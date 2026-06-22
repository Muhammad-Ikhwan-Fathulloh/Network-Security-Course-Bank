const API_URL = '';
let token = localStorage.getItem('auth_token');
let currentUser = JSON.parse(localStorage.getItem('current_user') || 'null');

let products = [];
let cart = [];
let categories = [];
let editingProductId = null;

/**
 * UI UTILITIES
 */
function showToast(text, type = 'success') {
    const toast = document.getElementById('message-toast');
    if (!toast) return;
    toast.textContent = text;
    toast.className = `toast-${type}`;
    toast.classList.remove('hidden');
    setTimeout(() => toast.classList.add('hidden'), 3000);
}

function formatIDR(num) {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(num);
}

/**
 * AUTH LOGIC
 */
function switchAuthTab(tab) {
    const loginForm = document.getElementById('login-form');
    const registerForm = document.getElementById('register-form');
    if (loginForm) loginForm.classList.toggle('hidden', tab !== 'login');
    if (registerForm) registerForm.classList.toggle('hidden', tab !== 'register');

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.textContent.toLowerCase().includes(tab));
    });
}

function logout() {
    localStorage.clear();
    location.reload();
}

/**
 * DASHBOARD ROUTING
 */
async function showDashboard(module) {
    ['pos', 'inventory', 'history'].forEach(m => {
        const el = document.getElementById(`${m}-module`);
        if (el) el.classList.toggle('hidden', m !== module);
    });
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.toggle('active', btn.textContent.toLowerCase().includes(module));
    });

    if (module === 'inventory') await fetchInventory();
    if (module === 'pos') await fetchProducts();
    if (module === 'history') await fetchHistory();
}

/**
 * API CALLS
 */
