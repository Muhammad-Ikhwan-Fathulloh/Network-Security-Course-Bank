const API_URL = '';

async function fetchProducts() {
    try {
        const response = await fetch(`${API_URL}/api/products`);
        const data = await response.json();
        
        if (data.success) {
            displayProducts(data.data);
        } else {
            showError(data.message);
        }
    } catch (error) {
        showError('Gagal terhubung ke server: ' + error.message);
    }
}

async function fetchServerInfo() {
    try {
        const response = await fetch(`${API_URL}/api/info`);
        const data = await response.json();
        
        if (data.success) {
            document.getElementById('server-type').textContent = data.data.server;
            document.getElementById('server-mode').textContent = data.data.mode;
            document.getElementById('server-time').textContent = data.data.time;
            document.getElementById('x-forwarded-for').textContent = data.data.proxy_headers['X-Forwarded-For'];
            document.getElementById('server-info').style.display = 'block';
        }
    } catch (error) {
        console.error('Gagal mengambil info server:', error);
    }
}

function displayProducts(products) {
    const container = document.getElementById('products');
    const loading = document.getElementById('loading');
    
    loading.style.display = 'none';
    
    products.forEach(product => {
        const card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML = `
            <div class="product-name">${product.name}</div>
            <div class="product-price">Rp ${product.price.toLocaleString('id-ID')}</div>
        `;
        container.appendChild(card);
    });
}

function showError(message) {
    const loading = document.getElementById('loading');
    const error = document.getElementById('error');
    
    loading.style.display = 'none';
    error.style.display = 'block';
    error.textContent = message;
}

document.addEventListener('DOMContentLoaded', () => {
    fetchProducts();
    fetchServerInfo();
});
