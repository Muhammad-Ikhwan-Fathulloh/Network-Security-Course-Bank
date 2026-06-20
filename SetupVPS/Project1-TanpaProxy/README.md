# Project 1: Tanpa Proxy

Proyek ini menunjukkan deploy aplikasi web dengan **frontend dan backend yang terekspos langsung** ke publik tanpa melalui reverse proxy. Aplikasi memiliki fitur register, login, dan melihat profil user dengan autentikasi JWT dan database MySQL.

## Arsitektur

```
User → Frontend (Port 8081)
User → Backend (Port 8001)
       ↓
    MySQL Database (Port 3307)
```

## Komponen

1. **Backend**: PHP Native (Apache) yang menyediakan API autentikasi
2. **Frontend**: JavaScript Native (Nginx) yang menampilkan antarmuka login/register
3. **Database**: MySQL untuk menyimpan data user

## Cara Deploy ke VPS dengan EasyPanel

### Cara A: Deploy via SSH & Docker Compose (Termudah)

1. **Login SSH ke VPS**
   ```bash
   ssh ubuntu@IP_VPS_ANDA
   sudo su
   ```

2. **Buat Folder Project**
   ```bash
   mkdir -p ~/project1
   cd ~/project1
   ```

3. **Upload File ke VPS**
   - Upload semua file dari folder `Project1-TanpaProxy/` ke folder `~/project1` di VPS
   - Bisa menggunakan SCP, SFTP, atau clone repository Git

4. **Jalankan Docker Compose**
   ```bash
   docker-compose up -d --build
   ```

5. **Verifikasi Container Berjalan**
   ```bash
   docker ps
   # Seharusnya melihat project1-database, project1-backend, dan project1-frontend
   ```

6. **Tambahkan ke EasyPanel (Opsional)**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Existing Service**
   - Pilih container `project1-backend` dan `project1-frontend`

---

### Cara B: Deploy via Dashboard EasyPanel (Dengan Docker Compose)

1. **Siapkan File Project**
   - Compress seluruh folder `Project1-TanpaProxy/` menjadi `project1.zip`
   - Pastikan `docker-compose.yml` ada di root ZIP

2. **Deploy Project**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Upload Files**
   - Upload `project1.zip`
   - EasyPanel akan otomatis mendeteksi `docker-compose.yml`
   - Konfigurasi:
     - **Name**: `auth-app-tanpa-proxy`
   - Klik **Create**

3. **Tunggu Deploy Selesai**
   - EasyPanel akan build dan menjalankan semua container
   - Tunggu sampai statusnya **Running**

---

### Langkah Akhir: Akses Aplikasi

- Frontend: `https://auth-app-tanpa-proxy.yourdomain.com` atau `http://IP_VPS:8081`
- Backend API: `http://IP_VPS:8001`

---

## Perintah Berguna di VPS

```bash
# Melihat container yang berjalan
docker ps

# Melihat log database
docker logs project1-database

# Melihat log backend
docker logs project1-backend

# Melihat log frontend
docker logs project1-frontend

# Menghentikan semua container
docker-compose down

# Memulai kembali
docker-compose up -d
```

## Testing Lokal

Jika ingin testing di lokal sebelum deploy:

```bash
docker-compose up -d --build
```

Akses:
- Frontend: `http://localhost:8081`
- Backend: `http://localhost:8001`

## Kelemahan Tanpa Proxy

1. Backend terekspos langsung ke publik (rentan terhadap serangan)
2. Tidak ada filtering request
3. Tidak ada rate limiting
4. Header server asli terlihat
