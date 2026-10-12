# 🛡️ Network Security Lab: Docker & Kali Linux

Selamat datang di repositori pusat mata kuliah **Network Security**. Repositori ini dirancang sebagai panduan praktis (hands-on) untuk memahami vektor serangan jaringan dan metodologi pertahanan menggunakan lingkungan terkontainerisasi yang aman.

## 📋 Daftar Kurikulum (16 Pertemuan)

### Modul Infrastruktur & Network Attacks (Pertemuan 1–7)

| Sesi | Topik | Detail Aktivitas & Tools |
| --- | --- | --- |
| **00** | **Docker & Kali Setup** | Instalasi Docker Desktop, perintah dasar `docker run/ps/exec`, volumes, bridge network, Docker Compose. |
| **01** | **Pengantar Network Security & Setup Lab** | CIA Triad, `docker-compose` multi-container, Kali + DVWA, eksperimen persistensi volume. |
| **02** | **Cryptography 101** | Praktik `openssl` (AES/RSA), hashing `md5sum`/`sha256sum`, analisis sertifikat SSL/TLS. |
| **03** | **L2 Security: ARP Spoofing** | `arpspoof` (dsniff), IP Forwarding, DNS Spoofing via `iptables` NAT. |
| **04** | **Wireless Security** | Simulasi WPA2 handshake, `aircrack-ng` suite, serangan deauth dengan `aireplay-ng`. |
| **05** | **L3 Security: IP/ICMP** | Scapy, Smurf Attack, DHCP Starvation (`yersinia`), ICMP Redirect MITM. |
| **06** | **L4 Security: TCP/UDP** | Three-way handshake, SYN Flood (`hping3`), TCP Session Hijacking, UDP Amplification. |
| **07** | **DNS Security** | DNS Cache Poisoning, DNS Exfiltration, DNSSEC, DoH. |

### UTS (Pertemuan 8)

| Sesi | Topik | Keterangan |
| --- | --- | --- |
| **08** | **🏫 UTS** | Ujian Tengah Semester — mencakup materi Pertemuan 1–7. |

### Modul Application Security & Defense (Pertemuan 9–15)

| Sesi | Topik | Detail Aktivitas & Tools |
| --- | --- | --- |
| **09** | **SQL Injection** | Manual union-based injection & automated scanning (`sqlmap`) pada DVWA. |
| **10** | **XSS & CSRF** | Pencurian cookie via Stored XSS, pembuatan form auto-submit untuk CSRF. |
| **11** | **CVE & CVSS** | CVE ID lifecycle, CVSS v4.0 metric groups, NVD, studi kasus Log4Shell. Hands-on: query NVD API, `nikto` scan, CVSS Calculator. |
| **12** | **Setup VPS & Nginx** | Provisioning VPS (Sumopod + EasyPanel), konfigurasi Nginx sebagai WAF + Reverse Proxy, Rate Limiting, SSL (Certbot), Fail2ban. |
| **13** | **Hands-On Reverse Proxy** | Lab NginxProxy (WAF dasar) vs HalimunProxy (AES-256-CBC encrypted proxy, Replay Protection, SSRF Guard). Penetrasi dengan `sqlmap` + Kali. |
| **14** | **Firewalling** | Implementasi `iptables` rules (Drop, Reject, Accept), Rate Limiting koneksi, proteksi port scanning. |
| **15** | **IDS dengan Snort** | Custom Rules Snort untuk mendeteksi Nmap scan dan SSH Brute Force. |

### UAS (Pertemuan 16)

| Sesi | Topik | Keterangan |
| --- | --- | --- |
| **16** | **🏆 UAS** | Ujian Akhir Semester — komprehensif Pertemuan 1–15. Termasuk soal praktik full pentest, CVE analysis, dan proxy comparison. |

---

## 🏗️ Arsitektur Lab Docker

Kita menggunakan Docker untuk mensimulasikan jaringan kompleks tanpa membebani resource host.

### Contoh Konfigurasi `docker-compose.yml`

```yaml
version: '3.8'

services:
  kali-attacker:
    image: kalilinux/kali-rolling
    container_name: kali-attacker
    tty: true
    stdin_open: true
    privileged: true
    volumes:
      - ./kali-home:/root
    networks:
      lab_network:
        ipv4_address: 172.20.0.5

  victim-web:
    image: vulnerables/web-dvwa
    container_name: web-target
    networks:
      lab_network:
        ipv4_address: 172.20.0.10

networks:
  lab_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
```

---

## 🧪 Hands-On Labs

### Lab 1: NginxProxy — WAF Dasar
```bash
cd HandsOnServerProxy/NginxProxy
docker-compose up -d --build
# Akses: http://localhost:8080
```

### Lab 2: HalimunProxy — Encrypted Reverse Proxy
```bash
cd HandsOnServerProxy/HalimunProxy
docker-compose up -d --build
# Akses: http://localhost:8080 (admin/admin)
```

---

## 🎓 Proyek Utama

### UTS (Pertemuan 8): MITM Framework
**Objektif:** Membangun jalur intersepsi traffic di jaringan lokal.
- **Alur:** `ARP Spoofing` → `IP Forwarding` → `DNS Spoofing` → `Credential Sniffing`

### UAS (Pertemuan 16): Full Penetration Test
**Objektif:** Audit keamanan menyeluruh (Black-Box Testing) + analisis CVE/CVSS.
- **Tahapan:** Reconnaissance → SQLi/XSS Exploitation → CVE Analysis → Proxy Comparison → Reporting

---

## 📚 Sumber Belajar & Referensi

- **OWASP Top 10:** [owasp.org](https://owasp.org/www-project-top-ten/)
- **PortSwigger Academy:** [portswigger.net](https://portswigger.net/web-security)
- **NVD:** [nvd.nist.gov](https://nvd.nist.gov)
- **CVSS Calculator:** [first.org/cvss](https://www.first.org/cvss/calculator/4.0)
- **GTFOBins:** [gtfobins.github.io](https://gtfobins.github.io/)
- **MITRE ATT&CK:** [attack.mitre.org](https://attack.mitre.org/)
