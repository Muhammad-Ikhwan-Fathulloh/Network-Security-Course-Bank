# Halimun-Proxy: Encrypted Reverse Proxy Simulation

Lab ini mendemonstrasikan penggunaan **Halimun-Proxy**, sebuah reverse proxy terenkripsi yang melindungi backend dari berbagai serangan network-layer dan application-layer.

## Fitur Utama
1.  **End-to-End Encryption**: Payload dienkripsi menggunakan AES-256-CBC dari client (frontend) hingga proxy.
2.  **Replay Protection**: Setiap request divalidasi menggunakan Nonce dan Timestamp untuk mencegah serangan replay.
3.  **Camouflage Routing**: URL yang terlihat di network diubah menjadi random segments yang tidak menunjukkan struktur backend asli.
4.  **SSRF Protection**: Proxy memblokir request yang mencoba mengakses internal network IP (localhost, private subnets).
5.  **Basic Authentication**: Lapisan keamanan tambahan di Nginx sebelum mencapai proxy.

## Persiapan
Pastikan Docker dan Docker Compose sudah terinstal di sistem Anda.

## Cara Menjalankan
1.  **Start Services**:
    Buka terminal di folder `HalimunProxy` dan jalankan:
    ```bash
    docker-compose up -d --build
    ```

2.  **Verifikasi Container**:
    Pastikan semua container berjalan:
    ```bash
    docker ps
    ```
    Anda harus melihat: `php-backend-protected`, `php-backend-exposed`, `js-frontend`, `halimun-proxy`, dan `nginx-gateway`.

3.  **Akses Dashboard**:
    - Buka browser ke `http://localhost:8080`.
    - Gunakan kredensial berikut jika diminta (Nginx Basic Auth):
        - **Username**: `admin`
        - **Password**: `admin`

## Simulasi Serangan
Anda dapat menjalankan script simulasi untuk melihat perbedaan antara backend yang terekspos langsung dan backend yang dilindungi Halimun-Proxy.

1.  Berikan izin eksekusi pada script:
    ```bash
    chmod +x attack-scripts/attack.sh
    ```

2.  Jalankan simulasi:
    ```bash
    ./attack-scripts/attack.sh
    ```

## Komponen Lab
- `backend-php/`: PHP backend terproteksi (hanya dalam network internal).
- `frontend-js/`: Frontend statis yang menggunakan `halimun-crypto.js` untuk enkripsi.
- `nginx/`: Nginx gateway dengan rate limiting dan basic auth.
- `config.yaml`: Konfigurasi routing dan enkripsi Halimun-Proxy.
