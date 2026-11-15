# Panduan Membuat Capture Files (.cap) untuk UTS

**File .cap adalah binary file berisi WPA2 handshake packets.**

Untuk 10 kasus, Anda memerlukan 10 file capture berbeda:
- `handshake-k1.cap` sampai `handshake-k10.cap`

---

## 3 Cara Membuat Capture Files

### CARA 1: Dari Real Access Point (Recommended - Jika Ada)

Jika sekolah memiliki **wireless access point test**, lakukan capture real:

```bash
# Terminal 1: Monitor mode
sudo airmon-ng start wlan0

# Terminal 2: Tangkap traffic
sudo airodump-ng -w capture-k1 wlan0mon

# Terminal 3: Disconnect client (force 4-way handshake)
sudo aireplay-ng --deauth 10 -a [BSSID] wlan0mon

# Wait 30 detik sampai file muncul:
# capture-k1-01.cap (berisi WPA2 handshake)

# Ulangi untuk k2 sampai k10 dengan BSSID berbeda
```

**File hasil:** `capture-k1-01.cap` → rename to `handshake-k1.cap`

**Keuntungan:** 100% real, handshake guaranteed valid
**Waktu:** ~15 menit per capture × 10 kasus = 150 menit

---

### CARA 2: Download dari Repository Publik (Easiest)

Aircrack-ng project menyediakan sample captures:

```bash
cd samples/

# Download sample captures
wget -q https://download.aircrack-ng.org/files/WPA-01.cap -O handshake-sample.cap
wget -q https://download.aircrack-ng.org/files/WPA-02.cap -O handshake-sample2.cap

# Verify
file handshake-*.cap
tcpdump -r handshake-sample.cap | head -10
```

**File hasil:** Langsung pakai atau duplicate untuk k1-k10

**Keuntungan:** Cepat, sudah tested, guaranteed valid
**Waktu:** ~5 menit
**Source:** https://github.com/aircrack-ng/aircrack-ng/tree/master/test

---

### CARA 3: Generate Synthetic dengan Script (Advanced)

Jika tidak ada akses AP atau file public, buat synthetic:

```bash
# Install tools
sudo apt-get install scapy tcpdump

# Buat script generate
cat > generate_captures.py << 'EOFPYTHON'
#!/usr/bin/env python3
import os
from scapy.all import *

def create_fake_wpa_capture(filename, ssid="TestSSID", password="TestPass123"):
    """
    Generate fake WPA2 handshake capture
    (Simplified - generates EAPOL frames)
    """
    packets = []
    
    # Create fake EAPOL message 1 (key message from AP)
    eapol = IP()/LLC()/SNAP()/EAPOL()
    packets.append(eapol)
    
    # Message 2, 3, 4 for 4-way handshake
    for i in range(3):
        packets.append(eapol)
    
    # Write to pcap
    wrpcap(filename, packets)
    print(f"✓ Created: {filename}")

# Generate untuk 10 kasus
for i in range(1, 11):
    create_fake_wpa_capture(f"handshake-k{i}.cap")
    
print("\n✓ Semua 10 capture files dibuat!")
EOFPYTHON

python3 generate_captures.py
```

**File hasil:** 10 synthetic .cap files

**Keuntungan:** Otomatis, bisa customizable per kasus
**Waktu:** ~2 menit
**Catatan:** Synthetic captures mungkin tidak real 100%

---

## Cara Paling Praktis untuk Sekolah

**Recommended untuk classroom:**

```bash
cd samples/

# Step 1: Download satu sample yang sudah tested
wget https://download.aircrack-ng.org/files/WPA-01.cap

# Step 2: Duplicate untuk 10 kasus
for i in {1..10}; do
  cp WPA-01.cap handshake-k$i.cap
done

# Step 3: Verify semua valid
for file in handshake-k*.cap; do
  echo "Testing $file..."
  aircrack-ng -w wordlist-${file#handshake-} $file | grep -q "Targets detected" && echo "  ✓ Valid"
done

# Step 4: Simpan
ls -lh handshake-k*.cap
```

**Waktu:** 10 menit setup, langsung bisa dipakai

---

## Verifikasi Capture Files Valid

```bash
# Test 1: File format
file handshake-k1.cap
# Expected: "pcapng capture file - version 1.0"

# Test 2: Punya EAPOL frames
tcpdump -r handshake-k1.cap | grep -i eapol | head -5

# Test 3: Bisa dibaca aircrack-ng
aircrack-ng handshake-k1.cap
# Expected:
# [00:00:00] Targets detected: 1
# [00:00:00] Number of handshakes: 1
```

---

## Persiapan untuk Ujian

### Pre-exam (2 minggu sebelum)

```bash
cd samples/

# Download atau generate 10 capture files
# (Gunakan salah satu CARA di atas)

# Verify semua valid
for file in handshake-k*.cap; do
  aircrack-ng $file 2>&1 | grep "handshakes" || echo "ERROR: $file invalid!"
done

# Test 1x dengan wordlist
aircrack-ng -w wordlist-k1.txt handshake-k1.cap
# Harus menemukan password atau "KEY NOT FOUND" (bukan error)
```

### Distribution ke Mahasiswa

```bash
# Per mahasiswa - hanya kasus mereka
for nim in [NIM_LIST]; do
  kasus=$(calculate_case_from_nim $nim)
  mkdir -p student-$nim/
  cp wordlist-k$kasus.txt student-$nim/
  cp handshake-k$kasus.cap student-$nim/
done
```

---

## Troubleshooting

| Problem | Solusi |
|---------|--------|
| File tidak valid | Download ulang atau generate baru |
| aircrack-ng error | Pastikan handshake frame ada di capture |
| File terlalu kecil | Pastikan copy berhasil (check size) |
| Password tidak ditemukan | Normal jika capture incomplete |

---

## File Checklist

Sebelum ujian mulai:

- [ ] 10 wordlist files ada (wordlist-k1.txt - k10.txt)
- [ ] 10 capture files ada (handshake-k1.cap - k10.cap)
- [ ] Setiap capture file >50KB (bukan kosong)
- [ ] Test 1x: `aircrack-ng -w wordlist-k1.txt handshake-k1.cap` berhasil
- [ ] Backup semua files (external drive)
- [ ] Siap distribute per mahasiswa

---

## Quick Commands

```bash
# Create all 10 wordlist + capture distribution
for i in {1..10}; do
  echo "✓ Case k$i ready"
  [ -f wordlist-k$i.txt ] && echo "  Wordlist: $(wc -l < wordlist-k$i.txt) passwords"
  [ -f handshake-k$i.cap ] && echo "  Capture: $(du -h handshake-k$i.cap)"
done

# Archive for distribution
tar -czf exam-samples.tar.gz wordlist-k*.txt handshake-k*.cap
```

---

**Status:** 10 wordlist files ✓ siap pakai
**To-do:** Tambah 10 capture files (gunakan CARA 2 paling mudah)

