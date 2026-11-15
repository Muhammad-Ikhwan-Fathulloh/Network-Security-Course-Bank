# Panduan Lengkap Penguji UTS Network Security (Pertemuan 1–7)

Dokumen ini berisi checklist dan panduan untuk penguji sebelum, selama, dan sesudah ujian praktik berbasis Docker.

---

## 1. PERSIAPAN SEBELUM UJIAN (7 hari sebelum)

### 1.1 Verifikasi Hardware
- [ ] Minimal **16GB RAM** tersedia (8GB untuk 2 mahasiswa bersamaan)
- [ ] **50GB free disk space** (Dockerfile build dan image pull membutuhkan ~20GB)
- [ ] Docker dan Docker Compose terinstall terbaru
- [ ] Network connectivity stabil (untuk pull image pertama kali)

```bash
# Cek versi Docker
docker --version
docker compose version

# Cek resource
docker stats --no-stream
```

### 1.2 Build Custom Images (Jalankan hanya SEKALI)

Jalankan di folder repository `UTS-Network-Security`:

```bash
cd 01-sumber-lab

# Build tiga image custom (total waktu ~10 menit)
docker build -t uts-openssl images/uts-openssl
docker build -t uts-kali-tools images/uts-kali-tools
docker build -t uts-dnsmasq images/uts-dnsmasq

# Pull base images (total waktu ~15 menit)
docker pull alpine:3.20
docker pull nginx:alpine
docker pull vulnerables/web-dvwa
docker pull kalilinux/kali-rolling

# Verifikasi semua image ada
docker images | grep -E "uts-|alpine|nginx|dvwa|kali"
```

Expected output:
```
REPOSITORY                TAG          IMAGE ID
uts-openssl              latest       <id>  (size ~100MB)
uts-kali-tools           latest       <id>  (size ~1.5GB)
uts-dnsmasq              latest       <id>  (size ~50MB)
alpine                   3.20         <id>  (size ~7MB)
nginx                    alpine       <id>  (size ~40MB)
vulnerables/web-dvwa     latest       <id>  (size ~150MB)
kalilinux/kali-rolling   latest       <id>  (size ~200MB)
```

### 1.3 Verify Semua Bagian Berjalan

**Bagian A (Container & Network):**
```bash
# A1 - Port mapping
docker run -d --name test-a1 -p 9999:80 nginx:alpine
curl -s http://localhost:9999 | head -n 1
docker rm -f test-a1
# ✓ Halaman nginx muncul

# A5 - Network bridge
docker network create test-net
docker run -d --name test-a --network test-net alpine sleep infinity
docker run -d --name test-b --network test-net alpine sleep infinity
docker exec test-a ping -c 1 test-b
docker network rm test-net
# ✓ Ping berhasil
```

**Bagian B (Compose files):**
```bash
cd 01-sumber-lab

# B1 - Internal network
cd b/b1-compose
docker compose up -d
docker compose exec attacker wget -qO- http://target | head -n 1
docker compose down -v
cd ../..
# ✓ Nginx page terakses

# B3 - SYN flood
cd b/b3-syn-flood
docker compose up -d
docker compose exec target netstat -ant | grep -c SYN_RECV
docker compose down -v
cd ../..
# ✓ netstat berjalan

# B4 - DNS exfiltration
cd b/b4-dns-exfil
docker compose up -d
LOGLEN=$(docker compose logs dns | wc -l)
[ $LOGLEN -gt 5 ] && echo "✓ DNS logging works"
docker compose down -v
cd ../..
```

### 1.4 Siapkan Capture & Wordlist Files

Untuk **Tugas 4 (WPA2 cracking)**, siapkan file per mahasiswa/kasus:

```bash
# Buat sample wordlist
cat > samples/wordlist-k1.txt << 'EOF'
password123
admin123
router12345
wifipass
12345678
defaultpass
keypass123
EOF

# Buat 10 versi (untuk 10 kasus)
for i in {1..10}; do
  cp samples/wordlist-k1.txt samples/wordlist-k$i.txt
done

# Untuk handshake .cap file, gunakan sample dari aircrack-ng project
# ATAU lakukan capture sendiri jika sudah ada access point test
# Dokumentasi akan ditambahkan di section 3.2
```

