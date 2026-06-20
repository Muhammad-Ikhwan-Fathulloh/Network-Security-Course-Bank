const API_URL = 'http://localhost:8001';

let token = localStorage.getItem('auth_token');
let currentUser = JSON.parse(localStorage.getItem('current_user') || 'null');

function showMessage(elementId, text, type) {
    const el = document.getElementById(elementId);
    el.className = type;
    el.textContent = text;
    el.style.display = 'block';
    setTimeout(() => {
        el.style.display = 'none';
    }, 3000);
}

function switchTab(tabName) {
    const tabs = document.querySelectorAll('.tab');
    tabs.forEach(tab => {
        tab.classList.toggle('active', tab.dataset.tab === tabName);
    });
    document.getElementById('login-form').classList.toggle('hidden', tabName !== 'login');
    document.getElementById('register-form').classList.toggle('hidden', tabName !== 'register');
}

function showAuthSection() {
    document.getElementById('auth-section').classList.remove('hidden');
    document.getElementById('profile-section').classList.add('hidden');
}

async function showProfileSection() {
    document.getElementById('auth-section').classList.add('hidden');
    document.getElementById('profile-section').classList.remove('hidden');
    document.getElementById('loading-profile').style.display = 'block';
    document.getElementById('profile-info').classList.add('hidden');

    try {
        const response = await fetch(`${API_URL}/api/profile`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const data = await response.json();

        if (data.success) {
            const user = data.data;
            document.getElementById('profile-info').innerHTML = `
                <p><strong>ID:</strong> ${user.id}</p>
                <p><strong>Username:</strong> ${user.username}</p>
                <p><strong>Email:</strong> ${user.email}</p>
                <p><strong>Dibuat Pada:</strong> ${new Date(user.created_at).toLocaleString('id-ID')}</p>
            `;
            document.getElementById('loading-profile').style.display = 'none';
            document.getElementById('profile-info').classList.remove('hidden');
        } else {
            logout();
        }
    } catch (error) {
        logout();
    }
}

function logout() {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('current_user');
    token = null;
    currentUser = null;
    showAuthSection();
}

document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.tab').forEach(tab => {
        tab.addEventListener('click', () => switchTab(tab.dataset.tab));
    });

    document.getElementById('login-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const username = document.getElementById('login-username').value;
        const password = document.getElementById('login-password').value;

        try {
            const response = await fetch(`${API_URL}/api/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username, password })
            });
            const data = await response.json();

            if (data.success) {
                token = data.data.token;
                currentUser = data.data.user;
                localStorage.setItem('auth_token', token);
                localStorage.setItem('current_user', JSON.stringify(currentUser));
                showMessage('message', 'Login berhasil!', 'success');
                setTimeout(showProfileSection, 1000);
            } else {
                showMessage('message', data.message, 'error');
            }
        } catch (error) {
            showMessage('message', 'Gagal terhubung ke server', 'error');
        }
    });

    document.getElementById('register-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const username = document.getElementById('register-username').value;
        const email = document.getElementById('register-email').value;
        const password = document.getElementById('register-password').value;

        try {
            const response = await fetch(`${API_URL}/api/register`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username, email, password })
            });
            const data = await response.json();

            if (data.success) {
                showMessage('message', 'Registrasi berhasil! Silakan login.', 'success');
                switchTab('login');
            } else {
                showMessage('message', data.message, 'error');
            }
        } catch (error) {
            showMessage('message', 'Gagal terhubung ke server', 'error');
        }
    });

    document.getElementById('logout-btn').addEventListener('click', logout);

    if (token && currentUser) {
        showProfileSection();
    }
});

