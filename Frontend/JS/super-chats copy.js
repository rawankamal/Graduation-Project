// Authentication functions
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

    // Check if token is expired
    if (authData.expiresAt && Date.now() >= authData.expiresAt) {
        console.log("Token expired");
        if (authData.refreshToken) {
            // You can implement token refresh here if needed
            return true;
        } else {
            return false;
        }
    }

    return true;
}

function clearAuthData() {
    // Clear refresh interval when logging out
    if (refreshInterval) {
        clearInterval(refreshInterval);
        refreshInterval = null;
    }

    sessionStorage.removeItem('authData');
    localStorage.removeItem('authData');
    sessionStorage.removeItem('userEmail');
    localStorage.removeItem('userEmail');
}

function showToast(message, type = 'info') {
    const bgColor = type === 'error' ? '#FF4B4B' :
        type === 'success' ? '#3B918C' :
            type === 'info' ? '#B8CC66' :
                type === 'warning' ? '#FFA500' : '#DBE5B1';

    Toastify({
        text: message,
        duration: 3000,
        close: true,
        gravity: "top",
        position: "right",
        backgroundColor: bgColor,
        stopOnFocus: true
    }).showToast();
}

// Chat Interface JavaScript with API Integration
class ChatManager {
    constructor() {
        this.currentChatId = null;
        this.currentThreadId = null;
        this.currentThreadApiId = null; // Store the actual API thread ID
        this.chats = new Map();
        this.threads = new Map();
        this.users = [];
        this.activeTab = 'chats';
        this.apiBase = 'https://autine-back.runasp.net/api';
        this.init();
    }

    init() {
        this.bindEvents();
        this.loadData();
    }