**Catatan:** File `.cap` harus disediakan penguji per mahasiswa (berbeda per NIM untuk hindari cheating).

### 1.5 Buat Versi Soal Alternatif (Hindari Contekan)

Untuk mengurangi contekan, buat **dua versi soal** dengan mengganti:

**Versi A (Kode ganjil):**
```yaml
# docker-compose.yml (b/b3-syn-flood/docker-compose-v1.yml)
services:
  target-v1:
    image: nginx:alpine
  attacker-v1:
    image: uts-kali-tools
```

**Versi B (Kode genap):**
```yaml
# docker-compose.yml (b/b3-syn-flood/docker-compose-v2.yml)
services:
  target-v2:
    image: nginx:alpine
  attacker-v2:
    image: uts-kali-tools
```

Ganti juga:
- Container names (target-k1 → target-v1-k1)
- Volume names (vol-k1 → vol-v1-k1)
- Passwords (kunci-k1-2026 → kunci-v1-k1-2026)

---

## 2. DISTRIBUSI SOAL KEPADA MAHASISWA

### 2.1 Tentukan Kasus per NIM
- [ ] Terima daftar NIM dari koordinator
- [ ] Hitung kasus per NIM (jumlah digit mod 10)
- [ ] Buat tabel mapping NIM → Kasus
- [ ] Bagikan soal sesuai kasus (jangan dicampur)

**Template Tabel:**
| NIM | Jumlah digit | Mod 10 | Kasus |
|-----|--------------|--------|-------|
| 19552011024 | 30 | 0 | 10 |
| 19552011025 | 31 | 1 | 1 |

### 2.2 Buat File Soal per Mahasiswa

```bash
# Template untuk mahasiswa (copy dengan ganti NIM)
mkdir -p jawaban-mahasiswa/

cat > jawaban-mahasiswa/TEMPLATE-jawaban.md << 'EOF'
# JAWABAN UTS Praktik Network Security

**NIM:** [ISIKAN NIM ANDA]
**Kasus:** [ISIKAN NOMOR KASUS]

## Perhitungan Kasus
- Digit NIM: [pisahkan per digit]
- Jumlah digit: [hasil]
- Sisa bagi 10: [hasil]
- Kasus yang diterima: [kasus final]

---

## Tugas 1 (Pertemuan 1): Docker & Volume

### Bukti:
[Paste output dari: docker run --rm -v vol-k*.../data alpine cat /data/laporan-k*.txt]

[Paste output dari: docker compose ... exec attacker wget -qO- http://target]

### Penjelasan:
[Jelaskan bagaimana volume mempertahankan data setelah container dihapus]

---

## Tugas 2 (Pertemuan 2): Kriptografi

### Bukti SHA-256:
[Paste dua hash SHA-256 - sebelum dan sesudah dekripsi]

### Sertifikat:
[Paste Subject, Issuer, dan tanggal kadaluarsa]

### Penjelasan:
[Jelaskan perbedaan sertifikat self-signed dan CA-signed]

---

## Tugas 3 (Pertemuan 3): ARP Spoofing

### MAC Address Sebelum Spoofing:
[Paste arp -a output]

### MAC Address Saat Spoofing:
[Paste arp -a output]

### Mitigasi:
[Jelaskan bagaimana static ARP binding mengembalikan MAC normal]

---

## Tugas 4 (Pertemuan 4): WPA2 Cracking

### Hasil aircrack-ng:
[Paste output aircrack-ng dengan kata sandi yang ditemukan atau KEY NOT FOUND]

### Penjelasan 4-way Handshake:
[Jelaskan 4 frame dalam WPA2 handshake]

---

## Tugas 5 (Pertemuan 5): ICMP dengan Scapy

### Output kirim_icmp.py:
[Paste TTL dan tipe ICMP balasan]

### Penjelasan SMURF Attack:
[Jelaskan bagaimana SMURF attack menggunakan ICMP broadcast]

---

## Tugas 6 (Pertemuan 6): SYN Flood

### SYN_RECV Sebelum Attack:
[Paste angka]

### SYN_RECV Saat Attack:
[Paste angka]

### Three-way Handshake (tcpdump):
[Paste SYN, SYN-ACK, ACK packets]

### Mitigasi:
[Jelaskan SYN cookies atau rate limiting]

---

## Tugas 7 (Pertemuan 7): DNS Exfiltration

### NIM dalam hex:
[Hasil dari: echo -n NIM-ANDA | xxd -p]

### Log DNS Query:
[Paste baris dari docker logs yang menunjukkan query <hex>.k*.exfil.lab]

### Decode Pesan:
[Hasil dari: echo <hex> | xxd -r -p]

---

## Kesimpulan

Saya telah menyelesaikan semua 7 tugas dengan output dan penjelasan yang diminta.

**Total waktu:** [jam:menit]
**Catatan:** [Jika ada masalah teknis]

EOF
```