async function apiFetch(endpoint, options = {}) {
    try {
        const res = await fetch(`${API_URL}${endpoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
                'Authorization': token ? `Bearer ${token}` : ''
            }
        });

        const data = await res.json().catch(() => ({ success: false, message: 'Server Error' }));
        if (res.status === 401) { logout(); return null; }
        if (!res.ok) return { success: false, message: data.message || 'Gagal' };

        return data;
    } catch (e) {
        return { success: false, message: 'Koneksi gagal' };
    }
}

async function fetchProfile() {
    const data = await apiFetch('/api/profile');
    if (data && data.success) {
        currentUser = data.data;
        const display = document.getElementById('user-display');
        if (display) display.textContent = `Kasir: ${currentUser.username}`;
    } else {
        localStorage.removeItem('auth_token');
        location.reload();
    }
}

/**
 * INVENTORY & CATEGORY LOGIC
 */
async function fetchInventory() {
    const catData = await apiFetch('/api/categories');
    categories = catData?.data || [];
    renderCategoryList();

    const select = document.getElementById('prod-category');
    if (select) select.innerHTML = categories.map(c => `<option value="${c.id}">${c.name}</option>`).join('');

    const res = await apiFetch('/api/products');
    products = res?.data || [];
    renderInventory();
}

function renderCategoryList() {
    const list = document.getElementById('category-list');
    if (!list) return;
    list.innerHTML = categories.map(c => `
        <span style="background:#e2e8f0; padding:5px 12px; border-radius:20px; font-size:0.8rem; display:flex; align-items:center; gap:5px;">
            ${c.name}
            <button onclick="deleteCategory(${c.id})" style="border:none; background:none; cursor:pointer; color:var(--danger); font-weight:700;">×</button>
        </span>
    `).join('');
}

function toggleCategorySection() {
    const sec = document.getElementById('category-section');
    if (sec) sec.classList.toggle('hidden');
}

async function deleteCategory(id) {
    if (!confirm('Hapus kategori? Produk dengan kategori ini mungkin bermasalah.')) return;
    const res = await apiFetch(`/api/categories/${id}`, { method: 'DELETE' });
    if (res && res.success) { showToast('Kategori dihapus'); fetchInventory(); }
}

function renderInventory() {
    const tbody = document.getElementById('inventory-body');
    if (!tbody) return;
    tbody.innerHTML = products.map(p => `
        <tr>
            <td>${p.id}</td>
            <td>${p.name}</td>
            <td>${p.category_name || 'N/A'}</td>
            <td>${formatIDR(p.price)}</td>
            <td>${p.stock}</td>
            <td>
                <button class="btn btn-primary" style="padding:5px 10px; font-size:0.7rem;" onclick="editProduct(${p.id})">Edit</button>
                <button class="btn btn-danger" style="padding:5px 10px; font-size:0.7rem;" onclick="deleteProduct(${p.id})">Del</button>
            </td>
        </tr>
    `).join('');
}

function toggleProductForm() {
    editingProductId = null;
    const form = document.getElementById('product-form');
    if (form) form.reset();
    const container = document.getElementById('product-form-container');
    if (container) container.classList.toggle('hidden');
}

async function editProduct(id) {
    const p = products.find(x => x.id === id);
    if (!p) return;
    editingProductId = id;
    document.getElementById('prod-name').value = p.name;
    document.getElementById('prod-category').value = p.category_id;
    document.getElementById('prod-price').value = p.price;
    document.getElementById('prod-stock').value = p.stock;
    document.getElementById('product-form-container').classList.remove('hidden');
}

async function deleteProduct(id) {
    if (!confirm('Hapus produk?')) return;
    await apiFetch(`/api/products/${id}`, { method: 'DELETE' });
    fetchInventory();
}

/**
 * POS LOGIC
 */
async function fetchProducts() {
    const res = await apiFetch('/api/products');
    products = res?.data || [];
    renderPOSProducts();
}

function renderPOSProducts() {
    const grid = document.getElementById('pos-product-grid');
    if (!grid) return;
    grid.innerHTML = products.map(p => `
        <div class="product-card" onclick="addToCart(${p.id})">
            <h4>${p.name}</h4>
            <p style="color: var(--primary); font-weight:700;">${formatIDR(p.price)}</p>
            <p style="font-size: 0.7rem; color: grey;">Stok: ${p.stock}</p>
        </div>
    `).join('');
}

function addToCart(id) {
    const p = products.find(prod => prod.id === id);
    if (!p || p.stock <= 0) { showToast('Stok habis!', 'error'); return; }
    const existing = cart.find(item => item.id === id);
    if (existing) existing.quantity++;
    else cart.push({ ...p, quantity: 1 });
    renderCart();
}

function renderCart() {
    const container = document.getElementById('cart-items');
    if (!container) return;
    if (cart.length === 0) {
        container.innerHTML = '<p style="color: grey; text-align: center;">Kosong</p>';
        document.getElementById('cart-total').textContent = 'Rp 0';
        return;
    }
    container.innerHTML = cart.map(item => `
        <div style="display: flex; justify-content: space-between; margin-bottom: 15px; font-size: 0.8rem;">
            <span>${item.name} x ${item.quantity}</span>
            <span>${formatIDR(item.price * item.quantity)}</span>
        </div>
    `).join('');
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    document.getElementById('cart-total').textContent = formatIDR(total);
}

async function processCheckout() {
    if (cart.length === 0) return;
    const res = await apiFetch('/api/transactions', {
        method: 'POST',
        body: JSON.stringify({ items: cart, total: cart.reduce((s, i) => s + (i.price * i.quantity), 0), user_id: currentUser?.id })
    });
    if (res && res.success) {
        showToast('Transaksi Berhasil!');
        cart = []; renderCart(); fetchProducts();
    }
}

/**
 * HISTORY LOGIC
 */
async function fetchHistory() {
    const res = await apiFetch('/api/transactions');
    if (res && res.success) {
        const body = document.getElementById('history-body');
        if (body) body.innerHTML = res.data.map(tx => `
            <tr>
                <td>#${tx.id}</td>
                <td>${new Date(tx.created_at).toLocaleString('id-ID')}</td>
                <td>${formatIDR(tx.total)}</td>
            </tr>
        `).join('');
    }
}

/**
 * INITIALIZATION
 */
document.addEventListener('DOMContentLoaded', async () => {
    if (token) {
        document.getElementById('auth-section').classList.add('hidden');
        document.getElementById('dashboard-section').classList.remove('hidden');
        await fetchProfile();
        await showDashboard('pos');
    }

    // AUTH LISTENERS
    document.getElementById('login-form')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const res = await apiFetch('/api/login', {
            method: 'POST',
            body: JSON.stringify({ username: document.getElementById('login-username').value, password: document.getElementById('login-password').value })
        });
        if (res && res.success) {
            localStorage.setItem('auth_token', res.data.token);
            localStorage.setItem('current_user', JSON.stringify(res.data.user));
            location.reload();
        } else showToast('Gagal login', 'error');
    });

    document.getElementById('register-form')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const res = await apiFetch('/api/register', {
            method: 'POST',
            body: JSON.stringify({ username: document.getElementById('register-username').value, email: document.getElementById('register-email').value, password: document.getElementById('register-password').value })
        });
        if (res && res.success) { showToast('Pendaftaran sukses!'); switchAuthTab('login'); }
    });

    // INVENTORY LISTENERS
    document.getElementById('product-form')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const prod = {
            name: document.getElementById('prod-name').value,
            category_id: document.getElementById('prod-category').value,
            price: document.getElementById('prod-price').value,
            stock: document.getElementById('prod-stock').value
        };
        const method = editingProductId ? 'PUT' : 'POST';
        const url = editingProductId ? `/api/products/${editingProductId}` : `/api/products`;
        const res = await apiFetch(url, { method, body: JSON.stringify(prod) });
        if (res && res.success) { showToast('Barang disimpan'); toggleProductForm(); fetchInventory(); }
    });

    document.getElementById('category-form')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        const nameInput = document.getElementById('cat-name');
        const name = nameInput.value;
        const res = await apiFetch('/api/categories', { method: 'POST', body: JSON.stringify({ name }) });
        if (res && res.success) {
            showToast('Kategori ditambah');
            nameInput.value = '';
            fetchInventory();
        } else {
            showToast(res?.message || 'Gagal tambah kategori', 'error');
        }
    });

    // Search Logic
    document.getElementById('search-product')?.addEventListener('input', (e) => {
        const q = e.target.value.toLowerCase();
        const grid = document.getElementById('pos-product-grid');
        const filter = products.filter(p => p.name.toLowerCase().includes(q));
        grid.innerHTML = filter.map(p => `
            <div class="product-card" onclick="addToCart(${p.id})">
                <h4>${p.name}</h4>
                <p style="color: var(--primary); font-weight:700;">${formatIDR(p.price)}</p>
                <p style="font-size: 0.7rem; color: grey;">Stok: ${p.stock}</p>
            </div>
        `).join('');
    });
});
