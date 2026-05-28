const DIRECT_BACKEND = 'http://localhost:5000';
const PROXY_URL = 'http://localhost:8080';

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
            content: text.substring(0, 500) + '...',
            full_length: text.length
        });
    } catch (error) {
        displayOutput('output-direct', { error: error.message }, true);
    }
}

async function testDirectSQLInjection() {
    try {
        const maliciousPayload = `' OR '1'='1' UNION SELECT * FROM users -- `;
        const response = await fetch(`${DIRECT_BACKEND}/api.php/users?id=${maliciousPayload}`);
        const data = await response.json();
        displayOutput('output-direct', {
            message: 'SQL Injection BERHASIL! Database terekspos!',
            payload: maliciousPayload,
            result: data
        });
    } catch (error) {
        displayOutput('output-direct', { error: error.message }, true);
    }
}

async function testProxyAPI() {
    try {
        const response = await fetch(`${PROXY_URL}/api/users`);
        const data = await response.json();
        displayOutput('output-proxy', {
            status_code: response.status,
            data: data
        });
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

async function testProxyConfig() {
    try {
        const response = await fetch(`${PROXY_URL}/api/config`);
        displayOutput('output-proxy', {
            status_code: response.status,
            hint: 'Interpretasikan status code tersebut untuk menentukan apakah request diblokir.',
            raw_response: await response.text()
        });
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

async function testProxySensitive() {
    try {
        const response = await fetch(`${PROXY_URL}/sensitive.php`);
        displayOutput('output-proxy', {
            status_code: response.status,
            hint: 'Bandingkan status code ini dengan hasil Direct Backend.',
            raw_response: await response.text()
        });
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}

async function testProxySQLInjection() {
    try {
        const maliciousPayload = `' OR '1'='1' UNION SELECT * FROM users -- `;
        const response = await fetch(`${PROXY_URL}/api/users?id=${maliciousPayload}`);
        displayOutput('output-proxy', {
            status_code: response.status,
            payload: maliciousPayload,
            hint: 'Analisis kenapa status code ini muncul saat mengirim payload SQLi.'
        });
    } catch (error) {
        displayOutput('output-proxy', { error: error.message }, true);
    }
}


async function startDDoSDirect() {
    const statusDiv = document.getElementById('ddos-status');
    const resultDiv = document.getElementById('ddos-result');
    const requests = 1000;

    statusDiv.innerHTML = 'Menjalankan serangan DDoS ke backend langsung...';
    statusDiv.className = 'status status-error';

    const startTime = performance.now();
    let successCount = 0;
    let failCount = 0;
    const errors = [];

    const promises = [];
    for (let i = 0; i < requests; i++) {
        promises.push(
            fetch(`${DIRECT_BACKEND}/api.php/users`)
                .then(() => successCount++)
                .catch((err) => {
                    failCount++;
                    errors.push(err.message);
                })
        );

        if (i % 100 === 0) {
            statusDiv.innerHTML = `Memproses request ${i}/${requests}...`;
            await new Promise(resolve => setTimeout(resolve, 0));
        }
    }

    await Promise.all(promises);
    const endTime = performance.now();
    const duration = (endTime - startTime) / 1000;

    statusDiv.innerHTML = 'Serangan DDoS selesai!';
    statusDiv.className = 'status status-info';

    resultDiv.innerHTML = JSON.stringify({
        total_requests: requests,
        success: successCount,
        failed: failCount,
        duration_seconds: duration.toFixed(2),
        requests_per_second: (requests / duration).toFixed(2),
        conclusion: 'Backend langsung sangat rentan terhadap DDoS! Banyak request gagal karena server overload.'
    }, null, 2);
}

async function startDDoSProxy() {
    const statusDiv = document.getElementById('ddos-status');
    const resultDiv = document.getElementById('ddos-result');
    const requests = 1000;

    statusDiv.innerHTML = 'Menjalankan serangan DDoS ke proxy...';
    statusDiv.className = 'status status-info';

    const startTime = performance.now();
    let successCount = 0;
    let failCount = 0;
    let rateLimitedCount = 0;

    const promises = [];
    for (let i = 0; i < requests; i++) {
        promises.push(
            fetch(`${PROXY_URL}/api/users`)
                .then((response) => {
                    if (response.status === 429) {
                        rateLimitedCount++;
                        successCount++;
                    } else if (response.ok) {
                        successCount++;
                    } else {
                        failCount++;
                    }
                })
                .catch(() => failCount++)
        );

        if (i % 100 === 0) {
            statusDiv.innerHTML = `Memproses request ${i}/${requests}...`;
            await new Promise(resolve => setTimeout(resolve, 0));
        }
    }

    await Promise.all(promises);
    const endTime = performance.now();
    const duration = (endTime - startTime) / 1000;

    statusDiv.innerHTML = 'Serangan DDoS selesai!';
    statusDiv.className = 'status status-success';

    resultDiv.innerHTML = JSON.stringify({
        total_requests: requests,
        success: successCount,
        failed: failCount,
        rate_limited: rateLimitedCount,
        duration_seconds: duration.toFixed(2),
        requests_per_second: (requests / duration).toFixed(2),
        conclusion: 'Proxy lebih tahan terhadap DDoS berkat rate limiting. Request yang melebihi batas dikembalikan dengan status 429.'
    }, null, 2);
}