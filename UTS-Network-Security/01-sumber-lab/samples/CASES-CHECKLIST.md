# 10 Cases - File Checklist untuk Mahasiswa

Status file yang sudah disediakan untuk setiap kasus:

## ✅ Sudah Siap (Wordlist Files)

Setiap kasus punya **wordlist unik** dengan 20 kata sandi berbeda:

```
✓ wordlist-k1.txt   - password: network2026 (20 entries)
✓ wordlist-k2.txt   - password: security2026 (20 entries)
✓ wordlist-k3.txt   - password: attacksim2026 (20 entries)
✓ wordlist-k4.txt   - password: defense2026 (20 entries)
✓ wordlist-k5.txt   - password: encryption2026 (20 entries)
✓ wordlist-k6.txt   - password: protocol2026 (20 entries)
✓ wordlist-k7.txt   - password: firewall2026 (20 entries)
✓ wordlist-k8.txt   - password: intrusion2026 (20 entries)
✓ wordlist-k9.txt   - password: vulnerability2026 (20 entries)
✓ wordlist-k10.txt  - password: compliance2026 (20 entries)
```

**Fitur:** Setiap kasus punya password unik di awal → mencegah cheating

---

## ⏳ Perlu Dibuat (Capture Files)

Untuk setiap kasus perlu **1 file .cap** berisi WPA2 handshake:

```
❌ handshake-k1.cap   - [PERLU DIBUAT]
❌ handshake-k2.cap   - [PERLU DIBUAT]
❌ handshake-k3.cap   - [PERLU DIBUAT]
❌ handshake-k4.cap   - [PERLU DIBUAT]
❌ handshake-k5.cap   - [PERLU DIBUAT]
❌ handshake-k6.cap   - [PERLU DIBUAT]
❌ handshake-k7.cap   - [PERLU DIBUAT]
❌ handshake-k8.cap   - [PERLU DIBUAT]
❌ handshake-k9.cap   - [PERLU DIBUAT]
❌ handshake-k10.cap  - [PERLU DIBUAT]
```

**Lihat:** `CAPTURE-FILES-GUIDE.md` untuk cara membuat

---

## Cara Membuat Capture Files (Pilih Satu)

### CARA TERCEPAT (Recommended):

```bash
cd samples/

# Download sample capture dari aircrack-ng
wget https://download.aircrack-ng.org/files/WPA-01.cap

# Duplicate untuk 10 kasus
for i in {1..10}; do
  cp WPA-01.cap handshake-k$i.cap
done

# Verify berhasil
ls -lh handshake-k*.cap
```

**Waktu:** 5 menit
**Hasil:** Semua 10 file siap pakai

---

### CARA REAL (Jika Ada Access Point):

```bash
# Tangkap real handshake per kasus
sudo airodump-ng -w capture-k1 wlan0mon
sudo aireplay-ng --deauth 10 -a [BSSID] wlan0mon
# Ulangi untuk k2-k10
```

**Waktu:** ~15 menit × 10 = 150 menit
**Hasil:** 100% real handshakes

---

### CARA ADVANCED (Script):

```bash
python3 << 'EOF'
from scapy.all import wrpcap, IP, LLC, SNAP, EAPOL
for i in range(1, 11):
    packets = [IP()/LLC()/SNAP()/EAPOL() for _ in range(4)]
    wrpcap(f"handshake-k{i}.cap", packets)
EOF
```

**Waktu:** 2 menit
**Hasil:** Synthetic captures

---

## Distribusi ke Mahasiswa

```bash
# Setiap mahasiswa dapat wordlist + capture untuk kasusnya saja

# Contoh: Mahasiswa dengan NIM → Kasus 3
cp wordlist-k3.txt ~/mahasiswa-ujian/
cp handshake-k3.cap ~/mahasiswa-ujian/

# Mahasiswa download dari folder tersebut
# atau copy ke USB
```

---

## Verification Checklist

Sebelum exam dimulai:

```bash
# 1. Semua wordlist ada?
ls wordlist-k*.txt | wc -l
# Expected: 10

# 2. Semua capture files ada?
ls handshake-k*.cap | wc -l
# Expected: 10

# 3. Test 1x dengan aircrack-ng
aircrack-ng -w wordlist-k1.txt handshake-k1.cap
# Expected: Berhasil crack atau "KEY NOT FOUND" (bukan error)

# 4. Total size reasonable?
du -sh handshake-k*.cap
# Expected: ~500MB-1GB total (minimal 50MB per file)
```

---

## Timeline Recommended

| Waktu | Aktivitas |
|-------|-----------|
| 2 minggu sebelum | Persiapkan capture files (gunakan CARA TERCEPAT) |
| 1 minggu | Test semua 10 cases dengan aircrack-ng |
| 3 hari | Backup semua files ke external drive |
| 1 hari sebelum | Verifikasi final, siapkan distribusi |
| Hari exam | Bagikan file per mahasiswa sesuai kasus |

---

## File Structure Saat Ujian

Folder mahasiswa masing-masing:

```
~/ujian-uts/
├── wordlist-kX.txt      (20 passwords)
├── handshake-kX.cap     (WPA2 handshake)
├── jawaban.md           (template jawaban)
└── [output dari 7 tasks]
```

Hanya **1 wordlist + 1 capture** per mahasiswa (sesuai kasusnya)

---

## Done Checklist

- [x] 10 Wordlist files siap pakai
  - [x] Setiap kasus punya password unik
  - [x] Minimal 20 entries per wordlist
  - [x] Format valid (1 password per baris)

- [ ] 10 Capture files (gunakan CAPTURE-FILES-GUIDE.md)
  - [ ] Setiap file >50KB
  - [ ] Format .cap (pcap/pcapng)
  - [ ] Berisi WPA2/EAPOL frames
  - [ ] Bisa dibaca aircrack-ng

- [ ] Test semua kombinasi
  - [ ] aircrack-ng -w wordlist-kX.txt handshake-kX.cap

- [ ] Backup & distribute ready
  - [ ] Semua files ter-backup
  - [ ] Ready untuk bagikan per mahasiswa

---

## Quick Start

```bash
# 1. Cek wordlist
cd samples/
ls -1 wordlist-k*.txt
wc -l wordlist-k*.txt

# 2. Buat capture files
wget https://download.aircrack-ng.org/files/WPA-01.cap
for i in {1..10}; do cp WPA-01.cap handshake-k$i.cap; done

# 3. Verify
ls -lh handshake-k*.cap

# 4. Archive
tar -czf exam-ready.tar.gz wordlist-k*.txt handshake-k*.cap

# 5. Distribute
# Bagikan ke mahasiswa sesuai kasusnya
```

---

**Status Keseluruhan:** 50% siap (wordlist ✓, capture ⏳)

**Action Item:** Buat 10 capture files menggunakan CAPTURE-FILES-GUIDE.md

