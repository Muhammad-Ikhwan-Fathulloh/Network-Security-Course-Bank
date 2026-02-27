# 🛡️ Pertemuan 14: System Hardening

## Daftar Isi
1. [Prinsip Dasar System Hardening](#1-prinsip-dasar-system-hardening)
2. [Manajemen Akun & Hak Akses (Least Privilege)](#2-manajemen-akun--hak-akses-least-privilege)
3. [Hardening Layanan Jaringan (SSH & Ports)](#3-hardening-layanan-jaringan-ssh--ports)
4. [Update & Patch Management](#4-update--patch-management)
5. [Hands-On: Mengaudit Keamanan dengan Lynis](#5-hands-on-mengaudit-keamanan-dengan-lynis)
6. [Hands-On: Mengamankan SSH Configuration](#6-hands-on-mengamankan-ssh-configuration)
7. [Backup & Incident Response Plan](#7-backup--incident-response-plan)
8. [Latihan Mandiri](#8-latihan-mandiri)

---

## 1. Prinsip Dasar System Hardening

**System Hardening** adalah proses mengamankan sistem dengan mengurangi **Attack Surface** (permukaan serangan). Semakin sedikit layanan dan akses yang terbuka, semakin sulit bagi penyerang untuk meretas sistem.

**Filosofi Utama:**
- Jika tidak butuh, hapus.
- Jika tidak pakai, matikan.
- Jika harus pakai, amankan.

---

## 2. Manajemen Akun & Hak Akses (Least Privilege)

**Principle of Least Privilege (PoLP)** menyatakan bahwa pengguna atau sistem hanya boleh memiliki hak akses minimal yang diperlukan untuk menjalankan fungsinya.

**Langkah Hardening Akun:**
- Hapus akun user yang tidak aktif.
- Gunakan `sudo` daripada login langsung sebagai `root`.
- Terapkan kebijakan password yang kuat (panjang, kompleks, rotasi).
- Batasi percobaan login (Lockout policy).

---

## 3. Hardening Layanan Jaringan (SSH & Ports)

### 3.1 Identifikasi Port Terbuka
Langkah pertama hardening adalah mengetahui apa yang berjalan di sistem Anda.
```bash
ss -tulpn
# atau
netstat -tulpn
```

### 3.2 Matikan Layanan Tidak Perlu
Misalnya jika Anda tidak membutuhkan web server:
```bash
systemctl stop apache2
systemctl disable apache2
```

---

## 4. Update & Patch Management

Software yang mengandung celah keamanan (CVE) harus segera diperbarui.

```bash
# Update repository
apt update

# Install patch keamanan saja (di Debian/Ubuntu)
apt upgrade --with-new-pkgs
```

---

## 5. Hands-On: Mengaudit Keamanan dengan Lynis

**Lynis** adalah tool audit keamanan open-source untuk sistem berbasis Linux/Unix.

```bash
# 1. Install Lynis
apt install -y lynis

# 2. Jalankan audit sistem secara menyeluruh
lynis audit system
```

Lynis akan memberikan **Security Index** dan daftar **Suggestions** (saran) untuk meningkatkan keamanan sistem Anda.

---

## 6. Hands-On: Mengamankan SSH Configuration

File konfigurasi SSH berada di `/etc/ssh/sshd_config`.

**Perubahan yang direkomendasikan:**
1. **Ganti Port Standar**: Ubah `Port 22` menjadi port lain (misal: `Port 2222`).
2. **Disable Root Login**: Set `PermitRootLogin no`.
3. **Gunakan SSH Key**: Set `PasswordAuthentication no`.
4. **Batasi User**: Tambahkan `AllowUsers namauser`.

```bash
# Restart SSH setelah perubahan
systemctl restart ssh
```

---

## 7. Backup & Incident Response Plan

Hardening tidak menjamin 100% aman. Anda butuh rencana cadangan:
- **Backup Rutin**: Simpan backup di lokasi terpisah (Off-site backup).
- **Log Management**: Kirim log ke server pusat (SIEM) agar tidak bisa dihapus penyerang.

---

## 8. Latihan Mandiri

### Latihan 1: Analisis Suggestion Lynis
Jalankan Lynis, pilih 3 saran (suggestions) yang diberikan, dan coba terapkan pada sistem Anda. Verifikasi dengan menjalankan Lynis kembali.

### Latihan 2: Implementasi Fail2Ban
Pelajari dan install `fail2ban` untuk secara otomatis memblokir IP yang melakukan percobaan brute force pada layanan SSH atau Web.