    bindEvents() {
        // Tab switching
        document.getElementById('myChats-tab')?.addEventListener('click', () => {
            this.activeTab = 'chats';
            this.showEmptyState();
        });

        document.getElementById('myThreads-tab')?.addEventListener('click', () => {
            this.activeTab = 'threads';
            this.showEmptyState();
        });

        // Message sending
        const sendButton = document.getElementById('sendButton');
        const messageInput = document.getElementById('messageInput');
        sendButton?.addEventListener('click', () => this.sendMessage());
        messageInput?.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.sendMessage();
        });

        // Search functionality
        document.querySelectorAll('input[type="search"]').forEach(input => {
            input.addEventListener('input', (e) => this.handleSearch(e.target.value));
        });

        // Details toggles
        document.querySelector('[aria-label="View user details"]')?.addEventListener('click', () => {
            this.toggleChatDetails();
        });

        window.openThreadDetails = () => this.toggleThreadDetails();

        // Close details buttons
        document.querySelectorAll('[aria-label="Close details"]').forEach(btn => {
            btn.addEventListener('click', () => {
                document.getElementById('chatsDetails')?.classList.add('d-none');
                document.getElementById('threadDetails')?.classList.add('d-none');
            });
        });

        // Supervisor dropdown
        document.querySelectorAll('.supervisor-dropdown .dropdown-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                this.addSupervisor(e.target.textContent);
            });
        });
    }

    async loadData() {
        // Check authentication first
        if (!checkAuth()) {
            showToast('Authentication required. Please login.', 'error');
            window.location.href = '../pages/login.html';
            return;
        }

        try {
            await Promise.all([
                this.fetchChats(),
                this.fetchThreads(),
                this.fetchUsers()
            ]);
            this.showEmptyState();
            showToast('Data loaded successfully', 'success');
        } catch (error) {
            console.error('Error loading data:', error);
            showToast('Failed to load data. Using sample data.', 'warning');
            this.loadSampleData(); // Fallback to sample data
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

    async fetchChats() {
        try {
            const response = await this.makeAuthenticatedRequest(`${this.apiBase}/Chats/contacts`);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

            const data = await response.json();

            this.chats.clear();
            data.forEach((contact, index) => {
                this.chats.set(`chat_${index}`, {
                    id: `chat_${index}`,
                    name: `${contact.firstName} ${contact.lastName}`,
                    avatar: contact.profilePic || '../images/parent.png',
                    lastMessage: 'Tap to continue chatting !',
                    timestamp: '',
                    messages: [],
                    isPinned: false,
                    isRead: true
                });
            });
        } catch (error) {
            console.error('Error fetching chats:', error);
            showToast('Failed to fetch chats', 'error');
        }
    }

    async fetchThreads() {
        try {
            const response = await this.makeAuthenticatedRequest(`${this.apiBase}/Threads/`);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

            const data = await response.json();

            this.threads.clear();
            data.forEach((thread, index) => {
                this.threads.set(`thread_${index}`, {
                    id: `thread_${index}`,
                    apiId: thread.id, // Store the actual API ID
                    name: thread.title,
                    threadId: thread.id || `THR-${Math.random().toString(36).substr(2, 6).toUpperCase()}`,
                    avatar: '../images/patient.png',
                    lastMessage: 'Tap to continue chatting !',
                    timestamp: '',
                    messages: [],
                    isPinned: false,
                    isRead: true,
                    members: []
                });
            });
        } catch (error) {
            console.error('Error fetching threads:', error);
            showToast('Failed to fetch threads', 'error');
        }
    }

    async fetchThreadMembers(threadApiId) {
        try {
            const response = await this.makeAuthenticatedRequest(`${this.apiBase}/Threads/${threadApiId}/thread-members`);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

            const members = await response.json();

            // Process members with the new response structure
            const memberDetails = members.map((member) => {
                if (member.userResponse) {
                    return {
                        id: member.id,
                        userId: member.userId,
                        name: `${member.userResponse.firstName} ${member.userResponse.lastName}`,
                        avatar: member.userResponse.profilePic || '../images/parent.png',
                        role: member.userResponse.role,
                        createdAt: member.createdAt
                    };
                }
                return {
                    id: member.id,
                    userId: member.userId,
                    name: 'Unknown User',
                    avatar: '../images/parent.png',
                    role: 'Unknown',
                    createdAt: member.createdAt
                };
            });

            return memberDetails;
        } catch (error) {
            console.error('Error fetching thread members:', error);
            showToast('Failed to fetch thread members', 'error');
            return [];
        }
    }

    async addMemberToThread(threadApiId, memberId) {
        try {
            const response = await this.makeAuthenticatedRequest(
                `${this.apiBase}/Threads/${threadApiId}/add-member?memberId=${memberId}`,
                {
                    method: 'POST'
                }
            );
            
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            
            showToast('Member added to thread successfully', 'success');
            
            // Refresh thread members after adding
            if (this.currentThreadId) {
                const thread = this.threads.get(this.currentThreadId);
                if (thread && thread.apiId === threadApiId) {
                    const updatedMembers = await this.fetchThreadMembers(threadApiId);
                    thread.members = updatedMembers;
                    this.updateThreadMembersDisplay(thread);
                }
            }
            
            return true;
        } catch (error) {
            console.error('Error adding member to thread:', error);
            showToast('Failed to add member to thread', 'error');
            return false;
        }
    }

    async fetchUsers() {
        try {
            const response = await this.makeAuthenticatedRequest(`https://grad-project-ai-api.vercel.app/supervisor/gets`);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

            const data = await response.json();

            // Extract supervisors from the response and map to our user format
            this.users = data.supervisors.map(supervisor => ({
                id: supervisor.supervisor_username,
                firstName: supervisor.supervisor_fname,
                lastName: supervisor.supervisor_lname,
                email: supervisor.supervisor_email,
                role: 'Supervisor'
            }));
            
            this.updateSupervisorDropdown();
        } catch (error) {
            console.error('Error fetching supervisors:', error);
            showToast('Failed to fetch supervisors', 'error');
        }
    }

    updateSupervisorDropdown() {
        const dropdown = document.querySelector('.supervisor-dropdown .dropdown-menu');
        if (!dropdown) return;

        dropdown.innerHTML = '';
        this.users.forEach(user => {
            const li = document.createElement('li');
            li.className = 'd-flex align-items-center justify-content-between';
            li.innerHTML = `
                <a class="dropdown-item custom-drop" href="#" data-user-id="${user.id}">
                    ${user.firstName} ${user.lastName}
                </a>
                <span class="btn-text-primary mx-3 fw-bold">Add</span>
            `;

            li.addEventListener('click', async (e) => {
                e.preventDefault();
                if (this.currentThreadApiId) {
                    await this.addMemberToThread(this.currentThreadApiId, user.id);
                } else {
                    showToast('No thread selected', 'warning');
                }
            });

            dropdown.appendChild(li);
        });
    }

    loadSampleData() {
        // Fallback sample data
        this.chats.set('chat1', {
            id: 'chat1',
            name: 'Darrell Steward',
            avatar: '../images/parent.png',
            lastMessage: 'Thanks for the update!',
            timestamp: '2:30 PM',
            messages: [],
            isPinned: false,
            isRead: true
        });

        this.threads.set('thread1', {
            id: 'thread1',
            apiId: 'sample-thread-id',
            name: 'Liam Watson',
            threadId: 'THR-92A7XK',
            avatar: '../images/patient.png',
            lastMessage: 'We need to schedule a follow-up',
            timestamp: '2:30 PM',
            messages: [],
            isPinned: true,
            isRead: true,
            members: []
        });
    }

    showEmptyState() {
        const chatContainer = document.querySelector('#myChats-tab-pane .row.rounded-4');
        const threadContainer = document.querySelector('#myThreads-tab-pane .row.rounded-4');
        const emptyChatContainer = document.getElementById('empty-chats-container');
        const emptyThreadContainer = document.getElementById('empty-threads-container');

        if (this.activeTab === 'chats') {
            if (this.chats.size === 0) {
                chatContainer?.classList.add('d-none');
                emptyChatContainer?.classList.remove('d-none');
            } else {
                chatContainer?.classList.remove('d-none');
                emptyChatContainer?.classList.add('d-none');
                this.renderChatList();
            }
        } else {
            if (this.threads.size === 0) {
                threadContainer?.classList.add('d-none');
                emptyThreadContainer?.classList.remove('d-none');
            } else {
                threadContainer?.classList.remove('d-none');
                emptyThreadContainer?.classList.add('d-none');
                this.renderThreadList();
            }
        }
    }

    renderChatList() {
        const chatList = document.querySelector('#chatsAside .chat-list');
        if (!chatList) return;

        chatList.innerHTML = '';
        this.chats.forEach(chat => {
            chatList.appendChild(this.createChatItem(chat));
        });
    }

    renderThreadList() {
        const threadList = document.querySelector('#threadAside .chat-list');
        if (!threadList) return;

        threadList.innerHTML = '';
        this.threads.forEach(thread => {
            threadList.appendChild(this.createThreadItem(thread));
        });
    }

    createChatItem(chat) {
        const article = document.createElement('article');
        article.className = 'chat-item d-flex justify-content-start align-items-center border-bottom py-3';
        article.dataset.chatId = chat.id;
        article.style.cursor = 'pointer';

        article.innerHTML = `
            <img src="${chat.avatar}" alt="${chat.name}" width="56" class="rounded-circle me-3">
            <div class="d-flex flex-column justify-content-start align-items-start w-100">
                <div class="d-flex justify-content-between align-items-center w-100">
                    <p class="fw-bold mb-0">${chat.name}</p>
                </div>
                <div class="d-flex justify-content-between align-items-center w-100">
                    <p class="text-secondary mb-0">${chat.lastMessage}</p>
                    <div class="d-flex justify-content-end align-items-center">
                        ${chat.isPinned ? '<i class="bi bi-pin-angle-fill ps-2" aria-label="Pinned chat"></i>' : ''}
                    </div>
                </div>
            </div>
        `;

        article.addEventListener('click', () => this.selectChat(chat.id));
        return article;
    }

    createThreadItem(thread) {
        const article = document.createElement('article');
        article.className = 'chat-item d-flex justify-content-start align-items-center border-bottom py-3';
        article.dataset.threadId = thread.id;
        article.style.cursor = 'pointer';

        article.innerHTML = `
            <img src="${thread.avatar}" alt="${thread.name}" width="56" class="rounded-circle me-3">
            <div class="d-flex flex-column justify-content-start align-items-start w-100">
                <div class="d-flex justify-content-between align-items-center w-100">
                    <p class="fw-bold mb-0">${thread.name}</p>
                </div>
                <div class="d-flex justify-content-between align-items-center w-100">
                    <p class="text-secondary mb-0">${thread.lastMessage}</p>
                </div>
            </div>
        `;

        article.addEventListener('click', () => this.selectThread(thread.id));
        return article;
    }

    selectChat(chatId) {
        this.currentChatId = chatId;
        const chat = this.chats.get(chatId);
        if (!chat) return;

        document.querySelectorAll('.chat-item').forEach(item => item.classList.remove('active'));
        document.querySelector(`[data-chat-id="${chatId}"]`)?.classList.add('active');

        const header = document.querySelector('#chatsMain .top-bar');
        if (header) {
            header.querySelector('img').src = chat.avatar;
            header.querySelector('img').alt = chat.name;
            header.querySelector('p').textContent = chat.name;
        }

        this.renderMessages(chat.messages, 'chatsMain');
    }

    async selectThread(threadId) {
        this.currentThreadId = threadId;
        const thread = this.threads.get(threadId);
        if (!thread) return;

        this.currentThreadApiId = thread.apiId;

        document.querySelectorAll('.chat-item').forEach(item => item.classList.remove('active'));
        document.querySelector(`[data-thread-id="${threadId}"]`)?.classList.add('active');

        const header = document.querySelector('.thread-main .top-bar');
        if (header) {
            header.querySelector('img').src = thread.avatar;
            header.querySelector('img').alt = thread.name;
            header.querySelector('p').textContent = thread.name;
        }

        // Load thread members when selecting a thread
        if (thread.apiId) {
            const members = await this.fetchThreadMembers(thread.apiId);
            thread.members = members;
            this.updateThreadMembersDisplay(thread);
        }

        this.renderMessages(thread.messages, 'thread-main');
    }

    renderMessages(messages, containerClass) {
        const chatArea = document.querySelector(`.${containerClass} .chat-area`);
        if (!chatArea) return;

        const noMessagesContainer = chatArea.querySelector('#noMessagesContainer');

        if (messages.length === 0) {
            noMessagesContainer?.classList.remove('d-none');
            return;
        }

        noMessagesContainer?.classList.add('d-none');
        chatArea.querySelectorAll('.message').forEach(msg => msg.remove());

        messages.forEach(message => {
            chatArea.appendChild(this.createMessageElement(message));
        });

        chatArea.scrollTop = chatArea.scrollHeight;
    }

    createMessageElement(message) {
        const div = document.createElement('div');
        div.className = message.isOwn
            ? 'message-container message-sent d-flex justify-content-end'
            : 'message-container message-received d-flex justify-content-start';

        div.innerHTML = `
            <div class="d-flex justify-content-start ${message.isOwn ? 'align-items-end' : 'align-items-start'} flex-column">
                <div class="message-bubble ${message.isOwn ? 'sent' : 'received'} my-2 p-3 rounded-4">
                    ${!message.isOwn ? `<div class="fw-bold mb-1">${message.sender}</div>` : ''}
                    <p>${message.content}</p>
                </div>
            </div>
        `;

        return div;
    }

    sendMessage() {
        const messageInput = document.getElementById('messageInput');
        const content = messageInput?.value.trim();
        if (!content) return;

        const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        const message = {
            id: 'msg_' + Date.now(),
            sender: 'You',
            content: content,
            timestamp: timestamp,
            isOwn: true
        };

        if (this.activeTab === 'chats' && this.currentChatId) {
            const chat = this.chats.get(this.currentChatId);
            if (chat) {
                chat.messages.push(message);
                chat.lastMessage = content;
                chat.timestamp = timestamp;
                this.renderMessages(chat.messages, 'chatsMain');
                this.renderChatList();
            }
        } else if (this.activeTab === 'threads' && this.currentThreadId) {
            const thread = this.threads.get(this.currentThreadId);
            if (thread) {
                thread.messages.push(message);
                thread.lastMessage = content;
                thread.timestamp = timestamp;
                this.renderMessages(thread.messages, 'thread-main');
                this.renderThreadList();
            }
        }

        messageInput.value = '';
    }

    handleSearch(query) {
        const items = this.activeTab === 'chats'
            ? document.querySelectorAll('#chatsAside .chat-item')
            : document.querySelectorAll('#threadAside .chat-item');

        items.forEach(item => {
            const name = item.querySelector('.fw-bold').textContent.toLowerCase();
            const message = item.querySelector('.text-secondary').textContent.toLowerCase();
            const searchTerm = query.toLowerCase();

            item.style.display = (name.includes(searchTerm) || message.includes(searchTerm)) ? 'flex' : 'none';
        });
    }

    toggleChatDetails() {
        const detailsPanel = document.getElementById('chatsDetails');
        const mainPanel = document.getElementById('chatsMain');

        if (detailsPanel?.classList.contains('d-none')) {
            detailsPanel.classList.remove('d-none');
            mainPanel?.classList.remove('col-lg-8');
            mainPanel?.classList.add('col-lg-5');
        } else {
            detailsPanel?.classList.add('d-none');
            mainPanel?.classList.remove('col-lg-5');
            mainPanel?.classList.add('col-lg-8');
        }
    }

    toggleThreadDetails() {
        const detailsPanel = document.getElementById('threadDetails');
        const mainPanel = document.querySelector('.thread-main');

        if (detailsPanel?.classList.contains('d-none')) {
            detailsPanel.classList.remove('d-none');
            mainPanel?.classList.remove('col-lg-8');
            mainPanel?.classList.add('col-lg-5');

            // Load thread members when opening details
            if (this.currentThreadId && this.currentThreadApiId) {
                const thread = this.threads.get(this.currentThreadId);
                if (thread) {
                    this.updateThreadMembersDisplay(thread);
                }
            }
        } else {
            detailsPanel?.classList.add('d-none');
            mainPanel?.classList.remove('col-lg-5');
            mainPanel?.classList.add('col-lg-8');
        }
    }

    addSupervisor(supervisorName, avatar = '../images/parent.png') {
        if (this.currentThreadId) {
            const thread = this.threads.get(this.currentThreadId);
            if (thread) {
                thread.members.push({ name: supervisorName, avatar });
                this.updateThreadMembersDisplay(thread);
            }
        }
    }

    updateThreadMembersDisplay(thread) {
        const membersContainer = document.querySelector('#threadDetails .members-list');
        if (!membersContainer) {
            // Create the members list container if it doesn't exist
            const membersSection = document.querySelector('#threadDetails .row.justify-content-between');
            if (membersSection) {
                const membersList = document.createElement('div');
                membersList.className = 'members-list mt-3';
                membersSection.appendChild(membersList);
            }
            return;
        }

        if (!thread.members || thread.members.length === 0) {
            membersContainer.innerHTML = '<p class="text-secondary text-center">No members in this thread</p>';
            return;
        }

        membersContainer.innerHTML = '';

        thread.members.forEach(member => {
            const memberItem = document.createElement('div');
            memberItem.className = 'member-item d-flex justify-content-between align-items-center py-2 px-3 border-bottom';

            memberItem.innerHTML = `
                <div class="d-flex align-items-center">
                    <img src="${member.avatar}" alt="${member.name}" width="40" class="rounded-circle me-3">
                    <div>
                        <p class="mb-0 fw-bold">${member.name}</p>
                        ${member.role ? `<small class="text-secondary">${member.role}</small>` : ''}
                    </div>
                </div>
                <button class="btn btn-outline-primary btn-sm chat-btn" data-member-id="${member.userId || member.id}" title="Start chat">
                    <i class="bi bi-chat-dots"></i>
                </button>
            `;

            // Add event listener for chat button
            const chatBtn = memberItem.querySelector('.chat-btn');
            chatBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.startChatWithMember(member);
            });

            membersContainer.appendChild(memberItem);
        });
    }

    startChatWithMember(member) {
        // Switch to chats tab
        this.activeTab = 'chats';
        document.getElementById('myChats-tab')?.click();

        // Create or find existing chat with this member
        let existingChatId = null;
        this.chats.forEach((chat, chatId) => {
            if (chat.name === member.name) {
                existingChatId = chatId;
            }
        });

        if (existingChatId) {
            // Select existing chat
            this.selectChat(existingChatId);
        } else {
            // Create new chat
            const newChatId = `chat_${Date.now()}`;
            this.chats.set(newChatId, {
                id: newChatId,
                name: member.name,
                avatar: member.avatar,
                lastMessage: 'Start a conversation',
                timestamp: '',
                messages: [],
                isPinned: false,
                isRead: true
            });

            this.renderChatList();
            this.selectChat(newChatId);
        }

        showToast(`Started chat with ${member.name}`, 'success');
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new ChatManager();
});

// Utility functions
function formatTimestamp(date) {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function generateThreadId() {
    return 'THR-' + Math.random().toString(36).substr(2, 6).toUpperCase();
}

window.ChatManager = ChatManager;