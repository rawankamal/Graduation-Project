// DOM Elements
const chatArea = document.getElementById('chatArea');
const noMessagesContainer = document.getElementById('noMessagesContainer');
const messageInput = document.getElementById('messageInput');
const sendButton = document.getElementById('sendButton');
const emptyChatsContainer = document.getElementById('empty-chats-container');
const chatsAside = document.getElementById('chatsAside');

// Store chat data
const chatData = {
  currentChat: null,
  chats: [
    {
      id: 1,
      name: "Darrell Steward",
      image: "../images/parent.png",
      lastMessage: "We need to schedule a follow-up",
      time: "2:30 PM",
      unreadCount: 0,
      isPinned: true,
      messages: [ 
        {
          sender: "Darrell Steward",
          content: "Hello there! How are you doing today?",
          time: "2:15 PM",
          isRead: true
        },
        {
          sender: "me",
          content: "Hi Darrell! I'm doing great, thanks for asking.",
          time: "2:20 PM",
          isRead: true
        },
        {
          sender: "Darrell Steward",
          content: "We need to schedule a follow-up",
          time: "2:30 PM",
          isRead: true
        }
      ]
    },
    {
      id: 2,
      name: "Jane Cooper",
      image: "../images/parent.png",
      lastMessage: "Can we meet tomorrow?",
      time: "1:45 PM",
      unreadCount: 2,
      isPinned: false,
      messages: [ 
        {
          sender: "Jane Cooper",
          content: "Hi there!",
          time: "1:30 PM",
          isRead: false
        },
        {
          sender: "Jane Cooper",
          content: "Can we meet tomorrow?",
          time: "1:45 PM",
          isRead: false
        }
      ]
    },
    {
      id: 3,
      name: "Robert Johnson",
      image: "../images/parent.png",
      lastMessage: "Thanks for your help!",
      time: "Yesterday",
      unreadCount: 9,
      isPinned: false,
      messages: [ 
        {
          sender: "Robert Johnson",
          content: "I needed some help with the documents",
          time: "Yesterday",
          isRead: false
        },
        {
          sender: "me",
          content: "I'll send them right away",
          time: "Yesterday",
          isRead: true
        },
        {
          sender: "Robert Johnson",
          content: "Thanks for your help!",
          time: "Yesterday",
          isRead: false
        }
      ]
    },
    {
      id: 4,
      name: "Sarah Williams",
      image: "../images/parent.png",
      lastMessage: "The meeting is confirmed",
      time: "Yesterday",
      unreadCount: 12,
      isPinned: false,
      messages: [
        {
          sender: "Sarah Williams",
          content: "Hello, are we still on for the meeting?",
          time: "Yesterday",
          isRead: false
        },
        {
          sender: "me",
          content: "Yes, I'll be there",
          time: "Yesterday",
          isRead: true
        },
        {
          sender: "Sarah Williams",
          content: "The meeting is confirmed",
          time: "Yesterday",
          isRead: false
        }
      ]
    }
  ]
};

// Initialize the chat interface
function initializeChat() {
  renderChatList();
  
  // Show empty state if no chats
  if (chatData.chats.length === 0) {
    emptyChatsContainer.classList.remove('d-none');
  } else {
    emptyChatsContainer.classList.add('d-none');
  }
  
  // Send message when clicking send button
  sendButton.addEventListener('click', sendMessage);
  
  // Send message when pressing Enter
  messageInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      sendMessage();
    }
  });
}

// Render the list of chats in the sidebar
function renderChatList() {
  // Clear the sidebar
  chatsAside.innerHTML = '';
  
  // Add search bar
  const searchBar = `
    <div class="d-flex justify-content-center align-items-center py-3 w-100">
      <div class="search-bar border">
        <i class="bi bi-search text-secondary"></i>
        <input type="search" class="" placeholder="Search for anything...">
      </div>
      <i class="ps-2 fs-3 bi bi-pencil-square"></i>
    </div>
  `;
  chatsAside.innerHTML = searchBar;
  
  // Sort chats: pinned first, then by last message time
  const sortedChats = [...chatData.chats].sort((a, b) => {
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;
    return 0;
  });
  
  // Render each chat
  sortedChats.forEach(chat => {
    const chatElement = document.createElement('article');
    chatElement.className = 'd-flex justify-content-start align-items-center border-bottom py-3';
    chatElement.dataset.chatId = chat.id;
    
    // Create unread indicator
    let unreadIndicator = '';
    if (chat.unreadCount > 0) {
      if (chat.unreadCount <= 9) {
        unreadIndicator = `<i class="bi bi-${chat.unreadCount}-circle-fill fs-5 incoming-msg"></i>`;
      } else {
        unreadIndicator = `<i class="bi bi-plus btn-text-primary"></i><i class="bi bi-9-circle-fill fs-5 incoming-msg"></i>`;
      }
    }
    
    // Create read/unread status icon
    let readStatus = '';
    const lastMessage = chat.messages[chat.messages.length - 1];
    if (lastMessage && lastMessage.sender === 'me') {
      readStatus = lastMessage.isRead 
        ? '<i class="bi bi-check-all fs-3 read ps-1"></i>' 
        : '<i class="bi bi-check-all fs-3 unread ps-1"></i>';
    }
    
    // Create pin icon if pinned
    const pinIcon = chat.isPinned ? '<i class="bi bi-pin-angle-fill ps-2"></i>' : '';
    
    chatElement.innerHTML = `
      <img src="${chat.image}" alt="photo" width="70px" class="rounded-circle me-3">
      <div class="d-flex flex-column justify-content-start align-items-start w-100">
        <div class="d-flex justify-content-between align-items-center w-100">
          <p class="fw-bold">${chat.name}</p>
          <p class="text-secondary">${chat.time}</p>
        </div>
        <div class="d-flex justify-content-between align-items-center w-100">
          <p class="text-secondary">${chat.lastMessage}</p>
          <div class="d-flex justify-content-end align-items-center">
            ${pinIcon}
            ${unreadIndicator}
            ${readStatus}
          </div>
        </div>
      </div>
    `;
    
    // Add click event to open the chat
    chatElement.addEventListener('click', () => openChat(chat.id));
    
    chatsAside.appendChild(chatElement);
  });
}

