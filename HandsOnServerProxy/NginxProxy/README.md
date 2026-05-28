# Lab Keamanan: Nginx Reverse Proxy & WAF Dasar

Lab ini menyimulasikan penggunaan Nginx sebagai Reverse Proxy untuk memperkuat keamanan aplikasi backend (PHP). Lab ini menunjukkan perbandingan antara server yang terekspos langsung ke publik vs server yang berada di belakang proxy yang dikonfigurasi dengan benar.

## Komponen Lab

1.  **Backend Exposed (Port 5000)**: Aplikasi PHP yang terekspos langsung (Rentan).
2.  **Backend Protected**: Aplikasi PHP yang sama, namun hanya bisa diakses via Nginx Proxy.
3.  **Frontend JS**: Web interface untuk mencoba serangan secara visual.
4.  **Nginx Proxy (Port 8080)**: Gerbang utama dengan aturan keamanan (WAF Dasar).

## Fitur Keamanan yang Diuji

-   **Path Restriction**: Memblokir akses ke file konfigurasi (`/config`) dan file sensitif (`/sensitive.php`).
-   **WAF (Web Application Firewall)**: Memblokir query string yang mencurigakan (SQL Injection: `union`, `select`, dsb; XSS: `<script>`).
-   **Rate Limiting**: Membatasi jumlah request per detik untuk mencegah DDoS.
-   **Security Headers**: Menyembunyikan identitas backend server (`X-Powered-By`, `Server`).

## Daftar URL & Port

| Komponen           | URL / Port                   | Keterangan                               |
| :----------------- | :--------------------------- | :--------------------------------------- |
| **Dashboard Lab**  | `http://localhost:8080`      | Entry point utama (via Proxy)            |
| **Protected API**  | `http://localhost:8080/api/` | Jalur API yang dilindungi WAF            |
| **Direct Backend** | `http://localhost:5000`      | Akses langsung ke backend (Rentan)       |
| **Nginx Status**   | `Internal Only`              | Digunakan untuk monitoring (Stub Status) |


## Cara Menjalankan (Instalasi)

1.  Pastikan Anda memiliki **Docker** dan **Docker Compose** terinstal.
2.  Buka terminal di folder `NginxProxy`.
3.  Jalankan perintah berikut untuk membangun dan menjalankan semua container:
    ```bash
    docker-compose up -d --build
    ```
4.  Setelah semua container statusnya `Started`, buka browser dan akses Dashboard Lab di:
    `http://localhost:8080`

## Skenario Pengujian

### 1. Simulasi Serangan Otomatis (Cepat)
Anda dapat menjalankan script simulasi untuk melihat hasil proteksi secara cepat di terminal:
```bash
sh ./attack-scripts/simulate_attacks.sh
```

### 2. Manual Test via Browser
Gunakan antarmuka web di `http://localhost:8080` untuk mencoba tombol:
- **Direct Backend**: Melihat kerentanan langsung (SQLi berhasil, Config terekspos).
- **Nginx Proxy**: Melihat proteksi aktif (SQLi diblokir, Config forbidden).

### 1. Simulasi Serangan via Terminal (CMD / Bash)
Gunakan `curl` untuk melihat bagaimana Nginx memproses request di level HTTP.

**Langkah-langkah:**
1.  Buka Command Prompt (CMD) atau Terminal.
2.  **Tes Proteksi Path**:
    Coba akses file konfigurasi melalui proxy:
    ```bash
    curl -I http://localhost:8080/api/config
    ```
    *Analisis: Perhatikan status `HTTP/1.1 403 Forbidden`.*
3.  **Tes Proteksi SQL Injection**:
    Kirim payload SQLi sederhana:
    ```bash
    curl -I "http://localhost:8080/api/users?id=' OR 1=1"
    ```
    *Analisis: Perhatikan status `HTTP/1.1 400 Bad Request`. Nginx mendeteksi kata kunci `OR` dan `'`.*
4.  **Tes Perbandingan Header**:
    ```bash
    curl -I http://localhost:5000/api.php/users
    curl -I http://localhost:8080/api/users
    ```
    *Analisis: Bandingkan header `Server`. Versi asli (Apache/PHP) disembunyikan oleh Nginx.*

### 2. Simulasi Serangan Advanced (Kali Linux)
Gunakan tools penetrasi untuk menguji ketahanan Nginx terhadap serangan otomatis.

**Langkah-langkah:**
1.  Pastikan semua container sudah berjalan.
2.  Jalankan container Kali Linux di network yang sama:
    ```bash
    docker run --rm -it --network nginxproxy_public-net kalilinux/kali-rolling /bin/bash
    ```
3.  Di dalam container Kali, perbarui package list dan install `sqlmap`:
    ```bash
    apt update && apt install -y sqlmap
    ```
4.  Jalankan `sqlmap` ke arah Nginx Gateway:
    ```bash
    sqlmap -u "http://nginx-gateway/api/users?id=1" --batch --banner
    ```
5.  **Observasi**:
    -   Lihat output `sqlmap`. Apakah ia berhasil menemukan database?
    -   Lihat log Nginx secara bersamaan di terminal lain: `docker logs -f nginx-gateway`.
    -   *Kesimpulan: sqlmap akan gagal mengeksploitasi karena Nginx memutus koneksi saat mendeteksi pola scanning.*

### 3. Menggunakan Postman
1.  Buat request `GET` ke `http://localhost:8080/api/config`.
2.  Perhatikan tab **Headers** dan **Status** di Postman (Status harus `403 Forbidden`).
3.  Coba masukkan script XSS di parameter: `http://localhost:8080/api/users?name=<script>alert(1)</script>`.
4.  Interpretasikan hasilnya.


## Latihan Praktikum

Selesaikan tantangan berikut untuk memperdalam pemahaman Anda:

1.  **Tantangan 1 (Rate Limiting)**: Gunakan Postman Runner atau loop sederhana di terminal untuk mengirim 50 request dalam waktu singkat ke `http://localhost:8080/api/users`. Amati kapan Nginx mulai mengirimkan status `429 Too Many Requests`.
2.  **Tantangan 2 (WAF Custom Rule)**: Buka file `nginx-proxy/default.conf`. Tambahkan aturan untuk memblokir kata kunci `xss` atau `<script>`. Restart container (`docker-compose restart nginx-proxy`) dan uji apakah blokir berhasil.
3.  **Tantangan 3 (Leakage Investigation)**: Bandingkan header response antara `http://localhost:5000/api.php/users` dan `http://localhost:8080/api/users`. Identifikasi informasi apa saja yang berhasil disembunyikan oleh Nginx.
4.  **Tantangan 4 (Bypass Attempt)**: Cobalah mencari celah untuk mengakses file `sensitive.php` melalui proxy dengan berbagai variasi URL (misal: `/API/Sensitive.php`). Apakah Nginx tetap bisa memblokirnya? Kenapa?

## Monitoring Log

Untuk melihat bukti blokir oleh Nginx secara real-time, jalankan perintah berikut:
```bash
docker logs -f nginx-gateway
```


## Kesimpulan Lab

Nginx bukan hanya berfungsi sebagai pengimbang beban (load balancer), tetapi juga sebagai lapisan pertahanan pertama yang sangat efektif untuk memblokir serangan sebelum mencapai aplikasi backend yang berharga.

