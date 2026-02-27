# 📧 Pertemuan 10: Email Security

## Daftar Isi
1. [Pengantar Protokol Email](#1-pengantar-protokol-email)
2. [Anatomi Email Header](#2-anatomi-email-header)
3. [Kerentanan Email: SMTP Spoofing](#3-kerentanan-email-smtp-spoofing)
4. [Hands-On: Analisis Header Email (Hop-by-Hop)](#4-hands-on-analisis-header-email-hop-by-hop)
5. [Mekanisme Proteksi Modern: SPF, DKIM, DMARC](#5-mekanisme-proteksi-modern-spf-dkim-dmarc)
6. [Hands-On: Verifikasi Record Keamanan Email](#6-hands-on-verifikasi-record-keamanan-email)
7. [Deteksi dan Pencegahan Phishing](#7-deteksi-dan-pencegahan-phishing)
8. [Latihan Mandiri](#8-latihan-mandiri)

---

## 1. Pengantar Protokol Email

Sistem email bekerja menggunakan tiga protokol utama:
- **SMTP (Simple Mail Transfer Protocol)**: Mengirim email (Port 25/587).
- **POP3 (Post Office Protocol v3)**: Mengambil email dengan mengunduhnya (Port 110/995).
- **IMAP (Internet Message Access Protocol)**: Sinkronisasi email dengan server (Port 143/993).

SMTP awalnya tidak memiliki sistem autentikasi, yang menyebabkan maraknya **Email Spoofing**.

---

## 2. Anatomi Email Header

Header email berisi metadata tentang pengiriman email. Informasi penting di header:
- `From`: Alamat pengirim (bisa dipalsukan).
- `To`: Alamat penerima.
- `Subject`: Judul email.
- `Received`: Log perjalanan email dari satu server (MTA) ke MTA berikutnya.
- `Return-Path`: Ke mana email harus dikirim jika gagal.

---

## 3. Kerentanan Email: SMTP Spoofing

SMTP Spoofing terjadi ketika penyerang menggunakan server SMTP tanpa autentikasi untuk mengirim email seolah-olah berasal dari domain lain.

```bash
# Contoh simulasi manual via telnet (Old school)
telnet mail.target.com 25
HELO attacker.com
MAIL FROM: <ceo@target.com>
RCPT TO: <employee@target.com>
DATA
Subject: Segera Kirimkan Password Anda!

Mohon kirimkan kredensial Anda untuk verifikasi keamanan.
.
QUIT
```

---

## 4. Hands-On: Analisis Header Email (Hop-by-Hop)

### 4.1 Melihat Raw Header
Buka salah satu email di Gmail/Outlook Anda, pilih "Show Original" atau "View Message Source".

### 4.2 Lacak Pengirim Asli
Cari bagian `Received: from`.
```text
Received: from server-a.com (192.168.1.5) by server-b.com (192.168.1.10) ...
```
IP paling bawah/awal biasanya adalah komputer pengirim asli.

---

## 5. Mekanisme Proteksi Modern: SPF, DKIM, DMARC

### 5.1 SPF (Sender Policy Framework)
Daftar IP di DNS yang diperbolehkan mengirim email atas nama suatu domain.
`v=spf1 ip4:1.2.3.4 include:_spf.google.com ~all`

### 5.2 DKIM (DomainKeys Identified Mail)
Tanda tangan digital di header email untuk memastikan isi email tidak diubah.

### 5.3 DMARC (Domain-based Message Authentication, Reporting, and Conformance)
Instruksi ke server penerima tentang apa yang harus dilakukan jika SPF atau DKIM gagal (none, quarantine, atau reject).

---

## 6. Hands-On: Verifikasi Record Keamanan Email

Gunakan tool `dig` (di Kali) untuk memeriksa record keamanan sebuah domain besar (misal: google.com).

```bash
# Cek SPF
dig google.com TXT

# Cek DMARC
dig _dmarc.google.com TXT
```

---

## 7. Deteksi dan Pencegahan Phishing

**Phishing** adalah serangan sosial ekonomi yang sering menggunakan email sebagai medianya.

**Ciri-ciri Phishing:**
1. Alamat pengirim yang mencurigakan (typosquatting: `g00gle.com`).
2. Subject mendesak (Urgency).
3. Link yang diarahkan ke domain berbeda (Hover link untuk cek).
4. Lampiran yang mencurigakan (misal: `invoice.iso`, `document.exe`).

---

## 8. Latihan Mandiri

### Latihan 1: Email Header Analysis Tools
Gunakan tool online seperti [Google Admin Toolbox Messageheader](https://toolbox.googleapps.com/apps/messageheader/) untuk menganalisis email yang masuk ke spam box Anda.

### Latihan 2: Identifikasi SPF Fail
Cari domain yang memiliki record SPF `-all` (Fail) dan `~all` (Softfail). Diskusikan perbedaannya dalam hal keamanan.