---

## 3. PROSEDUR UJIAN

### 3.1 Sebelum Mahasiswa Mulai (15 menit)

Untuk setiap mahasiswa:

```bash
# 1. Siapkan terminal bersih
docker system prune -f

# 2. Verifikasi folder struktur (dari terminal mahasiswa)
cd ~/UTS-Network-Security
ls -la 01-sumber-lab/{images,b,kasus}

# 3. Bagikan file soal khusus kasus mereka
cp 02-dokumen/LEMBAR-PERINTAH-PER-KASUS.md ~/soal-saya.md
# Edit: tampilkan hanya Kasus mereka

# 4. Bagikan capture & wordlist
cp samples/handshake-k*.cap ~/
cp samples/wordlist-k*.txt ~/

# 5. Buat folder kerja
mkdir -p ~/ujian-uts
cd ~/ujian-uts
```

### 3.2 Selama Ujian

**Durasi: 120 menit per mahasiswa**

Penguji harus:
- [ ] Memastikan terminal mahasiswa terbuka dan terlihat
- [ ] Mencatat timestamp awal dan akhir
- [ ] Memantau tidak ada akses ke internet (docker ps dan docker network inspect)
- [ ] Memverifikasi output bukan copy-paste dari internet

**Command penguji untuk monitoring:**
```bash
# Monitor container mahasiswa
docker ps --format "table {{.Names}}\t{{.Status}}"

# Cek network isolation (harus ada "Internal: true")
docker network inspect lab

# Lihat resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### 3.3 Pemberhentian Ujian

Mahasiswa harus:
- [ ] Menghapus semua container (`docker compose down -v`)
- [ ] Mengumpulkan file jawaban.md
- [ ] Menunjukkan terminal history (history atau .bash_history)

```bash
# Verifikasi cleanup
docker ps -a | wc -l  # Harus 0 atau minimal
docker network ls | wc -l  # Hanya bridge, host, none
docker volume ls | wc -l  # Hanya local (tidak ada vol-k*)
```

---

## 4. VERIFIKASI JAWABAN

### 4.1 Checklist per Tugas

Untuk setiap mahasiswa, verifikasi:

**Tugas 1:** ✓ File dari volume masih ada ✓ Halaman nginx terakses
**Tugas 2:** ✓ Dua SHA-256 sama ✓ Sertifikat valid
**Tugas 3:** ✓ MAC berubah saat spoof ✓ MAC normal setelah static ARP
**Tugas 4:** ✓ Handshake dianalisis ✓ Kata sandi ditemukan
**Tugas 5:** ✓ TTL dan tipe ICMP ada ✓ Penjelasan SMURF ada
**Tugas 6:** ✓ SYN_RECV meningkat ✓ TCP handshake di tcpdump
**Tugas 7:** ✓ NIM dalam hex terdeteksi ✓ Decode berhasil

### 4.2 Rubrik Penilaian

Gunakan rubrik dari `DOKUMEN-UTS-LENGKAP.md` section 5.

**Template scoring:**

```
A1 (Container & Port Mapping):    __/10
A2 (Volume Persistence):          __/10
A3 (Hash Integrity):              __/10
A4 (Encryption):                  __/10
A5 (Bridge Network):              __/10
B1 (Compose & Isolation):         __/12.5
B2 (RSA & Certificate):           __/12.5
B3 (SYN Flood Detection):         __/12.5
B4 (DNS Exfiltration):            __/12.5

