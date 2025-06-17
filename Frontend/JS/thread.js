// Authentication functions (from your existing code)
function getAuthData() {
    try {
        const authData = sessionStorage.getItem('authData') || localStorage.getItem('authData');
        return authData ? JSON.parse(authData) : null;
    } catch (error) {
        console.error('Error parsing auth data:', error);
        return null;
    }
}

function checkAuth() {
    const authData = getAuthData();
    if (!authData || !authData.accessToken) {
        console.log("No access token found, redirecting to login");
        return false;
    }
    if (authData.expiresAt && Date.now() >= authData.expiresAt) {
        console.log("Token expired");
        return authData.refreshToken ? true : false;
    }
    return true;
}

function showToast(message, type = 'info') {
    const bgColor = type === 'error' ? '#FF4B4B' :
        type === 'success' ? '#3B918C' :
            type === 'info' ? '#B8CC66' :
                type === 'warning' ? '#FFA500' : '#DBE5B1';

    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: message,
            duration: 3000,
            close: true,
            gravity: "top",
            position: "right",
            backgroundColor: bgColor,
            stopOnFocus: true
        }).showToast();
    } else {
        console.log(`${type.toUpperCase()}: ${message}`);
    }
}

// Main Threads Chat Manager
class ThreadsChatManager {
    constructor() {
        this.connection = null;
        this.currentThreadId = null;
        this.onlineMembers = [];
        this.isConnected = false;
        this.threads = new Map();
        this.apiBase = 'https://autine-back.runasp.net/api';
        this.hubUrl = 'https://autine-back.runasp.net/thread-chat';

        this.init();
    }

    init() {
        this.initializeElements();
        this.bindEvents();
        this.loadThreads();
        this.connectToHub();
    }

    initializeElements() {
        this.elements = {
            connectionStatus: document.getElementById('connectionStatus'),
            threadsList: document.getElementById('threadsList'),
            chatArea: document.getElementById('chatArea'),
            messageInput: document.getElementById('messageInput'),
            sendBtn: document.getElementById('sendBtn'),
            currentThreadName: document.getElementById('currentThreadName'),
            currentThreadId: document.getElementById('currentThreadId'),
            membersList: document.getElementById('membersList'),
            reconnectBtn: document.getElementById('reconnectBtn')
        };
    }