// Open a specific chat
function openChat(chatId) {
  // Find the chat by ID
  const chat = chatData.chats.find(c => c.id === chatId);
  if (!chat) return;
  
  // Set as current chat
  chatData.currentChat = chat;
  
  // Update chat header
  document.querySelector('.chats-main .top-bar img').src = chat.image;
  document.querySelector('.chats-main .top-bar p.fs-4').textContent = chat.name;
  
  // Update chat details
  document.querySelector('#chatsDetails img').src = chat.image;
  document.querySelector('#chatsDetails p.fs-4').textContent = chat.name;
  
  // Mark messages as read
  chat.messages.forEach(msg => msg.isRead = true);
  chat.unreadCount = 0;
  
  // Render chat messages
  renderChatMessages(chat);
  
  // Update chat list to reflect read status
  renderChatList();
}

// Render messages for the current chat
function renderChatMessages(chat) {
  // Clear chat area
  chatArea.innerHTML = '';
  
  // Hide empty message container if there are messages
  if (chat.messages.length > 0) {
    noMessagesContainer.classList.add('d-none');
  } else {
    noMessagesContainer.classList.remove('d-none');
    return;
  }
  
  // Render each message
  chat.messages.forEach(message => {
    const messageElement = document.createElement('div');
    messageElement.className = message.sender === 'me' 
      ? 'message-container message-sent d-flex justify-content-end' 
      : 'message-container message-received d-flex justify-content-start';
    
    const messageContent = `
      <div class="d-flex justify-content-start ${message.sender === 'me' ? 'align-items-end' : 'align-items-start'} flex-column">
        <div class="message-bubble ${message.sender === 'me' ? 'sent' : 'received'} my-2 p-3 rounded-4">
          <p>${message.content}</p>
        </div>
        <div class="d-flex justify-content-between align-items-center">
            <small class="text-secondary">${message.time}</small>
            ${message.sender === 'me' ?
          (message.isRead ?
            '<i class="bi bi-check-all fs-6 read"></i>' :
            '<i class="bi bi-check-all fs-6 unread"></i>') :
          ''}
          </div>
      </div>
    `;
    
    messageElement.innerHTML = messageContent;
    chatArea.appendChild(messageElement);
  });
  
  // Scroll to bottom
  chatArea.scrollTop = chatArea.scrollHeight;
}

// Send a new message
function sendMessage() {
  const messageText = messageInput.value.trim();
  if (!messageText || !chatData.currentChat) return;
  
  // Create new message
  const newMessage = {
    sender: 'me',
    content: messageText,
    time: getCurrentTime(),
    isRead: false
  };
  
  // Add message to current chat
  chatData.currentChat.messages.push(newMessage);
  chatData.currentChat.lastMessage = messageText;
  chatData.currentChat.time = getCurrentTime();
  
  // Render message
  renderChatMessages(chatData.currentChat);
  
  // Update chat list
  renderChatList();
  
  // Clear input
  messageInput.value = '';
}