TOTAL NILAI:                      __/100

Pengurang nilai:
- Output tidak lengkap (-30%):     __
- Perintah tidak bisa diulang (-50%): __
- Serangan ke host luar (-100%):   __

NILAI AKHIR:                      __/100
```

---

## 5. TROUBLESHOOTING UMUM

### 5.1 Container Tidak Bisa Diakses

**Error:** `connect: permission denied`

**Solusi:**
```bash
# Pastikan user dalam grup docker
usermod -aG docker $USER
newgrp docker

# Atau gunakan sudo
sudo docker ps
```

### 5.2 Network Internal Tidak Bekerja

**Error:** `Container tidak bisa akses internet`

**Verifikasi:**
```bash
# Check network isolation
docker network inspect lab-arp-k1 | grep "Internal"
# Expected: "Internal": true

# Jika false, network tidak terisolasi
```

### 5.3 Image Build Gagal

**Error:** `Error response from daemon: pull access denied`

**Solusi:**
```bash
# Cek koneksi internet
ping 8.8.8.8

# Cek Docker daemon
sudo systemctl restart docker

# Coba build lagi
docker build -t uts-kali-tools --no-cache images/uts-kali-tools
```

### 5.4 Disk Space Habis

**Error:** `write error: no space left on device`

**Solusi:**
```bash
# Bersihkan image/container lama
docker system prune -af --volumes

# Cek ukuran Docker
du -sh /var/lib/docker
```

---

## 6. POST-UJIAN

### 6.1 Kumpulkan Jawaban
- [ ] Semua file jawaban.md dari mahasiswa
- [ ] Terminal history untuk audit (jika diperlukan)
- [ ] Screenshot keberhasilan (opsional, jika ada masalah)

### 6.2 Backup Log
```bash
# Simpan docker history untuk audit
docker history uts-openssl > uts-openssl-history.txt
docker history uts-kali-tools > uts-kali-tools-history.txt
docker history uts-dnsmasq > uts-dnsmasq-history.txt

# Simpan daftar scores
cp scores-ujian.txt backups/
```

### 6.3 Cleanup Server
```bash
# Hapus semua container dan volume mahasiswa
docker system prune -af --volumes

# Verifikasi hanya image tersisa
docker images

# Hapus volume sample jika ada
docker volume rm vol-k{1..10}
```

---

## 7. CATATAN PENTING

⚠️ **KEAMANAN & ETIKA:**
- Jangan biarkan mahasiswa mengakses jaringan luar (network internal: true harus diterapkan)
- Tangkap setiap percobaan serangan ke host real di luar lab
- Verifikasi perintah bisa diulang (tidak boleh hardcoded output)

⚠️ **REPRODUCIBILITY:**
- Jalankan semua perintah penguji minimal 2x di environment sebelum ujian
- Dokumentasikan setiap perubahan untuk consistency
- Verifikasi timing (total waktu harus ≤ 2 jam per mahasiswa)

⚠️ **DOCUMENTATION:**
- Simpan bukti output mahasiswa (screenshots atau copy-paste ke file)
- Catat waktu ujian dan anomali teknis
- Buat laporan ujian untuk departemen/akademik

---

**Versi:** 1.0
**Terakhir diupdate:** 2026-11-15
**Penguji:** [Nama Penguji]
**Tanda tangan & Tanggal:** _________________

