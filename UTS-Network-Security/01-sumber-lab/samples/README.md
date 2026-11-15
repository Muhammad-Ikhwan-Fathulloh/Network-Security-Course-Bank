# Samples: Wordlist dan Capture Files untuk Tugas 4 (WPA2)

Folder ini berisi contoh dan template untuk wordlist dan capture files yang digunakan di **Tugas 4 (Pertemuan 4): Analisis Handshake WPA2**.

---

## 1. Wordlist Files

File `.txt` berisi kata sandi untuk cracking dengan `aircrack-ng`. Setiap file wordlist harus berisi satu kata sandi per baris.

### Format Wordlist

```
password123
admin123
router12345
wifipass
12345678
keypass
defaultpass
```

### Persiapan Wordlist per Kasus

Untuk 10 kasus, siapkan **10 wordlist berbeda** agar mahasiswa tidak bisa copy-paste hasil:

```bash
# Template: Copy ke 10 file terpisah
cp wordlist-template.txt wordlist-k1.txt
cp wordlist-template.txt wordlist-k2.txt
...
cp wordlist-template.txt wordlist-k10.txt

# EDIT setiap file dan TAMBAHKAN kata sandi yang berbeda
# Jangan gunakan kata sandi yang sama untuk semua kasus!
```

**Contoh variasi:**

**wordlist-k1.txt:**
```
12345678
password123
admin123
router12345
wifipass
```

**wordlist-k2.txt:**
```
password456
cisco12345
networksec
wifisecure
123456789
```

**wordlist-k3.txt:**
```
network2026
security123
admin456
routerpass
keypass123
```

Dan seterusnya untuk k4 sampai k10.

### Tips Membuat Wordlist Sulit Ditebak

1. **Jangan gunakan** kata sandi yang terkenal (password123, admin, dll) untuk SEMUA kasus
2. **Gunakan variasi** panjang (6-12 karakter)
3. **Campur** huruf, angka, dan underscore: `wifi_2026`, `net_sec_k1`
4. **Hindari pola** yang mudah: jangan k1 → password1, k2 → password2
5. **Dokumentasikan** kata sandi di file terpisah hanya untuk penguji

### Wordlist yang Sudah Disiapkan

```
wordlist-k1.txt   - 50 kata sandi
wordlist-k2.txt   - 50 kata sandi
wordlist-k3.txt   - 50 kata sandi
wordlist-k4.txt   - 50 kata sandi
wordlist-k5.txt   - 50 kata sandi
wordlist-k6.txt   - 50 kata sandi
wordlist-k7.txt   - 50 kata sandi
wordlist-k8.txt   - 50 kata sandi
wordlist-k9.txt   - 50 kata sandi
wordlist-k10.txt  - 50 kata sandi
```

---

## 2. Capture Files (.cap)

File `.cap` adalah **handshake WPA2 yang sudah ditangkap** dari wireless network. File ini digunakan untuk testing `aircrack-ng -w wordlist.txt handshake.cap`.

### Format & Struktur .cap

File `.cap` adalah hasil capture dari tools seperti:
- `airodump-ng` (aircrack-ng suite)
- `tcpdump`
- Wireshark

Format file `.cap` adalah **libpcap format** yang berisi raw network packets termasuk WPA2 4-way handshake.

### Cara Membuat Capture File

#### Opsi 1: Dari Real Access Point (Recommended jika tersedia)

Jika ada **wireless access point test** yang bisa dikonfigurasi, lakukan:

```bash
# Terminal 1: Monitor jaringan
sudo airodump-ng wlan0mon -w capture-k1

# Terminal 2: Deauthenticate client (jika ada)
sudo aireplay-ng --deauth 10 -a [BSSID] wlan0mon

# Terminal 3: Tunggu 4-way handshake
# File akan tersimpan sebagai: capture-k1-01.cap
```

Hasil: 1 file `.cap` per access point per kasus.

#### Opsi 2: Menggunakan Sample dari Repository

Jika tidak ada akses AP test, gunakan **sample handshake** dari open-source projects:

```bash
# Download dari aircrack-ng repository
wget https://www.aircrack-ng.org/Files/WPA-01.cap -O sample-wpa.cap

# Atau gunakan capture dari Wireshark samples
# https://wiki.wireshark.org/SampleCaptures
```

#### Opsi 3: Simulasi dengan Docker (Advanced)

