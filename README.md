# 🛡️ Network Security Lab: Docker & Kali Linux

Selamat datang di repositori pusat mata kuliah **Network Security**. Repositori ini dirancang sebagai panduan praktis (hands-on) untuk memahami vektor serangan jaringan dan metodologi pertahanan menggunakan lingkungan terkontainerisasi yang aman.

## 📋 Daftar Kurikulum & Detail Teknis

Setiap pertemuan dirancang untuk menyeimbangkan teori protokol dengan praktik eksploitasi dan mitigasi.

### Modul 1-7: Infrastructure & Network Attacks

| Sesi | Topik | Detail Aktivitas & Tools |
| --- | --- | --- |
| **01** | **Setup Lab & CIA Triad** | Instalasi `docker-compose`, konfigurasi `macvlan` network, dan pengenalan Docker ephemeral storage. |
| **02** | **Cryptography 101** | Praktik `openssl` (AES/RSA), hashing `md5sum`/`sha256sum`, dan analisis sertifikat SSL/TLS. |
| **03** | **L2 Security: ARP Spoofing** | Penggunaan `arpspoof` (dsniff) dan `Ettercap`. |
| **04** | **Wireless Security** | Simulasi WPA2 handshake, penggunaan `aircrack-ng` suite, dan serangan deauth. |
| **05** | **L3 Security: IP/ICMP** | Analisis paket `scapy`, serangan *Smurf Attack*, dan DHCP Starvation menggunakan `yersinia`. |
| **06** | **L4 Security: TCP/UDP** | *Three-way handshake* deep dive, SYN Flood menggunakan `hping3`, dan TCP Session Hijacking. |
| **07** | **DNS Security** | Konfigurasi `bind9` rentan, DNS Cache Poisoning, dan *DNS Exfiltration*. |

### Modul 8-14: Application Security & Defense

| Sesi | Topik | Detail Aktivitas & Tools |
| --- | --- | --- |
| **08** | **SQL Injection** | Manual union-based injection & automated scanning dengan `sqlmap` pada target DVWA. |
| **09** | **XSS & CSRF** | Pencurian cookie via Stored XSS dan pembuatan form *auto-submit* untuk serangan CSRF. |
| **10** | **Email Security** | Analisis header email (hop-by-hop), simulasi SMTP relay, dan setup SPF/DKIM record. |
| **11** | **Firewalling** | Implementasi `iptables` rules (Drop, Reject, Accept) dan *Rate Limiting* koneksi. |
| **12** | **IDS dengan Snort** | Penulisan *Custom Rules* Snort untuk mendeteksi Nmap scan dan serangan Brute Force. |
| **13** | **Vuln Scanning** | Vulnerability assessment menggunakan `Nmap NSE`, `Nikto`, dan `OpenVAS/GVM`. |
| **14** | **Hardening** | Implementasi *Least Privilege*, penutupan port tidak perlu, dan SSH hardening. |

---

## 🏗️ Arsitektur Lab Docker

Kita menggunakan Docker untuk mensimulasikan jaringan kompleks tanpa membebani resource host.

### Contoh Konfigurasi `docker-compose.yml`

```yaml
services:
  kali:
    image: kalilinux/kali-rolling
    container_name: kali-attacker
    networks:
      pentest_net:
        ipv4_address: 172.20.0.5
    tty: true # Menjaga container tetap berjalan

  victim-web:
    image: vulnerables/web-dvwa
    container_name: web-target
    networks:
      pentest_net:
        ipv4_address: 172.20.0.10

networks:
  pentest_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

```

---

## 🎓 Proyek Utama

### 1. UTS: Man-in-the-Middle (MITM) Framework

**Objektif:** Membangun "jalur sutra" informasi ilegal di jaringan lokal.

* **Target:** Intersepsi kredensial login dari situs HTTP di container korban.
* **Alur:** `Arpspoofing` ➡️ `IP Forwarding` ➡️ `DNS Spoofing` ➡️ `SSL Strip` (opsional) ➡️ `Credential Sniffing`.

### 2. UAS: Full Penetration Test (Vulnerable Lab)

**Objektif:** Melakukan audit keamanan menyeluruh (Black-Box Testing).

* **Tahapan:**
1. **Reconnaissance:** Scanning port dan identifikasi service.
2. **Exploitation:** Mendapatkan akses user (Low Privilege).
3. **Privilege Escalation:** Menjadi `root` di dalam container.
4. **Exfiltration:** Mengambil data sensitif (Flag).
5. **Reporting:** Membuat laporan standar industri (Executive Summary vs Technical Findings).



---

## 📚 Sumber Belajar & Referensi

Untuk memperdalam materi, mahasiswa sangat disarankan merujuk pada:

* **OWASP Top 10:** [owasp.org](https://owasp.org/www-project-top-ten/) (Standar keamanan web).
* **PortSwigger Academy:** [portswigger.net](https://portswigger.net/web-security) (Latihan web security gratis).
* **GTFOBins:** [gtfobins.github.io](https://gtfobins.github.io/) (Eksploitasi binary Unix).
* **MITRE ATT&CK:** [attack.mitre.org](https://attack.mitre.org/) (Basis pengetahuan taktik serangan).