    bindEvents() {
        // Send message events
        if (this.elements.sendBtn) {
            this.elements.sendBtn.addEventListener('click', () => this.sendMessage());
        }

        if (this.elements.messageInput) {
            this.elements.messageInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    this.sendMessage();
                }
            });
        }

        // Reconnect button
        if (this.elements.reconnectBtn) {
            this.elements.reconnectBtn.addEventListener('click', () => this.connectToHub());
        }
    }

    async makeAuthenticatedRequest(url, options = {}) {
        const authData = getAuthData();
        if (!authData || !authData.accessToken) {
            throw new Error('No authentication token available');
        }

        return fetch(url, {
            ...options,
            headers: {
                'Authorization': `Bearer ${authData.accessToken}`,
                'Content-Type': 'application/json',
                ...options.headers
            }
        });
    }

    async loadThreads() {
        if (!checkAuth()) {
            showToast('Authentication required. Please login.', 'error');
            return;
        }

        try {
            const response = await this.makeAuthenticatedRequest(`${this.apiBase}/Threads/`);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

            const data = await response.json();
            this.threads.clear();

            data.forEach((thread, index) => {
                this.threads.set(thread.id, {
                    id: thread.id,
                    title: thread.title,
                    description: thread.description || '',
                    createdAt: thread.createdAt,
                    messages: []
                });
            });

            this.renderThreadsList();
            showToast('Threads loaded successfully', 'success');
        } catch (error) {
            console.error('Error loading threads:', error);
            showToast('Failed to load threads', 'error');
        }
    }

    renderThreadsList() {
        if (!this.elements.threadsList) return;

        this.elements.threadsList.innerHTML = '';

        if (this.threads.size === 0) {
            this.elements.threadsList.innerHTML = `
                <div class="text-center p-4 text-muted">
                    <i class="bi bi-chat-dots fs-1"></i>
                    <p class="mt-2">No threads available</p>
                </div>
            `;
            return;
        }

        this.threads.forEach(thread => {
            const threadElement = this.createThreadElement(thread);
            this.elements.threadsList.appendChild(threadElement);
        });
    }

    createThreadElement(thread) {
        const div = document.createElement('div');
        div.className = 'thread-item border-bottom py-3 px-2';
        div.style.cursor = 'pointer';
        div.dataset.threadId = thread.id;

        div.innerHTML = `
            <div class="d-flex align-items-center">
                <div class="me-3">
                    <i class="bi bi-chat-square-text fs-4 text-primary"></i>
                </div>
                <div class="flex-grow-1">
                    <h6 class="mb-1 fw-bold">${this.escapeHtml(thread.title)}</h6>
                    <p class="mb-0 text-muted small">${this.escapeHtml(thread.description)}</p>
                    <small class="text-muted">${new Date(thread.createdAt).toLocaleDateString()}</small>
                </div>
            </div>
        `;
        console.log('Creating thread element:', thread.id, thread.title);
        console.log('hub is connected:', this.isConnected);

        div.addEventListener('click', () => this.selectThread(thread.id));
        return div;
    }

    async selectThread(threadId) {
        if (this.currentThreadId === threadId) return;

        // Leave current thread if any
        if (this.currentThreadId) {
            await this.leaveCurrentThread();
        }

        // Select new thread
        this.currentThreadId = threadId;
        const thread = this.threads.get(threadId);

        if (!thread) return;

        // Update UI
        this.updateThreadSelection(threadId);
        this.updateCurrentThreadInfo(thread);
        this.clearChatArea();

        // Join new thread via SignalR
        if (this.isConnected) {
            await this.joinThread(threadId);
            console.log(`Joined thread: ${thread.title}`);
        }
    
    }

    updateThreadSelection(threadId) {
        // Remove active class from all threads
        document.querySelectorAll('.thread-item').forEach(item => {
            item.classList.remove('active', 'bg-primary', 'text-white');
        });

        // Add active class to selected thread
        const selectedElement = document.querySelector(`[data-thread-id="${threadId}"]`);
        if (selectedElement) {
            selectedElement.classList.add('active', 'bg-primary', 'text-white');
        }
    }

    updateCurrentThreadInfo(thread) {
        if (this.elements.currentThreadName) {
            this.elements.currentThreadName.textContent = thread.title;
        }
        if (this.elements.currentThreadId) {
            this.elements.currentThreadId.textContent = `ID: ${thread.id}`;
        }
    }

    async connectToHub() {
        if (!checkAuth()) {
            showToast('Authentication required for real-time chat', 'error');
            return;
        }

        const authData = getAuthData();

        try {
            this.updateConnectionStatus('connecting', 'Connecting to chat...');

            let token = authData.accessToken.startsWith("Bearer ")
                ? authData.accessToken.slice(7)
                : authData.accessToken;

            this.connection = new signalR.HubConnectionBuilder()
                .withUrl(this.hubUrl, {
                    accessTokenFactory: () => token
                })
                .withAutomaticReconnect()
                .build();

            this.setupHubEvents();



            await this.connection.start();

            console.log('SignalR connection established');

            this.isConnected = true;
            this.updateConnectionStatus('connected', 'Connected to chat');
            this.updateButtonStates();
            showToast('Connected to real-time chat', 'success');

        } catch (error) {
            console.error('SignalR connection failed:', error);
            this.updateConnectionStatus('disconnected', 'Connection failed');
            this.updateButtonStates();
            showToast('Failed to connect to real-time chat', 'error');
        }
    }

    setupHubEvents() {
        // Thread joined event
        this.connection.on('ThreadJoined', (response) => {
            console.log('Thread joined:', response);
            showToast(`Joined thread: ${response.title}`, 'success');
            this.addSystemMessage(`Joined "${response.title}" - ${response.connectedMemberCount} members online`);
            this.updateOnlineMembers(response.onlineMember || []);
        });

        // Member joined event
        this.connection.on('MemberJoined', (response) => {
            const memberName = response.member?.userResponse?.fullName || response.member?.userId || 'Unknown User';
            console.log('Member joined:', memberName);
            this.addSystemMessage(`${memberName} joined the chat`);
            this.updateOnlineMembers(response.onlineMember || []);
        });

        // Member left event
        this.connection.on('MemberLeft', (response) => {
            const memberName = response.member?.userResponse?.fullName || response.member?.userId || 'Unknown User';
            console.log('Member left:', memberName);
            this.addSystemMessage(`${memberName} left the chat`);
            this.updateOnlineMembers(response.onlineMember || []);
        });

        // Receive message event
        this.connection.on('ReceiveMessage', (message, onlineUsersCount) => {
            console.log('Message received:', message);

            const isOwnMessage = message.direction === true;
            const senderName = message.member?.userResponse?.fullName ||
                message.member?.userId || 'Unknown User';

            if (!isOwnMessage) {
                this.addMessage(senderName, message.content, false, message.timestamp);
            }
        });

        // Connection events
        this.connection.onclose((error) => {
            this.isConnected = false;
            this.currentThreadId = null;
            this.updateConnectionStatus('disconnected', 'Connection lost');
            this.updateButtonStates();
            console.error('Connection closed:', error);
            showToast('Chat connection lost', 'error');
        });

        this.connection.onreconnecting((error) => {
            this.updateConnectionStatus('connecting', 'Reconnecting...');
            console.log('Reconnecting:', error);
        });

        this.connection.onreconnected((connectionId) => {
            this.isConnected = true;
            this.updateConnectionStatus('connected', 'Reconnected');
            this.updateButtonStates();
            console.log('Reconnected:', connectionId);
            showToast('Chat reconnected', 'success');
        });
    }

    async joinThread(threadId) {
        if (!this.connection || !this.isConnected) {
            showToast('Not connected to chat server', 'error');
            return;
        }

        try {
            await this.connection.invoke('JoinThread', threadId);
            console.log('Joined thread:', threadId);
        } catch (error) {
            console.error('Failed to join thread:', error);
            showToast('Failed to join thread chat', 'error');
        }
    }

    async leaveCurrentThread() {
        if (!this.currentThreadId || !this.connection) return;

        try {
            // The hub handles leaving automatically when joining another thread
            // or when disconnecting, but we can clear local state
            this.currentThreadId = null;
            this.clearChatArea();
            this.updateOnlineMembers([]);
        } catch (error) {
            console.error('Error leaving thread:', error);
        }
    }

    async sendMessage() {
        const content = this.elements.messageInput?.value?.trim();

        if (!content) return;

        if (!this.currentThreadId) {
            showToast('Please select a thread first', 'warning');
            return;
        }

        if (!this.connection || !this.isConnected) {
            showToast('Not connected to chat server', 'error');
            return;
        }

        try {
            const messageRequest = {
                threadId: this.currentThreadId,
                content: content
            };

            // Add message to UI immediately for better UX
            this.addMessage('You', content, true);
            this.elements.messageInput.value = '';

            // Send via SignalR
            await this.connection.invoke('SendMessage', messageRequest);
            console.log('Message sent:', content);
            showToast('Message sent successfully', 'success');

        } catch (error) {
            console.error('Failed to send message:', error);
            showToast('Failed to send message', 'error');
        }
    }

    addMessage(sender, content, isOutgoing = false, timestamp = null) {
        if (!this.elements.chatArea) return;

        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${isOutgoing ? 'outgoing' : 'incoming'} mb-3`;

        const time = timestamp ? new Date(timestamp).toLocaleTimeString() : new Date().toLocaleTimeString();

        messageDiv.innerHTML = `
            <div class="d-flex ${isOutgoing ? 'justify-content-end' : 'justify-content-start'}">
                <div class="message-bubble p-3 rounded-3 ${isOutgoing ? 'bg-primary text-white' : 'bg-light'}">
                    ${!isOutgoing ? `<div class="fw-bold small mb-1">${this.escapeHtml(sender)}</div>` : ''}
                    <div>${this.escapeHtml(content)}</div>
                    <div class="small opacity-75 mt-1">${time}</div>
                </div>
            </div>
        `;

        this.elements.chatArea.appendChild(messageDiv);
        this.elements.chatArea.scrollTop = this.elements.chatArea.scrollHeight;
    }

    addSystemMessage(content) {
        if (!this.elements.chatArea) return;

        const messageDiv = document.createElement('div');
        messageDiv.className = 'message system text-center mb-3';

        messageDiv.innerHTML = `
            <div class="small text-muted p-2 rounded bg-light d-inline-block">
                <i class="bi bi-info-circle me-1"></i>
                ${this.escapeHtml(content)}
            </div>
        `;

        this.elements.chatArea.appendChild(messageDiv);
        this.elements.chatArea.scrollTop = this.elements.chatArea.scrollHeight;
    }

    clearChatArea() {
        if (this.elements.chatArea) {
            this.elements.chatArea.innerHTML = `
                <div class="text-center text-muted p-4">
                    <i class="bi bi-chat-dots fs-1"></i>
                    <p class="mt-2">No messages yet. Start the conversation!</p>
                </div>
            `;
        }
    }

    updateOnlineMembers(members) {
        this.onlineMembers = members || [];

        if (!this.elements.membersList) return;

        this.elements.membersList.innerHTML = '';

        if (this.onlineMembers.length === 0) {
            this.elements.membersList.innerHTML = `
                <div class="text-muted small text-center p-2">
                    No members online
                </div>
            `;
            return;
        }

        this.onlineMembers.forEach(member => {
            const memberDiv = document.createElement('div');
            memberDiv.className = 'member-item d-flex align-items-center p-2 mb-1 bg-light rounded';

            const memberName = member.userResponse?.fullName || member.userId || 'Unknown User';

            memberDiv.innerHTML = `
                <div class="status-dot bg-success rounded-circle me-2" style="width: 8px; height: 8px;"></div>
                <span class="small">${this.escapeHtml(memberName)}</span>
            `;

            this.elements.membersList.appendChild(memberDiv);
        });
    }

    updateConnectionStatus(status, message) {
        if (!this.elements.connectionStatus) return;

        this.elements.connectionStatus.className = `connection-status ${status}`;
        this.elements.connectionStatus.innerHTML = `
            <i class="bi bi-${status === 'connected' ? 'wifi' : status === 'connecting' ? 'arrow-repeat' : 'wifi-off'} me-2"></i>
            ${message}
        `;
    }

    updateButtonStates() {
        if (this.elements.sendBtn) {
            this.elements.sendBtn.disabled = !this.isConnected || !this.currentThreadId;
        }
        if (this.elements.messageInput) {
            this.elements.messageInput.disabled = !this.isConnected || !this.currentThreadId;
        }
        if (this.elements.reconnectBtn) {
            this.elements.reconnectBtn.style.display = this.isConnected ? 'none' : 'inline-block';
        }
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Public methods for external access
    refreshThreads() {
        return this.loadThreads();
    }

    disconnect() {
        if (this.connection) {
            this.connection.stop();
        }
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.threadsChatManager = new ThreadsChatManager();
});

// Export for external access
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ThreadsChatManager;
}