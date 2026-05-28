const DIRECT_BACKEND = 'http://localhost:5000';
const HALIMUN_PROXY = 'http://localhost:8080';

let halimunCrypto = null;

async function initCrypto() {
    const keyHex = '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';
    const ivHex = '000102030405060708090a0b0c0d0e0f';
    halimunCrypto = new HalimunCrypto(keyHex, ivHex);
}

function displayOutput(elementId, data, isError = false) {
    const element = document.getElementById(elementId);
    const timestamp = new Date().toLocaleTimeString('id-ID');
    const prefix = isError ? 'ERROR' : 'SUCCESS';
    element.innerHTML = `[${timestamp}] ${prefix}:\n${JSON.stringify(data, null, 2)}`;
}

async function testDirectAPI() {
    try {
        const response = await fetch(`${DIRECT_BACKEND}/api.php/users`);
        const data = await response.json();
        displayOutput('output-direct', data);
    } catch (error) {
        displayOutput('output-direct', { error: error.message }, true);
    }
}

async function testDirectConfig() {
    try {
        const response = await fetch(`${DIRECT_BACKEND}/api.php/config`);
        const data = await response.json();
        displayOutput('output-direct', {
            message: 'Data konfigurasi sensitif terekspos!',
            data: data
        });
    } catch (error) {
        displayOutput('output-direct', { error: error.message }, true);
    }
}

async function testDirectSensitive() {
    try {
        const response = await fetch(`${DIRECT_BACKEND}/sensitive.php`);
        const text = await response.text();
        displayOutput('output-direct', {
            message: 'File sensitif dapat diakses!',
            content: text.substring(0, 500) + '...'
        });
    } catch (error) {
        displayOutput('output-direct', { error: error.message }, true);
    }
}

async function testProxyAPI() {
    try {
        if (!halimunCrypto) await initCrypto();

        const encryptedRequest = await halimunCrypto.createEncryptedRequest(
            'http://backend-php:80/api.php/users',
            'GET',
            { 'Content-Type': 'application/json' }
        );

        const response = await fetch(`${HALIMUN_PROXY}${encryptedRequest.url}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: encryptedRequest.body
        });

        const data = await response.json();
        displayOutput('output-proxy', {
            message: 'Request berhasil melalui Halimun-Proxy terenkripsi!',
            data: data,
            nonce_used: encryptedRequest.nonce
        });
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

async function testProxyConfig() {
    try {
        if (!halimunCrypto) await initCrypto();

        const encryptedRequest = await halimunCrypto.createEncryptedRequest(
            'http://backend-php:80/api.php/config',
            'GET',
            { 'Content-Type': 'application/json' }
        );

        const response = await fetch(`${HALIMUN_PROXY}${encryptedRequest.url}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: encryptedRequest.body
        });

        if (response.status === 403 || response.status === 404) {
            displayOutput('output-proxy', {
                status: 'DIBLOKIR',
                message: 'Halimun-Proxy memblokir akses ke konfigurasi!',
                http_code: response.status
            });
        } else {
            const data = await response.json();
            displayOutput('output-proxy', {
                warning: 'Akses konfigurasi berhasil!',
                data: data
            });
        }
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

async function testProxySensitive() {
    try {
        if (!halimunCrypto) await initCrypto();

        const encryptedRequest = await halimunCrypto.createEncryptedRequest(
            'http://backend-php:80/sensitive.php',
            'GET',
            { 'Content-Type': 'text/html' }
        );

        const response = await fetch(`${HALIMUN_PROXY}${encryptedRequest.url}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: encryptedRequest.body
        });

        if (response.status === 403 || response.status === 404) {
            displayOutput('output-proxy', {
                status: 'DIBLOKIR',
                message: 'Halimun-Proxy memblokir akses ke file sensitif!',
                http_code: response.status
            });
        } else {
            const text = await response.text();
            displayOutput('output-proxy', {
                warning: 'File sensitif masih bisa diakses!',
                content: text.substring(0, 300)
            });
        }
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

async function testReplayAttack() {
    try {
        if (!halimunCrypto) await initCrypto();

        const encryptedRequest = await halimunCrypto.createEncryptedRequest(
            'http://backend-php:80/api.php/users',
            'GET',
            { 'Content-Type': 'application/json' }
        );

        const response1 = await fetch(`${HALIMUN_PROXY}${encryptedRequest.url}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: encryptedRequest.body
        });

        const response2 = await fetch(`${HALIMUN_PROXY}${encryptedRequest.url}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: encryptedRequest.body
        });

        displayOutput('output-proxy', {
            first_request_status: response1.status,
            second_request_status: response2.status,
            replay_protection: response2.status === 403 ? 'AKTIF - Request kedua ditolak!' : 'TIDAK AKTIF'
        });
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

window.onload = () => {
    initCrypto();
    console.log('Halimun Crypto initialized');
};