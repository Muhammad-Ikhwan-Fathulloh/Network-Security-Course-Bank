# 🚀 Tutorial Lengkap: Daftar Sumopod & Install EasyPanel

## 🎯 Tujuan

Pada tutorial ini, Anda akan belajar:

* Mendaftar akun Sumopod
* Melakukan top up saldo
* Membuat VPS Ubuntu
* Menginstall EasyPanel
* Login ke Dashboard EasyPanel

Estimasi waktu: **15–20 menit**

---

# 1️⃣ Daftar Akun Sumopod

## Langkah 1: Buka Link Referral

Silakan daftar melalui link berikut:

👉 https://sumopod.com/register?ref=6c757670-bfaa-4513-8cf0-2eef74418e4e

## Langkah 2: Isi Form Registrasi

Lengkapi data berikut:

* Nama Lengkap
* Email Aktif
* Password
* Konfirmasi Password

Kemudian klik **Register**.

## Langkah 3: Verifikasi Email

1. Buka email yang digunakan saat registrasi.
2. Cari email dari Sumopod.
3. Klik tombol **Verify Email**.
4. Login ke dashboard Sumopod setelah verifikasi berhasil.

---

# 2️⃣ Tambahkan Saldo Akun

## Langkah 1: Masuk ke Menu Billing

Setelah login:

**Billing → Add Credit**

## Langkah 2: Top Up Saldo

Untuk kebutuhan workshop dan praktik EasyPanel, disarankan melakukan top up minimal:

![Step](/Sumopod/CreateVPS/create-vps%20(1).png)

![Step](/Sumopod/CreateVPS/create-vps%20(2).png)

![Step](/Sumopod/CreateVPS/create-vps%20(3).png)

✅ **Rp60.000**

Metode pembayaran yang tersedia:

* QRIS
* E-Wallet
* Transfer Bank

Tunggu hingga saldo masuk ke akun.

---

# 3️⃣ Membuat VPS

## Langkah 1: Buat VPS Baru

Masuk ke dashboard lalu klik:

**Create VPS** atau **Order VPS**

![Step](/Sumopod/CreateVPS/create-vps%20(4).png)

## Langkah 2: Pilih Paket VPS

Pilih provider **Tencent Cloud** dengan lokasi **Singapore**.

![Step](/Sumopod/CreateVPS/create-vps%20(5).png)

### Pilihan Paket Tencent Cloud

| CPU    | RAM  | Storage | Egress            | Harga      |
| ------ | ---- | ------- | ----------------- | ---------- |
| 2 vCPU | 2 GB | 40 GB   | 512 GB (20 Mbps)  | ⭐ Rp60.000 |
| 2 vCPU | 2 GB | 50 GB   | 1.02 TB (30 Mbps) | Rp75.000   |
| 2 vCPU | 4 GB | 60 GB   | 1.54 TB (30 Mbps) | Rp90.000   |
| 2 vCPU | 4 GB | 70 GB   | 2.05 TB (30 Mbps) | Rp125.000  |
| 2 vCPU | 8 GB | 80 GB   | 2.56 TB (30 Mbps) | Rp150.000  |
| 2 vCPU | 8 GB | 100 GB  | 3.07 TB (30 Mbps) | Rp185.000  |

![Step](/Sumopod/CreateVPS/create-vps%20(6).png)

### Paket yang Direkomendasikan

Untuk kebutuhan belajar dan workshop, pilih:

* Provider: Tencent Cloud
* CPU: 2 vCPU
* RAM: 2 GB
* Storage: 40 GB SSD
* Egress: 512 GB (20 Mbps)
* Harga: Rp60.000/bulan

Spesifikasi ini sudah cukup untuk:

* Install EasyPanel
* Deploy WordPress
* Deploy Laravel
* Deploy Node.js
* Menjalankan beberapa container Docker

## Langkah 3: Konfigurasi VPS

Gunakan pengaturan berikut:

| Pengaturan       | Nilai            |
| ---------------- | ---------------- |
| Operating System | Ubuntu 24.04 LTS |
| Region           | Singapore        |
| Hostname         | easypanel-course |

Kemudian klik:

**Create VPS**

Lalu pilih:

**I Agree, Create VPS**

---

# 4️⃣ Tunggu VPS Aktif

Proses provisioning VPS biasanya memerlukan waktu:

⏳ 5–15 menit

Status server akan berubah dari:

**Pending → Active**

![Step](/Sumopod/CreateVPS/create-vps%20(7).png)

---

# 5️⃣ Ambil Informasi VPS

Setelah VPS aktif, buka detail VPS dan catat informasi berikut:

* IP Address VPS
* Username: ubuntu
* Password VPS

Informasi ini akan digunakan untuk login SSH.

---

# 6️⃣ Login ke VPS Menggunakan SSH

## Opsi Termudah: SSH Melalui Browser

Buka:

https://ssheasy.com

Masukkan:

* Host/IP: IP VPS Anda
* Username: ubuntu
* Password: Password VPS

Klik:

**Connect**

Jika berhasil akan muncul tampilan:

```bash
ubuntu@vps:~$
```

![Step](/Sumopod/CreateVPS/create-vps%20(8).png)

---

# 7️⃣ Install EasyPanel

## Langkah 1: Masuk Sebagai Root

Jalankan:

```bash
sudo su
```

![Step](/Sumopod/CreateVPS/create-vps%20(9).png)

## Langkah 2: Install Docker

Jalankan:

```bash
apt-get update && apt-get install -y docker.io docker-compose
```

![Step](/Sumopod/CreateVPS/create-vps%20(10).png)

![Step](/Sumopod/CreateVPS/create-vps%20(11).png)

Tunggu hingga proses selesai.

## Langkah 3: Install EasyPanel

Jalankan:

```bash
curl -sSL https://get.easypanel.io | sh
```

![Step](/Sumopod/CreateVPS/create-vps%20(12).png)

Proses instalasi membutuhkan waktu sekitar 5–10 menit.

Tunggu hingga muncul pesan:

```text
Easypanel installed successfully
```

![Step](/Sumopod/CreateVPS/create-vps%20(13).png)

---

# 8️⃣ Akses Dashboard EasyPanel

Buka browser lalu akses:

```text
http://IP_VPS_ANDA:3000
```

Contoh:

```text
http://123.123.123.123:3000
```

Jika muncul halaman setup EasyPanel berarti instalasi berhasil.

---

# 9️⃣ Buat Akun Administrator EasyPanel

Pada halaman setup pertama kali, isi:

* Email
* Password
* Confirm Password

![Step](/Sumopod/CreateVPS/create-vps%20(14).png)

Pada bagian:

**How did you find Easypanel?**

Pilih:

**Google**

Kemudian klik:

**Setup**

---

# 🔟 Login ke Dashboard EasyPanel

Masukkan:

* Email yang dibuat sebelumnya
* Password EasyPanel

Klik:

**Login**

![Step](/Sumopod/CreateVPS/create-vps%20(15).png)

![Step](/Sumopod/CreateVPS/create-vps%20(16).png)