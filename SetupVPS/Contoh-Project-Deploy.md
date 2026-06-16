# 🚀 Contoh Project Deploy di EasyPanel

Berikut adalah **dua contoh project** untuk deploy aplikasi web di EasyPanel:

## 📁 Struktur Folder

```
SetupVPS/
├── Project1-TanpaProxy/    # Project tanpa reverse proxy
├── Project2-DenganProxy/   # Project dengan Nginx reverse proxy
└── Contoh-Project-Deploy.md  # File ini
```

---

## 1️⃣ Project 1: Tanpa Proxy

**Karakteristik:**
- Frontend dan backend terekspos langsung ke publik
- Setiap layanan memiliki port sendiri
- Cocok untuk development atau testing cepat

**File:** [Project1-TanpaProxy/README.md](./Project1-TanpaProxy/README.md)

---

## 2️⃣ Project 2: Dengan Nginx Proxy

**Karakteristik:**
- Semua request melalui Nginx reverse proxy
- Backend tidak terekspos langsung (lebih aman)
- Single entry point (satu port untuk semua)
- Cocok untuk production

**File:** [Project2-DenganProxy/README.md](./Project2-DenganProxy/README.md)

---

## 📊 Perbandingan Kedua Project

| Fitur | Tanpa Proxy | Dengan Proxy |
|-------|-------------|--------------|
| **Keamanan** | Rendah (backend terekspos) | Tinggi (backend terlindungi) |
| **Port** | 2 port (8000, 8080) | 1 port (80) |
| **URL API** | Domain terpisah | Path `/api` |
| **SSL Setup** | Perlu setup di setiap layanan | Cukup di proxy |
| **Rate Limiting** | Tidak ada | Bisa ditambahkan |
| **WAF** | Tidak ada | Bisa ditambahkan |

---

## 🛠️ Cara Menjalankan di Lokal

### Project 1:
```bash
cd Project1-TanpaProxy
docker-compose up -d --build
```
Akses: `http://localhost:8080`

### Project 2:
```bash
cd Project2-DenganProxy
docker-compose up -d --build
```
Akses: `http://localhost`

---

## � Panduan Deploy ke VPS dengan EasyPanel

Berikut adalah panduan **step-by-step** untuk deploy kedua project ke VPS Anda yang sudah terinstall EasyPanel.

### Prasyarat
Pastikan:
1. VPS Anda sudah terinstall EasyPanel (lihat [README.md](./README.md))
2. Anda sudah login ke Dashboard EasyPanel
3. Anda memiliki akses SSH ke VPS (opsional tapi direkomendasikan)

---

## 📤 Cara 1: Deploy Menggunakan Docker Compose (Termudah)

Ini adalah cara termudah karena kita bisa deploy semua layanan sekaligus.

### Untuk Project 2 (Dengan Proxy) - REKOMENDASI

1. **Upload File ke VPS**
   - Login SSH ke VPS Anda
   - Buat folder project:
     ```bash
     mkdir -p ~/project2
     cd ~/project2
     ```
   - Upload semua file dari folder `Project2-DenganProxy/` ke VPS (gunakan SCP/SFTP atau clone repository Git)

2. **Deploy dengan Docker Compose**
   ```bash
   docker-compose up -d --build
   ```

3. **Atur di EasyPanel**
   - Buka Dashboard EasyPanel
   - Klik **Create Project**
   - Pilih **Existing Service**
   - Pilih container yang sudah berjalan (`project2-nginx`, `project2-backend`, `project2-frontend`)
   - Atur domain jika diperlukan

### Untuk Project 1 (Tanpa Proxy)

1. **Upload File ke VPS**
   ```bash
   mkdir -p ~/project1
   cd ~/project1
   # Upload semua file dari Project1-TanpaProxy/
   ```

2. **Deploy dengan Docker Compose**
   ```bash
   docker-compose up -d --build
   ```

3. **Atur di EasyPanel**
   - Tambahkan container yang sudah berjalan ke EasyPanel

---

## 📤 Cara 2: Deploy Melalui Dashboard EasyPanel

### Deploy Project 2 (Dengan Proxy)

1. **Siapkan File**
   - Compress folder `Project2-DenganProxy/` menjadi file ZIP
   
2. **Buat Project Baru di EasyPanel**
   - Klik **Create Project**
   - Pilih **Upload Files**
   - Upload file ZIP yang sudah dibuat
   - EasyPanel akan otomatis mendeteksi `docker-compose.yml`
   
3. **Konfigurasi Project**
   - **Name**: `toko-online-proxy`
   - Klik **Create**
   
4. **Tunggu Deploy Selesai**
   - EasyPanel akan build dan menjalankan semua container
   
5. **Akses Aplikasi**
   - Klik project yang sudah dibuat
   - Akses URL yang diberikan (contoh: `https://toko-online-proxy.yourdomain.com`)

### Deploy Project 1 (Tanpa Proxy)

1. **Deploy Backend Terlebih Dahulu**
   - Compress folder `Project1-TanpaProxy/backend-php/`
   - Buat project baru dengan nama `project1-backend`
   - Set port menjadi `80` dan publish port `8000`
   
2. **Edit Frontend**
   - Buka file `Project1-TanpaProxy/frontend-js/script.js`
   - Ubah `API_URL` menjadi URL backend Anda:
     ```javascript
     const API_URL = 'https://project1-backend.yourdomain.com';
     ```
   
3. **Deploy Frontend**
   - Compress folder `Project1-TanpaProxy/frontend-js/`
   - Buat project baru dengan nama `project1-frontend`
   - Set port menjadi `80` dan publish port `8080`

---

## 🔍 Verifikasi Deployment

### Cek Container di VPS
Anda bisa memeriksa container yang berjalan via SSH:
```bash
docker ps
```

### Cek Log Container
```bash
# Project 2
docker logs project2-nginx
docker logs project2-backend

# Project 1
docker logs project1-backend
docker logs project1-frontend
```

---

## �📝 Catatan Penting

Untuk deploy di EasyPanel, pastikan:
1. VPS Anda sudah terinstall EasyPanel (lihat [README.md](./README.md))
2. Upload file project ke repository Git atau langsung ke EasyPanel
3. Ikuti instruksi di masing-masing README project
4. Pastikan port yang digunakan tidak bentrok dengan layanan lain (EasyPanel menggunakan port 3000)