Jika ingin **generate capture file sintetis**, lihat:
- [Aircrack-ng generator](https://github.com/aircrack-ng/aircrack-ng)
- [Mock WPA captures](https://github.com/aircrack-ng/aircrack-ng/tree/master/test)

### Verifikasi Capture File

Setelah capture, verifikasi format dengan `tcpdump`:

```bash
# Lihat packets dalam capture
tcpdump -r handshake-k1.cap | head -20

# Cari WPA packets
tcpdump -r handshake-k1.cap 'tcp or udp' | grep EAPOL | head -5

# Expected output:
# [timestamp] [source] > [dest]: [WPA/EAPOL frames]
```

### Contoh Validasi dengan aircrack-ng

```bash
# Test capture file bisa dibaca aircrack-ng
aircrack-ng handshake-k1.cap

# Expected output:
# aircrack-ng 1.7
# [00:00:00] Waiting for query responses...
# [00:00:00] Targets detected: 1
# [00:00:00] Number of handshakes: 1
```

---

## 3. Persiapan File untuk Ujian

### Langkah 1: Siapkan Wordlist

```bash
cd samples/

# Pastikan ada 10 wordlist
ls -1 wordlist-k*.txt
# Expected:
# wordlist-k1.txt
# wordlist-k2.txt
# ...
# wordlist-k10.txt

# Verifikasi isi tidak kosong
wc -l wordlist-k*.txt | grep -v " 0 "
```

### Langkah 2: Siapkan Capture Files

```bash
# Pastikan ada 10 capture files
ls -1 handshake-k*.cap
# Expected:
# handshake-k1.cap
# handshake-k2.cap
# ...
# handshake-k10.cap

# Verifikasi ukuran tidak terlalu kecil
du -sh handshake-k*.cap
# Expected: minimal 50KB per file (tidak boleh 0B atau kosong)
```

### Langkah 3: Buat Backup

```bash
# Backup semua files sebelum distribusi
cp -r samples samples-backup-$(date +%Y%m%d)

# Compress untuk distribusi
tar -czf exam-samples.tar.gz wordlist-k*.txt handshake-k*.cap
```

### Langkah 4: Distribusi ke Mahasiswa

Saat memberikan soal, bagikan:

```bash
# Per mahasiswa (sesuai kasusnya)
cp wordlist-k${KASUS}.txt ~/ujian-uts/
cp handshake-k${KASUS}.cap ~/ujian-uts/

# Verifikasi kepemilikan
ls -la ~/ujian-uts/
# total 200
# -rw-r--r--  1 student student 45678 Nov 15 09:00 wordlist-k1.txt
# -rw-r--r--  1 student student 98765 Nov 15 09:00 handshake-k1.cap
```

---

## 4. Panduan Penguji

### Sebelum Ujian

- [ ] Verifikasi semua 10 wordlist ada dan berisi kata sandi berbeda
- [ ] Verifikasi semua 10 capture file ada dan valid
- [ ] Test 1x: `aircrack-ng -w wordlist-k1.txt handshake-k1.cap` harus berhasil
- [ ] Backup files ke external drive

### Saat Ujian

- [ ] Berikan wordlist dan capture HANYA untuk kasus mahasiswa
- [ ] Jangan biarkan mahasiswa share file antar kasus
- [ ] Pantau output aircrack-ng (jangan boleh copy-paste)

### Afterexam

- [ ] Hapus semua file capture dan wordlist dari mahasiswa
- [ ] Simpan backup untuk tahun depan
- [ ] Update dokumentasi jika ada perubahan format

---

## 5. Quick Reference Command

```bash
# Create new wordlist
cat > wordlist-kX.txt << 'EOF'
password1
admin123
network2026
wifi_secure
keypass
EOF

# Test aircrack-ng dengan sample
aircrack-ng -w wordlist-k1.txt handshake-k1.cap

# Count lines in wordlist
wc -l wordlist-k*.txt

# Check capture file format
file handshake-k*.cap
# Expected: data (not empty, not text)

# Archive for distribution
tar -czf samples.tar.gz wordlist-k*.txt handshake-k*.cap

# Extract at exam location
tar -xzf samples.tar.gz
```

---

**Note:**
- Ganti `kX` dengan nomor kasus (1-10)
- JANGAN bagikan kunci jawaban sebelum waktunya
- SIMPAN BACKUP semua files sebelum ujian dimulai
- Perbarui repository setiap tahun dengan capture/wordlist baru

