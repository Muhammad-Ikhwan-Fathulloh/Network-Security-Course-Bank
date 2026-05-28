class HalimunCrypto {
    constructor(keyHex, ivHex) {
        this.keyHex = keyHex;
        this.ivHex = ivHex;
    }

    async encryptPayload(payload) {
        const encoder = new TextEncoder();

        const keyBuffer = this.hexToBuffer(this.keyHex);
        const ivBuffer = this.hexToBuffer(this.ivHex);

        const cryptoKey = await crypto.subtle.importKey(
            'raw',
            keyBuffer,
            { name: 'AES-CBC' },
            false,
            ['encrypt']
        );

        const encodedPayload = encoder.encode(JSON.stringify(payload));

        const encrypted = await crypto.subtle.encrypt(
            { name: 'AES-CBC', iv: ivBuffer },
            cryptoKey,
            encodedPayload
        );

        return this.bufferToBase32(new Uint8Array(encrypted));
    }

    hexToBuffer(hex) {
        const bytes = new Uint8Array(hex.length / 2);
        for (let i = 0; i < hex.length; i += 2) {
            bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
        }
        return bytes;
    }

    bufferToBase32(buffer) {
        const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        let result = '';
        let bits = 0;
        let value = 0;

        for (let i = 0; i < buffer.length; i++) {
            value = (value << 8) | buffer[i];
            bits += 8;

            while (bits >= 5) {
                result += base32Chars[(value >> (bits - 5)) & 31];
                bits -= 5;
            }
        }

        if (bits > 0) {
            result += base32Chars[(value << (5 - bits)) & 31];
        }

        return result;
    }

    generateNonce() {
        return crypto.randomUUID();
    }

    generateTimestamp() {
        return Math.floor(Date.now() / 1000);
    }

    async createEncryptedRequest(apiUrl, method, headers, body = null) {
        const nonce = this.generateNonce();
        const timestamp = this.generateTimestamp();

        const payload = {
            api_url: apiUrl,
            api_header: headers,
            method: method,
            timestamp: timestamp,
            expired: 300,
            offset: '+00:00',
            nonce: nonce,
            body: body
        };

        const encrypted = await this.encryptPayload(payload);

        const segments = this.generateCamouflageSegments();

        return {
            url: `/proxy/1/${segments.join('/')}`,
            body: `x=${encrypted}`,
            nonce: nonce
        };
    }

    generateCamouflageSegments() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        const segments = [];
        for (let i = 0; i < 5; i++) {
            let segment = '';
            for (let j = 0; j < 8; j++) {
                segment += chars[Math.floor(Math.random() * chars.length)];
            }
            segments.push(segment);
        }
        return segments;
    }
}