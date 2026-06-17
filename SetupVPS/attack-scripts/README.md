# 📜 Attack Scripts untuk SetupVPS

Folder ini berisi script otomatis untuk melakukan penetration testing pada Project 1 dan Project 2.

---

## 📋 Daftar Script

| Script | Deskripsi |
|--------|-----------|
| `attack-project1.sh` | Test kerentanan pada Project 1 (Tanpa Proxy) |
| `attack-project2.sh` | Test keamanan pada Project 2 (Dengan Proxy) |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Docker Desktop berjalan
- Project target sudah dijalankan dengan `docker-compose up -d`
- Untuk Windows: Gunakan WSL, Git Bash, atau terminal Linux lainnya

### Menjalankan Script untuk Project 1
1. Jalankan Project 1:
   ```bash
   cd ../Project1-TanpaProxy
   docker-compose up -d --build
   ```
2. Jalankan script:
   ```bash
   cd ../attack-scripts
   chmod +x attack-project1.sh
   ./attack-project1.sh
   ```

### Menjalankan Script untuk Project 2
1. Jalankan Project 2:
   ```bash
   cd ../Project2-DenganProxy
   docker-compose up -d --build
   ```
2. Jalankan script:
   ```bash
   cd ../attack-scripts
   chmod +x attack-project2.sh
   ./attack-project2.sh
   ```

---

## 📊 Apa yang Diuji?

### attack-project1.sh:
1. **Port Exposure**: Memeriksa apakah port backend terbuka
2. **Information Leak**: Memeriksa apakah header server terekspos
3. **CORS Misconfiguration**: Memeriksa apakah CORS mengizinkan semua origin
4. **API Enumeration**: Mencoba mengakses endpoint API
5. **Rate Limiting**: Memeriksa apakah ada rate limiting
6. **Frontend Check**: Memeriksa akses frontend

### attack-project2.sh:
1. **Single Entry Point**: Memastikan hanya port proxy yang terbuka
2. **Proxy Headers**: Memeriksa header response dari proxy
3. **API via Proxy**: Menguji akses API melalui proxy
4. **Frontend via Proxy**: Menguji akses frontend melalui proxy
5. **Path Routing**: Memverifikasi routing proxy

---

## 💡 Catatan untuk Windows

Jika Anda menggunakan Windows PowerShell:
- Script `.sh` tidak bisa dijalankan langsung
- Gunakan **Git Bash**, **WSL**, atau **Docker** untuk menjalankan script
- Atau, jalankan perintah satu per satu secara manual

Alternatif dengan Docker:
```bash
# Jalankan container Linux dengan script yang dimount
docker run --rm -it -v ${PWD}:/scripts -w /scripts alpine sh
chmod +x *.sh
./attack-project1.sh
```
