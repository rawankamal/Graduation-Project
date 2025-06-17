// API base URL
const API_BASE_URL = 'https://gradationproject.runasp.net/api';

// Notification helper using Toastify
const showNotification = (message, isSuccess = true) => {
    Toastify({
        text: message,
        duration: 3000,
        close: true,
        gravity: "top",
        position: "right",
        backgroundColor: isSuccess ? "#204E4C" : "#FF4B4B",
        stopOnFocus: true
    }).showToast();
};

// Function to handle API errors
const handleApiError = (error) => {
    console.error('API Error:', error);
    // Display error notification to user using Toastify
    showNotification('An error occurred. Please try again.', false);
};

// Get auth data consistently - matching the auth module's approach
function getAuthData() {
    // Try session storage first, then localStorage
    let authData = null;
    const sessionData = sessionStorage.getItem('authData');
    const localData = localStorage.getItem('authData');

    if (sessionData) {
        authData = JSON.parse(sessionData);
    } else if (localData) {
        authData = JSON.parse(localData);
    }

    return authData;
}

// Get auth token from the auth data
const getAuthToken = () => {
    const authData = getAuthData();
    if (!authData || !authData.accessToken) {
        showNotification('No authentication token found');
        return '';
    }

    // // Check if token is expired
    // if (authData.expiresAt && Date.now() >= authData.expiresAt) {
    //     console.warn('Auth token is expired');
    //     // You may want to handle token refresh here or redirect to login
    //     if (confirm('Your session has expired. Please log in again.')) {
    //         window.location.href = '/pages/login.html';
    //     }
    //     return '';
    // }

    return authData.accessToken;
};

// Create headers with auth token
const createHeaders = (contentType = 'application/json') => {
    const headers = {
        'Content-Type': contentType,
        'Authorization': `Bearer ${getAuthToken()}`
    };
    return headers;
};

// Check if user is authenticated before making API calls
function checkAuthBeforeRequest() {
    const token = getAuthToken();
    if (!token) {
        showNotification('Authentication required. Please log in.', false);
        // Redirect after a short delay to allow the notification to be seen
        setTimeout(() => {
            window.location.href = '/pages/login.html';
        }, 2000);
        return false;
    }
    return true;
}

