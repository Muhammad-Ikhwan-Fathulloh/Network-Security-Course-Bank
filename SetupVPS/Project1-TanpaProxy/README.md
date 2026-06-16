# Project 1: Tanpa Proxy

Proyek ini menunjukkan deploy aplikasi web dengan **frontend dan backend yang terekspos langsung** ke publik tanpa melalui reverse proxy.

## Arsitektur

```
User → Frontend (Port 8080)
User → Backend (Port 8000)
```

## Komponen

1. **Backend**: PHP Native (Apache) yang menyediakan API
2. **Frontend**: JavaScript Native (Nginx) yang menampilkan antarmuka web

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
   # Seharusnya melihat project1-backend dan project1-frontend
   ```

6. **Tambahkan ke EasyPanel (Opsional)**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Existing Service**
   - Pilih container `project1-backend` dan `project1-frontend`

---

### Cara B: Deploy via Dashboard EasyPanel

1. **Siapkan File Backend**
   - Compress folder `backend-php/` menjadi `backend.zip`

2. **Deploy Backend**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Upload Files**
   - Upload `backend.zip`
   - Konfigurasi:
     - **Name**: `project1-backend`
     - **Port**: `80`
     - **Publish Port**: `8000`
   - Klik **Create**
   - Tunggu sampai statusnya **Running**
   - Catat URL backend (contoh: `https://project1-backend.yourdomain.com`)

3. **Edit Konfigurasi Frontend**
   - Buka file `frontend-js/script.js`
   - Ubah `API_URL` menjadi URL backend Anda:
     ```javascript
     const API_URL = 'https://project1-backend.yourdomain.com';
     ```
     Atau jika menggunakan IP:
     ```javascript
     const API_URL = 'http://IP_VPS_ANDA:8000';
     ```

4. **Siapkan File Frontend**
   - Compress folder `frontend-js/` menjadi `frontend.zip`

5. **Deploy Frontend**
   - Klik **Create Project** lagi
   - Upload `frontend.zip`
   - Konfigurasi:
     - **Name**: `project1-frontend`
     - **Port**: `80`
     - **Publish Port**: `8080`
   - Klik **Create**

---

### Langkah Akhir: Akses Aplikasi

- Frontend: `https://project1-frontend.yourdomain.com` atau `http://IP_VPS:8080`
- Backend API: `https://project1-backend.yourdomain.com/api/products` atau `http://IP_VPS:8000/api/products`

---

## Perintah Berguna di VPS

```bash
# Melihat container yang berjalan
docker ps

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
- Frontend: `http://localhost:8080`
- Backend: `http://localhost:8000`

## Kelemahan Tanpa Proxy

1. Backend terekspos langsung ke publik (rentan terhadap serangan)
2. Tidak ada filtering request
3. Tidak ada rate limiting
4. Header server asli terlihat
