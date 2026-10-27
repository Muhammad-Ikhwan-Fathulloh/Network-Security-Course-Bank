# 📡 Pertemuan 4: Wireless Security - Lab Index

**Status:** ✅ Ready to Use  
**Last Updated:** 2025-10-27

---

## 📁 Folder Contents

### docker-compose.yml
- **Purpose:** Docker configuration untuk Wireless Security lab
- **Services:** 
  - `kali-wireless-lab` (Attacker)
  - `wifi-ap-target` (AP Simulator)
  - `burp-suite` (Traffic Interceptor)
- **Network:** 192.168.100.0/24
- **Start:** `docker-compose up -d`

### README.md
- **Purpose:** Quick start guide dan troubleshooting
- **Contains:**
  - Setup instructions
  - Lab workflow
  - Common commands
  - Troubleshooting tips

### Folders

#### captures/
- **Purpose:** Menyimpan wireless capture files (.cap, .pcap)
- **Usage:** Hasil dari airodump-ng akan disimpan di sini
- **Tools:** Wireshark untuk analisis

#### wordlists/
- **Purpose:** Menyimpan password dictionary untuk WPA2 cracking
- **Pre-installed:**
  - rockyou.txt (built-in di Kali)
  - Custom wordlists (isi manual)
- **Usage:** 
  ```bash
  cd wordlists/
  cat > custom.txt << EOF
  password123
  router12345
  EOF
  ```

#### configs/
- **Purpose:** Menyimpan konfigurasi untuk hostapd, DHCP, dll
- **Usage:** Untuk setup AP simulator yang lebih advanced

#### scripts/
- **Purpose:** Custom scripts untuk wireless attacks
- **Example:**
  - Monitor mode automation
  - Deauth loops
  - Custom packet injection

---

## 🚀 Quick Start

```bash
# 1. Start lab
docker-compose up -d

# 2. Verify
docker-compose ps

# 3. Access Kali
docker-compose exec kali-wireless-lab bash

# 4. Check tools
aircrack-ng --version
airodump-ng --help

# 5. Start monitoring
airodump-ng wlan0mon

# 6. Cleanup
docker-compose down
```

---

## 📚 Next Steps

1. **Read:** [Pertemuan4.md](../Pertemuan4.md) - Full theory + hands-on
2. **Follow:** Hands-on section di Pertemuan4.md (starting from section 4)
3. **Practice:**
   - Monitor Mode Setup
   - Network Scanning
   - Handshake Capture
   - Deauthentication Attack
   - WPA2 Cracking
   - Evil Twin Setup

---

## 💡 Key Tools Available

- **aircrack-ng suite:** Wireless auditing
- **hostapd:** AP simulator
- **dnsmasq:** DHCP server
- **Burp Suite:** Traffic analysis
- **tcpdump:** Packet capture
- **Wireshark:** Packet analysis

---

## 📊 Lab Topology

```
Docker Network (192.168.100.0/24)
├── kali-wireless-lab (192.168.100.2)
│   └── Tools: aircrack-ng, airodump-ng, aireplay-ng, airbase-ng
├── wifi-ap-target (192.168.100.3)
│   └── Simulated WiFi AP
└── burp-suite (192.168.100.4)
    └── HTTP/HTTPS proxy
```

---

## 🔐 Security Notes

- Lab network is isolated (192.168.100.0/24)
- All attacks confined to Docker network
- No impact on host network
- Safe for practice and learning

---

## 📝 What You'll Learn

- ✅ WPA2 security mechanisms
- ✅ 4-way handshake process
- ✅ Wireless network scanning
- ✅ Handshake capture techniques
- ✅ Dictionary attacks
- ✅ Deauthentication attacks
- ✅ Evil Twin (rogue AP) creation
- ✅ Wireless traffic analysis

---

**Ready to start?** Run `docker-compose up -d` and follow the hands-on guide in Pertemuan4.md!
