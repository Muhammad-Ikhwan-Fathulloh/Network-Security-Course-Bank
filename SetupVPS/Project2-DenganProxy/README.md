# Project 2: Dengan Nginx Proxy

Proyek ini menunjukkan deploy aplikasi web dengan **Nginx sebagai reverse proxy** di depan frontend dan backend. Aplikasi memiliki fitur register, login, dan melihat profil user dengan autentikasi JWT dan database MySQL. Backend tidak terekspos langsung ke publik.

## Arsitektur

```
User → Nginx Proxy (Port 80) → Frontend / Backend
                                    ↓
                              MySQL Database
```

## Komponen

1. **Nginx Proxy**: Gerbang utama yang menangani semua request
2. **Backend**: PHP Native (Apache) - hanya bisa diakses via proxy
3. **Frontend**: JavaScript Native (Nginx) - hanya bisa diakses via proxy
4. **Database**: MySQL untuk menyimpan data user

## Cara Deploy ke VPS dengan EasyPanel

### Cara A: Deploy via SSH & Docker Compose (TERMUDAH & REKOMENDASI)

1. **Login SSH ke VPS**
   ```bash
   ssh ubuntu@IP_VPS_ANDA
   sudo su
   ```

2. **Buat Folder Project**
   ```bash
   mkdir -p ~/project2
   cd ~/project2
   ```

3. **Upload File ke VPS**
   - Upload semua file dari folder `Project2-DenganProxy/` ke folder `~/project2` di VPS
   - Bisa menggunakan SCP, SFTP, atau clone repository Git

4. **Jalankan Docker Compose**
   ```bash
   docker-compose up -d --build
   ```

5. **Verifikasi Container Berjalan**
   ```bash
   docker ps
   # Seharusnya melihat project2-database, project2-nginx, project2-backend, project2-frontend
   ```

6. **Tambahkan ke EasyPanel (Opsional)**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Existing Service**
   - Pilih container `project2-nginx` (ini yang akan diakses publik)

---

### Cara B: Deploy via Dashboard EasyPanel

1. **Siapkan File Project**
   - Compress seluruh folder `Project2-DenganProxy/` menjadi `project2.zip`
   - Pastikan `docker-compose.yml` ada di root ZIP

2. **Deploy Project**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Upload Files**
   - Upload `project2.zip`
   - EasyPanel akan otomatis mendeteksi `docker-compose.yml`
   - Konfigurasi:
     - **Name**: `auth-app-dengan-proxy`
   - Klik **Create**

3. **Tunggu Deploy Selesai**
   - EasyPanel akan build dan menjalankan semua container
   - Tunggu sampai statusnya **Running**

---

### Langkah Akhir: Akses Aplikasi

Akses melalui domain yang diberikan EasyPanel atau langsung via IP VPS:
- `https://auth-app-dengan-proxy.yourdomain.com` atau `http://IP_VPS_ANDA`

Semua request (frontend dan API) melalui URL yang sama!
- Frontend: `/`
- API: `/api/register`, `/api/login`, `/api/profile`

---

## Perintah Berguna di VPS

```bash
# Melihat container yang berjalan
docker ps

# Melihat log database
docker logs project2-database

# Melihat log Nginx
docker logs project2-nginx

# Melihat log backend
docker logs project2-backend

# Melihat log frontend
docker logs project2-frontend

# Menghentikan semua container
docker-compose down

# Memulai kembali
docker-compose up -d

# Melihat resource usage
docker stats
```

---

## Troubleshooting

### Jika tidak bisa diakses:
1. Pastikan port 80 tidak diblokir firewall
2. Cek status container: `docker ps`
3. Cek log Nginx: `docker logs project2-nginx`

### Jika API error:
1. Pastikan container backend berjalan: `docker ps | grep backend`
2. Cek log backend: `docker logs project2-backend`

## Testing Lokal

Jika ingin testing di lokal sebelum deploy:

```bash
docker-compose up -d --build
```

Akses:
- `http://localhost`

## Keuntungan Menggunakan Proxy

1. **Backend tidak terekspos**: Backend hanya bisa diakses via Nginx
2. **Single entry point**: Semua request melalui satu port (80/443)
3. **SSL/TLS termination**: Mudah setup HTTPS di level proxy
4. **Load balancing**: Bisa menambahkan multiple backend
5. **Rate limiting**: Bisa membatasi request per detik
6. **WAF**: Bisa menambahkan firewall aplikasi web
7. **Static file caching**: Nginx bisa cache file static dengan cepat

## Perbandingan dengan Project 1

| Fitur | Project 1 (Tanpa Proxy) | Project 2 (Dengan Proxy) |
|-------|-------------------------|--------------------------|
| Akses Backend | Langsung | Via Proxy |
| Port yang Diekspose | 2 port (8000, 8080) | 1 port (80) |
| Keamanan | Rendah | Tinggi |
| URL API | Domain terpisah | Path yang sama (/api) |