// Profile API service
const ProfileService = {
    // Get user profile
    getProfile: async () => {
        if (!checkAuthBeforeRequest()) return null;

        try {
            const response = await fetch(`${API_BASE_URL}/Profiles`, {
                method: 'GET',
                headers: createHeaders()
            });

            if (response.status === 401) {
                // Token is invalid or expired
                showNotification('Your session has expired. Please log in again.', false);
                setTimeout(() => {
                    window.location.href = '/pages/login.html';
                }, 2000);
                return null;
            }

            if (!response.ok) {
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            handleApiError(error);
            return null;
        }
    },

    // Update user profile
    updateProfile: async (profileData) => {
        if (!checkAuthBeforeRequest()) return null;

        try {
            const response = await fetch(`${API_BASE_URL}/Profiles`, {
                method: 'PUT',
                headers: createHeaders(),
                body: JSON.stringify(profileData)
            });

            if (response.status === 401) {
                // Token is invalid or expired
                showNotification('Your session has expired. Please log in again.', false);
                setTimeout(() => {
                    window.location.href = '/pages/login.html';
                }, 2000);
                return null;
            }

            if (!response.ok) {
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            handleApiError(error);
            return null;
        }
    },

    // Change password
    changePassword: async (passwordData) => {
        if (!checkAuthBeforeRequest()) return null;

        try {
            const response = await fetch(`${API_BASE_URL}/Profiles/change-password`, {
                method: 'PUT',
                headers: createHeaders(),
                body: JSON.stringify(passwordData)
            });

            if (response.status === 401) {
                // Token is invalid or expired
                showNotification('Your session has expired. Please log in again.', false);
                setTimeout(() => {
                    window.location.href = '/pages/login.html';
                }, 2000);
                return null;
            }

            if (!response.ok) {
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            handleApiError(error);
            return null;
        }
    },

    // Upload profile picture
    uploadProfilePicture: async (imageFile) => {
        if (!checkAuthBeforeRequest()) return null;

        try {
            const formData = new FormData();
            formData.append('Image', imageFile);

            const response = await fetch(`${API_BASE_URL}/Profiles/change-profile-picture`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${getAuthToken()}`
                    // Note: Don't set Content-Type header when using FormData
                },
                body: formData
            });

            if (response.status === 401) {
                // Token is invalid or expired
                showNotification('Your session has expired. Please log in again.', false);
                setTimeout(() => {
                    window.location.href = '/pages/login.html';
                }, 2000);
                return null;
            }

            if (!response.ok) {
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            handleApiError(error);
            return null;
        }
    },

    // Delete account
    deleteAccount: async () => {
        if (!checkAuthBeforeRequest()) return false;

        try {
            const response = await fetch(`${API_BASE_URL}/Profiles`, {
                method: 'DELETE',
                headers: createHeaders()
            });

            if (response.status === 401) {
                // Token is invalid or expired
                showNotification('Your session has expired. Please log in again.', false);
                setTimeout(() => {
                    window.location.href = '/pages/login.html';
                }, 2000);
                return false;
            }

            if (!response.ok) {
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }

            return true;
        } catch (error) {
            handleApiError(error);
            return false;
        }
    }
};

// Event handlers for profile form
document.addEventListener('DOMContentLoaded', () => {
    console.log("Profile page loaded - checking authentication...");

    // Check if the user is authenticated first
    if (!checkAuthBeforeRequest()) {
        console.error("User is not authenticated");
        return;
    }

    console.log("Authentication check passed - loading profile data");

    // Load user profile data
    const loadProfileData = async () => {
        try {
            console.log("Fetching profile data...");
            const profileData = await ProfileService.getProfile();
            console.log("Profile data received:", profileData);

            if (profileData) {
                // Populate profile form
                document.getElementById('firstName').value = profileData.firstName || '';
                document.getElementById('lastName').value = profileData.lastName || '';
                document.getElementById('bio').value = profileData.bio || '';

                // Set date of birth
                if (profileData.dateOfBirth) {
                    const dob = new Date(profileData.dateOfBirth);
                    if (!isNaN(dob.getTime())) {
                        document.getElementById('dob-day').value = dob.getDate();
                        document.getElementById('dob-month').value = dob.getMonth() + 1;
                        document.getElementById('dob-year').value = dob.getFullYear();
                    }
                }

                // Set gender
                if (profileData.gender) {
                    const genderRadio = document.querySelector(`input[name="customRadio"][value="${profileData.gender.toLowerCase()}"]`);
                    if (genderRadio) {
                        genderRadio.checked = true;
                    }
                }

                // Set country and city
                if (profileData.country) {
                    document.getElementById('country').value = profileData.country;
                    // Load cities for the selected country
                    loadCities(profileData.country, profileData.city);
                }

                // Load profile picture if exists
                if (profileData.profilePictureUrl) {
                    document.querySelector('.user-pic').src = profileData.profilePictureUrl;
                    document.getElementById('profilePic').src = profileData.profilePictureUrl;
                }

                // Also update the user modal
                document.getElementById('profile-first').value = profileData.firstName || '';
                document.getElementById('profile-last').value = profileData.lastName || '';
                document.getElementById('birthDate').value = profileData.dateOfBirth ?
                    new Date(profileData.dateOfBirth).toLocaleDateString() : '';
                document.getElementById('gender').value = profileData.gender || '';
                document.getElementById('country').value = profileData.country || '';
                document.getElementById('city').value = profileData.city || '';
                document.getElementById('email').value = profileData.email || '';
            } else {
                console.error("No profile data returned");
            }
        } catch (error) {
            console.error("Error loading profile:", error);
            showNotification("Error loading profile data", false);
        }
    };

    // Submit profile form
    document.getElementById('profileForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        // Basic form validation
        if (!validateProfileForm()) {
            return;
        }

        // Get form data
        const day = document.getElementById('dob-day').value;
        const month = document.getElementById('dob-month').value;
        const year = document.getElementById('dob-year').value;
        const dateOfBirth = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;

        const gender = document.querySelector('input[name="customRadio"]:checked')?.value || '';

        const profileData = {
            firstName: document.getElementById('firstName').value,
            lastName: document.getElementById('lastName').value,
            bio: document.getElementById('bio').value,
            country: document.getElementById('country').value,
            city: document.getElementById('city').value,
            gender: gender,
            dateOfBirth: dateOfBirth
        };

        // Update profile
        const result = await ProfileService.updateProfile(profileData);
        if (result) {
            showNotification('Profile updated successfully!');
            // Refresh profile data
            loadProfileData();
        }
    });

    // Upload profile picture
    document.getElementById('profile-pic').addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (file) {
            // Upload to server
            const result = await ProfileService.uploadProfilePicture(file);
            if (result) {
                // Update profile picture
                const profilePics = document.querySelectorAll('.profile-pic, .user-pic');
                profilePics.forEach(pic => {
                    pic.src = URL.createObjectURL(file);
                });
                showNotification('Profile picture updated successfully!');
            }
        }
    });

    // Delete profile picture
    document.querySelector('.btn-text-error').addEventListener('click', async () => {
        if (confirm('Are you sure you want to delete your profile picture?')) {
            // Reset profile picture to default
            const profilePics = document.querySelectorAll('.profile-pic, .user-pic');
            profilePics.forEach(pic => {
                pic.src = '../images/user.png';
            });

            // You might need a separate API endpoint for this or handle it differently
            showNotification('Profile picture deleted!');
        }
    });

    // Change password form
    document.getElementById('passwordForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        // Basic form validation
        if (!validatePasswordForm()) {
            return;
        }

        const passwordData = {
            currentPassword: document.getElementById('currentPassword').value,
            newPassword: document.getElementById('newPassword').value
        };

        // Change password
        const result = await ProfileService.changePassword(passwordData);
        if (result) {
            showNotification('Password changed successfully!');
            // Clear form
            document.getElementById('passwordForm').reset();
        }
    });

    // Delete account
    window.confirmDeletion = async () => {
        const password = document.getElementById('password').value;
        if (!password) {
            document.getElementById('password').classList.add('is-invalid');
            return;
        }

        if (!confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
            return;
        }

        // You might need to send the password for verification
        const result = await ProfileService.deleteAccount();
        if (result) {
            showNotification('Account deleted successfully!');
            // Redirect to login page
            setTimeout(() => {
                window.location.href = '../pages/login.html';
            }, 2000); // Allow time for the toast notification to be seen
        }
    };

    // Toggle password visibility
    const togglePasswordVisibility = (inputId, iconId) => {
        const passwordInput = document.getElementById(inputId);
        const icon = document.getElementById(iconId);

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            icon.classList.replace('bi-eye', 'bi-eye-slash');
        } else {
            passwordInput.type = 'password';
            icon.classList.replace('bi-eye-slash', 'bi-eye');
        }
    };

    // Set up password toggles
    document.getElementById('toggleCurrentPassword').addEventListener('click', () => {
        togglePasswordVisibility('currentPassword', 'toggleCurrentPassword');
    });

    document.getElementById('toggleNewPassword').addEventListener('click', () => {
        togglePasswordVisibility('newPassword', 'toggleNewPassword');
    });

    document.getElementById('toggleConfirmPassword').addEventListener('click', () => {
        togglePasswordVisibility('confirmPassword', 'toggleConfirmPassword');
    });

    // Form validation helpers
    function validateProfileForm() {
        const form = document.getElementById('profileForm');
        let isValid = true;

        // Reset validation
        form.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });

        // Validate required fields
        const requiredFields = ['firstName', 'lastName', 'bio', 'dob-day', 'dob-month', 'dob-year', 'country', 'city'];
        requiredFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (!field.value.trim()) {
                field.classList.add('is-invalid');
                isValid = false;
            }
        });

        // Validate gender
        const genderSelected = document.querySelector('input[name="customRadio"]:checked');
        if (!genderSelected) {
            document.querySelector('.gender-feedback').style.display = 'block';
            isValid = false;
        } else {
            document.querySelector('.gender-feedback').style.display = 'none';
        }

        if (!isValid) {
            showNotification('Please fill in all required fields correctly', false);
        }

        return isValid;
    }

    function validatePasswordForm() {
        const form = document.getElementById('passwordForm');
        let isValid = true;

        // Reset validation
        form.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });

        // Validate required fields
        const currentPassword = document.getElementById('currentPassword');
        const newPassword = document.getElementById('newPassword');
        const confirmPassword = document.getElementById('confirmPassword');

        if (!currentPassword.value) {
            currentPassword.classList.add('is-invalid');
            isValid = false;
        }

        if (!newPassword.value || newPassword.value.length < 8) {
            newPassword.classList.add('is-invalid');
            isValid = false;
        }

        if (newPassword.value !== confirmPassword.value) {
            confirmPassword.classList.add('is-invalid');
            isValid = false;
        }

        if (!isValid) {
            showNotification('Please check your password entries', false);
        }

        return isValid;
    }

    // Toggle notification
    document.getElementById('notificationToggle').addEventListener('click', function () {
        this.classList.toggle('bi-toggle-on');
        this.classList.toggle('bi-toggle-off');

        // You can also save this preference to the server if needed
        const isEnabled = this.classList.contains('bi-toggle-on');
        showNotification(`Notifications ${isEnabled ? 'enabled' : 'disabled'}!`);
    });

    // Initialize country and city selectors
    initializeLocationSelectors();

    // Initialize date of birth selectors
    initializeDateSelectors();

    // Load profile data
    loadProfileData();
});

// Initialize location selectors
function initializeLocationSelectors() {
    const countrySelect = document.getElementById('country');
    const citySelect = document.getElementById('city');

    // Sample country list - replace with actual API call if available
    const countries = [
        'Egypt', 'United States', 'United Kingdom'
    ];

    // Populate countries
    countrySelect.innerHTML = '<option value="">Select Country</option>';
    countries.sort().forEach(country => {
        const option = document.createElement('option');
        option.value = country;
        option.textContent = country;
        countrySelect.appendChild(option);
    });

    // Handle country change
    countrySelect.addEventListener('change', () => {
        const selectedCountry = countrySelect.value;
        if (selectedCountry) {
            loadCities(selectedCountry);
        } else {
            citySelect.innerHTML = '<option value="">Select City</option>';
            citySelect.disabled = true;
        }
    });
}

// Load cities based on country
function loadCities(country, selectedCity = null) {
    const citySelect = document.getElementById('city');
    citySelect.disabled = false;

    // Sample city lists - replace with actual API call if available
    const citiesByCountry = {
        'Egypt': ['Cairo', 'Alexandria', 'Giza', 'Sharm El Sheikh', 'Luxor', 'Aswan'],
        'United States': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
        'United Kingdom': ['London', 'Manchester', 'Birmingham', 'Liverpool', 'Glasgow'],
    };

    // Default cities for countries not in the list
    const defaultCities = ['Capital', 'Major City 1', 'Major City 2'];

    // Get cities for the selected country
    const cities = citiesByCountry[country] || defaultCities;

    // Populate cities
    citySelect.innerHTML = '<option value="">Select City</option>';
    cities.forEach(city => {
        const option = document.createElement('option');
        option.value = city;
        option.textContent = city;

        // Select city if it matches the previously selected city
        if (selectedCity && city === selectedCity) {
            option.selected = true;
        }

        citySelect.appendChild(option);
    });
}

// Initialize date selectors
function initializeDateSelectors() {
    const daySelect = document.getElementById('dob-day');
    const yearSelect = document.getElementById('dob-year');

    // Populate days
    daySelect.innerHTML = '<option value="">Day</option>';
    for (let i = 1; i <= 31; i++) {
        const option = document.createElement('option');
        option.value = i;
        option.textContent = i;
        daySelect.appendChild(option);
    }

    // Populate years (allow ages 18-100)
    const currentYear = new Date().getFullYear();
    yearSelect.innerHTML = '<option value="">Year</option>';
    for (let i = currentYear - 100; i <= currentYear - 18; i++) {
        const option = document.createElement('option');
        option.value = i;
        option.textContent = i;
        yearSelect.appendChild(option);
    }
}

// Function to fetch available bots from the API
function fetchAvailableBots() {
    // Show loading state
    const botContainer = document.getElementById('botContainer');
    botContainer.innerHTML = '<div class="text-center w-100 py-3"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>';

    // Fetch bots from the API
    fetch('https://gradationproject.runasp.net/api/BotUsers')
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            displayAvailableBots(data);
        })
        .catch(error => {
            console.error('Error fetching bots:', error);
            displayNoBots();
        });
}

// Function to display available bots in the bot container
function displayAvailableBots(bots) {
    const botContainer = document.getElementById('botContainer');
    botContainer.innerHTML = ''; // Clear loading state or previous content

    // Check if there are any bots available
    if (!bots || bots.length === 0) {
        displayNoBots();
        return;
    }

    // Create and append bot elements to the container
    bots.forEach(bot => {
        const botElement = document.createElement('div');
        botElement.className = 'd-flex flex-column align-items-center justify-content-center mx-2';
        botElement.style.cursor = 'pointer';

        // Use bot.image if available, otherwise use a default image path
        const imagePath = bot.image || `../images/bot (${Math.floor(Math.random() * 3) + 1}).png`;

        botElement.innerHTML = `
      <img src="${imagePath}" alt="${bot.name}" width="60px" class="rounded-circle mb-2">
      <p class="bot-name">${bot.name}</p>
    `;

        // Add click event to open chat with this bot
        botElement.addEventListener('click', function () {
            openBotChat(bot.name, imagePath);

            // Add a default message if it's a new chat
            if (!botChats[bot.name] || botChats[bot.name].length === 0) {
                // Pre-populate with conversation history
                simulateConversationHistory(bot.name);
            }
        });

        botContainer.appendChild(botElement);

        // Also add this bot to the messages section
        addBotToMessagesSection(bot.name, imagePath);
    });
}

// Function to display a message when no bots are available
function displayNoBots() {
    const botContainer = document.getElementById('botContainer');
    botContainer.innerHTML = `
    <div class="text-center w-100 py-3">
      <p class="text-muted">No bots available at the moment. Please try again later.</p>
    </div>
  `;
}