// Get current time in format HH:MM AM/PM
function getCurrentTime() {
  const now = new Date();
  return now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

// Pin/unpin chat
function togglePinChat(chatId) {
  const chat = chatData.chats.find(c => c.id === chatId);
  if (!chat) return;
  
  chat.isPinned = !chat.isPinned;
  renderChatList();
}

// Delete chat
function handleDeleteChat() {
  if (!chatData.currentChat) return;
  
  // Remove chat from the list
  chatData.chats = chatData.chats.filter(c => c.id !== chatData.currentChat.id);
  
  // Clear current chat
  chatData.currentChat = null;
  
  // Hide modal
  const modal = bootstrap.Modal.getInstance(document.getElementById('deleteChatModal'));
  modal.hide();
  
  // Render chat list
  renderChatList();
  
  // Clear chat area
  chatArea.innerHTML = '';
  noMessagesContainer.classList.remove('d-none');
  
  // Show empty state if no chats
  if (chatData.chats.length === 0) {
    emptyChatsContainer.classList.remove('d-none');
  }
}

// Setup pin chat functionality
document.addEventListener('click', function(e) {
  if (e.target.classList.contains('dropdown-item') && e.target.textContent.includes('Pin Chat')) {
    if (chatData.currentChat) {
      togglePinChat(chatData.currentChat.id);
    }
  }
});

// Add CSS for read/unread messages
function addChatStyles() {
  const styleElement = document.createElement('style');
  styleElement.textContent = `
    .message-bubble {
      max-width: 70%;
      word-wrap: break-word;
    }
    
    .message-bubble.sent {
      background-color: #DBE5B1;
      color: #333;
      border-radius: 16px 16px 0 16px !important;
    }
    
    .message-bubble.received {
      background-color: #f0f0f0;
      color: #333;
      border-radius: 16px 16px 16px 0 !important;
    }
    
    .read {
      color: #204E4C;
    }
    
    .unread {
      color:rgb(172, 175, 172);
    }
    
    .incoming-msg {
      color: #204E4C;
    }
    
    .chat-area {
      padding: 15px;
      display: flex;
      flex-direction: column;
    }
    
    .chats-tab article {
      cursor: pointer;
      transition: background-color 0.2s ease;
    }
    
    .chats-tab article:hover {
      background-color: #f5f5f5;
    }
    
    .chats-tab .input-area {
      padding: 10px;
      border-top: 1px solid #e0e0e0;
    }
    
    .chats-tab .btn-send {
      background-color: #204E4C;
      color: white;
    }
    
    .chats-tab .btn-send:hover {
      background-color: #3B918C;
      color: white;
    }
  `;
  document.head.appendChild(styleElement);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
  addChatStyles();
  initializeChat();
  
  // If there are chats, open the first one by default
  if (chatData.chats.length > 0) {
    openChat(chatData.chats[0].id);
  }
});

// Functions to handle chat details panel
function showChatDetails() {
  if (!chatData.currentChat) return;
  
  const details = document.getElementById('chatsDetails');
  const threadDetails = document.getElementById('threadDetails');
  const main = document.querySelector('.chats-main');
  
  // Update details with current chat user information
  document.querySelector('#chatsDetails img').src = chatData.currentChat.image;
  document.querySelector('#chatsDetails p.fs-4').textContent = chatData.currentChat.name;
  
  // Hide thread details if it's open
  if (!threadDetails.classList.contains('d-none')) {
    threadDetails.classList.add('d-none');
  }
  
  // Show details panel with transition
  details.style.transition = 'all .5s ease';
  main.style.transition = 'all .5s ease';
  details.classList.remove('d-none');
  main.classList.remove('col-lg-8');
  main.classList.add('col-lg-5');
}

function hideChatDetails() {
  const details = document.getElementById('chatsDetails');
  const main = document.querySelector('.chats-main');
  
  // Hide details panel with transition
  details.style.transition = 'all .5s ease';
  main.style.transition = 'all .5s ease';
  details.classList.add('d-none');
  main.classList.remove('col-lg-5');
  main.classList.add('col-lg-8');
}

function showThreadDetails() {
  const details = document.getElementById('chatsDetails');
  const threadDetails = document.getElementById('threadDetails');
  const main = document.querySelector('.chats-main');
  
  // Hide chat details if it's open
  if (!details.classList.contains('d-none')) {
    details.classList.add('d-none');
  }
  
  // Show thread details panel with transition
  threadDetails.style.transition = 'all .5s ease';
  main.style.transition = 'all .5s ease';
  threadDetails.classList.remove('d-none');
  main.classList.remove('col-lg-8');
  main.classList.add('col-lg-5');
}

function hideThreadDetails() {
  const threadDetails = document.getElementById('threadDetails');
  const main = document.querySelector('.chats-main');
  
  // Hide thread details panel with transition
  threadDetails.style.transition = 'all .5s ease';
  main.style.transition = 'all .5s ease';
  threadDetails.classList.add('d-none');
  main.classList.remove('col-lg-5');
  main.classList.add('col-lg-8');
}

// Set up delete chat modal
document.addEventListener('DOMContentLoaded', function() {
  // Create delete chat modal
  const modalHTML = `
    <div class="modal fade" id="deleteChatModal" tabindex="-1" aria-labelledby="deleteChatModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="deleteChatModalLabel">Delete Chat</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            Are you sure you want to delete this chat? This action cannot be undone.
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
          </div>
        </div>
      </div>
    </div>
  `;
  
  document.body.insertAdjacentHTML('beforeend', modalHTML);
  
  // Add event listener for delete confirmation
  document.getElementById('confirmDeleteBtn').addEventListener('click', handleDeleteChat);
  
  // Replace inline onclick handlers with proper event listeners
  document.querySelector('.chats-main .top-bar img').addEventListener('click', showChatDetails);
  document.querySelector('#chatsDetails .bi-x').addEventListener('click', hideChatDetails);
});