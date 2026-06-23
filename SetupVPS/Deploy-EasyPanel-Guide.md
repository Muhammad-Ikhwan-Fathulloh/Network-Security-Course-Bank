# 🚀 Panduan Deploy ke EasyPanel via Docker Image (Step-by-Step)

Panduan ini menjelaskan cara deploy aplikasi **Sistem Kasir** ke VPS menggunakan **EasyPanel** dengan metode **Docker Image** dari Docker Hub secara bertahap.

> [!NOTE]
> Pastikan VPS Anda sudah terinstall **EasyPanel** sebelum mengikuti panduan ini.
> Lihat [README.md](./README.md) untuk panduan instalasi EasyPanel.

---

## 📋 Daftar Isi

1. [Tahap 1 — Persiapan Docker Hub](#tahap-1--persiapan-docker-hub)
2. [Tahap 2 — Membuat Personal Access Token](#tahap-2--membuat-personal-access-token)
3. [Tahap 3 — Deploy Project 1 (Tanpa Proxy)](#tahap-3--deploy-project-1-tanpa-proxy)
4. [Tahap 4 — Deploy Project 2 (Dengan Proxy)](#tahap-4--deploy-project-2-dengan-proxy)
5. [Tahap 5 — Verifikasi Deployment](#tahap-5--verifikasi-deployment)

---

## Tahap 1 — Persiapan Docker Hub

### 1.1 Pastikan Image Sudah di Docker Hub

Sebelum deploy, pastikan Docker Image sudah di-push ke Docker Hub.

**Project 1 — Tanpa Proxy:**

![Docker Hub - project1-unified](../Sumopod/Deploy/Deploy%20(7).png)

> Image: `ikhwan17/project1-unified` dengan tag `latest`

**Project 2 — Dengan Proxy:**

![Docker Hub - project2-unified](../Sumopod/Deploy/Deploy%20(8).png)

> Image: `ikhwan17/project2-unified` dengan tag `latest`

### 1.2 Cara Push Image ke Docker Hub

Jika belum push, jalankan perintah berikut di lokal:

```bash
# Login ke Docker Hub
docker login -u <username_dockerhub>

# Build image (dari folder project)
docker build -t <username>/project1-unified .

# Push ke Docker Hub
docker push <username>/project1-unified
```

---

## Tahap 2 — Membuat Personal Access Token

Untuk menarik image dari Docker Hub (terutama private registry), Anda perlu **Personal Access Token**.

### 2.1 Buka Account Settings Docker Hub

Login ke [hub.docker.com](https://hub.docker.com), klik profil Anda di kanan atas, lalu pilih **Account settings**.

![Docker Hub - Account Settings](../Sumopod/Deploy/Deploy%20(9).png)

### 2.2 Navigasi ke Personal Access Tokens

Di sidebar kiri, klik **Personal access tokens**. Anda akan melihat daftar token yang sudah ada.

![Personal Access Tokens List](../Sumopod/Deploy/Deploy%20(10).png)

### 2.3 Generate Token Baru

Klik **Generate new token**, lalu isi:

| Field                        | Nilai                                                    |
| ---------------------------- | -------------------------------------------------------- |
| **Access token description** | `LearningNetworkSecurity` (atau nama deskriptif lainnya) |
| **Expiration date**          | `30 days` (atau sesuai kebutuhan)                        |
| **Access permissions**       | `Read & Write`                                           |

Klik **Generate**.

![Create Access Token](../Sumopod/Deploy/Deploy%20(11).png)

### 2.4 Salin Token

> [!CAUTION]
> Token hanya ditampilkan **SEKALI**. Pastikan Anda menyalinnya sekarang!

Salin token yang ditampilkan. Token ini akan digunakan sebagai **Password** saat konfigurasi Docker Image di EasyPanel.

![Copy Access Token](../Sumopod/Deploy/Deploy%20(12).png)

Informasi yang perlu dicatat:
- **Username**: `ikhwan17` (username Docker Hub Anda)
- **Password**: Token yang baru disalin (contoh: `dckr_pat_xxxxxxxxxxxx`)
- **Command login**: `docker login -u ikhwan17`

---

## Tahap 3 — Deploy Project 1 (Tanpa Proxy)

### 3.1 Buka Dashboard EasyPanel

Akses dashboard EasyPanel Anda melalui browser (contoh: `http://<IP_VPS>:3000`).

![EasyPanel Dashboard](../Sumopod/Deploy/Deploy%20(1).png)

> Dashboard menampilkan informasi CPU, Memory, Disk, dan Network dari VPS Anda.

### 3.2 Buat Project Baru

Klik **+ New** atau klik area **Create Project**, lalu isi:

| Field    | Nilai       |
| -------- | ----------- |
| **Name** | `project-1` |

Klik **Create**.

![Create Project - project-1](../Sumopod/Deploy/Deploy%20(2).png)

### 3.3 Halaman Project

Setelah project dibuat, Anda akan masuk ke halaman project dengan **Environment Variables** (biarkan kosong untuk saat ini).

![Project Page - Environment Variables](../Sumopod/Deploy/Deploy%20(3).png)

### 3.4 Tambahkan Service Baru

Klik **+ Service** di kanan atas. Pilih tab **Services**, lalu pilih tipe **App**.

![Add Service - Choose Type](../Sumopod/Deploy/Deploy%20(4).png)

> Tipe service yang tersedia: App, MySQL, MariaDB, Postgres, Mongo, Redis, Box, Compose, Wordpress

### 3.5 Beri Nama Service

Pada dialog **Create App Service**, isi:

| Field            | Nilai      |
| ---------------- | ---------- |
| **Service Name** | `sistem-1` |

Klik **Create**.

![Create App Service - sistem-1](../Sumopod/Deploy/Deploy%20(5).png)

### 3.6 Pilih Source: Docker Image

Setelah service dibuat, Anda akan diarahkan ke halaman **Source**. Pilih tab **Docker Image**.

![Source Page - Upload/Github/Docker Image](../Sumopod/Deploy/Deploy%20(6).png)

### 3.7 Konfigurasi Docker Image

Isi konfigurasi Docker Image:

| Field        | Nilai                                  |
| ------------ | -------------------------------------- |
| **Image**    | `ikhwan17/project1-unified`            |
| **Username** | `ikhwan17`                             |
| **Password** | *(Personal Access Token dari Tahap 2)* |

Klik **Save**.

![Docker Image Configuration](../Sumopod/Deploy/Deploy%20(13).png)

### 3.8 Proses Deploy

Setelah klik Save, EasyPanel akan mulai pull image dan menjalankan container. Anda bisa melihat progress di bagian **Logs**.

![Deploy Logs - Waiting](../Sumopod/Deploy/Deploy%20(14).png)

> Log menampilkan: `Waiting for service project-1_sistem-1 to start...`

### 3.9 Deploy Berhasil

Tunggu beberapa saat hingga muncul notifikasi **"App deployed"**.

![App Deployed Notification](../Sumopod/Deploy/Deploy%20(15).png)

> ✅ Notifikasi: *"App deployed - It may take a while for the new app to boot up"*

### 3.10 Service Berjalan

Setelah deploy berhasil, service akan berjalan dengan indikator **hijau** (●). Log menunjukkan Apache sudah aktif.

![Service Running - Apache Logs](../Sumopod/Deploy/Deploy%20(16).png)

> Log Apache: `Apache/2.4.67 (Debian) PHP/8.2.31 configured -- resuming normal operations`

### 3.11 Buka Aplikasi

Klik tombol **Open** (ikon panah keluar) di toolbar untuk membuka aplikasi di browser.

![Open Button - Klik untuk buka app](../Sumopod/Deploy/Deploy%20(17).png)

> URL: `https://project-1-sistem-1.bnv1ft.easypanel.host`

---

## Tahap 4 — Deploy Project 2 (Dengan Proxy)

### 4.1 Kembali ke Dashboard

Dari dashboard, klik **+ New** untuk membuat project baru.

### 4.2 Buat Project Baru

Isi nama project:

| Field    | Nilai       |
| -------- | ----------- |
| **Name** | `project-2` |

Klik **Create**.

![Create Project - project-2](../Sumopod/Deploy/Deploy%20(22).png)

> Terlihat project-1 sudah ada di dashboard sebelumnya.

### 4.3 Tambahkan Service dan Konfigurasi Docker Image

Ulangi langkah yang sama seperti Project 1:

1. Klik **+ Service** → Pilih **App**
2. Beri nama: `sistem-2`
3. Pilih tab **Docker Image**
4. Isi konfigurasi:

| Field        | Nilai                               |
| ------------ | ----------------------------------- |
| **Image**    | `ikhwan17/project2-unified`         |
| **Username** | `ikhwan17`                          |
| **Password** | *(Personal Access Token yang sama)* |

Klik **Save**.

![Docker Image - project2-unified](../Sumopod/Deploy/Deploy%20(23).png)

### 4.4 Pantau Proses Deploy

Perhatikan log deployment hingga container berjalan.

![Deploy Logs - project-2](../Sumopod/Deploy/Deploy%20(24).png)

> Log: Apache berhasil start — `Apache/2.4.67 (Debian) PHP/8.2.31 configured -- resuming normal operations`

---

## Tahap 5 — Verifikasi Deployment

### 5.1 Verifikasi Project 1

Buka URL Project 1 dan lakukan:

**a) Daftar Akun Baru (Tab Daftar)**

![Register - Sistem Kasir](../Sumopod/Deploy/Deploy%20(18).png)

| Field    | Contoh          |
| -------- | --------------- |
| Username | `test`          |
| Email    | `test@test.com` |
| Password | `********`      |

Klik **Daftar Kasir Baru**.

**b) Login dengan Akun yang Baru Dibuat**

![Login - Pendaftaran Sukses](../Sumopod/Deploy/Deploy%20(19).png)

> ✅ Notifikasi hijau: *"Pendaftaran sukses!"*

Login dengan username dan password yang sudah didaftarkan.

**c) Akses Dashboard POS**

![Dashboard POS - Terminal Penjualan](../Sumopod/Deploy/Deploy%20(20).png)

> Dashboard **Kasir Panel** menampilkan:
> - Terminal Penjualan
> - Keranjang Belanja
> - Menu: Kasir (POS), Inventori, Riwayat

### 5.2 Verifikasi Project 2

Buka URL Project 2 dan pastikan halaman login tampil.

![Login - Project 2](../Sumopod/Deploy/Deploy%20(25).png)

> URL: `https://project-2-sistem-2.bnv1ft.easypanel.host`

---

## 📊 Ringkasan Deploy

| Komponen         | Project 1                   | Project 2                   |
| ---------------- | --------------------------- | --------------------------- |
| **Nama Project** | `project-1`                 | `project-2`                 |
| **Nama Service** | `sistem-1`                  | `sistem-2`                  |
| **Docker Image** | `ikhwan17/project1-unified` | `ikhwan17/project2-unified` |
| **Tipe**         | Tanpa Proxy                 | Dengan Proxy                |
| **Status**       | ✅ Running                   | ✅ Running                   |

---

## 🔑 Catatan Keamanan

> [!WARNING]
> - Jangan simpan Personal Access Token di tempat publik
> - Gunakan token dengan expiration date yang wajar (30 hari)
> - Jika token bocor, segera revoke di Docker Hub → Personal access tokens
> - Untuk production, gunakan private Docker registry

---

## 📝 Troubleshooting

| Masalah                  | Solusi                                                                          |
| ------------------------ | ------------------------------------------------------------------------------- |
| Image tidak bisa di-pull | Pastikan Image name, Username, dan Password (token) benar                       |
| Service tidak start      | Cek Logs di EasyPanel untuk error detail                                        |
| Port bentrok             | Pastikan port tidak digunakan service lain                                      |
| Apache warning `AH00558` | Warning normal, bisa diabaikan (set `ServerName` directive jika ingin suppress) |
| App tidak bisa diakses   | Pastikan domain/subdomain sudah dikonfigurasi di tab Domains                    |