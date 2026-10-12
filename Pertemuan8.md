# 📝 Pertemuan 8: UTS (Ujian Tengah Semester)

## Informasi Ujian

| Keterangan | Detail |
| :--------- | :----- |
| **Jenis** | UTS (Ujian Tengah Semester) |
| **Cakupan Materi** | Pertemuan 1 – 7 |
| **Format** | Teori + Praktik |
| **Durasi** | 90 – 120 menit |

---

## 🎯 Cakupan Materi UTS

### Pertemuan 1: Pengantar Keamanan Jaringan
- CIA Triad (Confidentiality, Integrity, Availability)
- Setup Docker Lab dengan `docker-compose`
- Konsep containerisasi vs VM

### Pertemuan 2: Cryptography 101
- Konsep hashing (MD5, SHA-256) dan collision
- Enkripsi simetris AES-256-CBC dengan `openssl`
- Enkripsi asimetris RSA (public/private key)
- SSL/TLS dan sertifikat digital

### Pertemuan 3: L2 Security – ARP Spoofing
- Cara kerja ARP dan ARP Cache
- ARP Poisoning dengan `arpspoof`
- MITM: IP Forwarding untuk intercept traffic
- DNS Spoofing via `iptables` NAT

### Pertemuan 4: Wireless Security
- Standar keamanan WiFi (WEP, WPA, WPA2)
- Monitor mode dengan `airmon-ng`
- Capture WPA2 Handshake (`airodump-ng`, `aireplay-ng`)
- Cracking dengan `aircrack-ng` dan `hashcat`

### Pertemuan 5: L3 Security – IP/ICMP
- Manipulasi paket dengan Scapy
- Smurf Attack (ICMP Broadcast Amplification)
- DHCP Starvation dengan `yersinia`
- ICMP Redirect untuk MITM

### Pertemuan 6: L4 Security – TCP/UDP
- Three-way handshake TCP
- SYN Flood dengan `hping3`
- TCP Session Hijacking (konsep)
- UDP Amplification Attack

### Pertemuan 7: DNS Security
- Cara kerja resolusi DNS (Recursive vs Iterative)
- DNS Cache Poisoning (Kaminsky Attack)
- DNS Exfiltration via TXT record
- DNSSEC, DoH, DoT sebagai mitigasi

---

## 📋 Contoh Soal Teori

**1. CIA Triad**
- Sebutkan dan jelaskan tiga pilar CIA Triad beserta contoh serangan yang mengancam masing-masing!
- Apa perbedaan mendasar antara VM tradisional dan Docker container dari sisi isolasi?

**2. Kriptografi**
- Jelaskan perbedaan antara enkripsi simetris dan asimetris. Kapan sebaiknya menggunakan masing-masing?
- Apa yang dimaksud dengan "hash collision" dan mengapa MD5 tidak lagi direkomendasikan untuk keamanan?

**3. ARP Spoofing**
- Gambarkan alur serangan ARP Poisoning dari attacker hingga berhasil melakukan intercept!
- Apa saja langkah mitigasi yang bisa diterapkan untuk melindungi jaringan dari ARP Spoofing?

**4. Wireless Security**
- Mengapa WEP dianggap tidak aman? Jelaskan kelemahan kriptografinya secara singkat!
- Apa yang dimaksud dengan Deauthentication Attack dan apa tujuannya dalam rangkaian serangan WPA2?

**5. L3/L4 Security**
- Jelaskan mengapa serangan SYN Flood efektif dalam menghabiskan resource server!
- Apa perbedaan antara Smurf Attack dan Ping of Death dari sisi vektor serangan?

**6. DNS Security**
- Jelaskan bagaimana DNS Cache Poisoning dapat mengarahkan korban ke situs palsu!
- Bagaimana DNSSEC membantu mencegah DNS Cache Poisoning?

---

## 🛠️ Contoh Soal Praktik

### Soal Praktik 1: Docker Lab
Buatlah `docker-compose.yml` yang menjalankan:
- Container Kali Linux attacker di IP `172.21.0.5`
- Container Ubuntu target di IP `172.21.0.10`
- Jaringan bridge internal subnet `172.21.0.0/24`

Tunjukkan bahwa keduanya dapat saling ping, dan data di `/root` Kali tetap tersimpan setelah container di-restart.

### Soal Praktik 2: Kriptografi
Di dalam container Kali, lakukan hal berikut dan tangkap screenshot setiap langkah:
1. Hash teks `"Ujian Network Security"` dengan SHA-256.
2. Enkripsi teks tersebut menggunakan AES-256-CBC dengan password pilihan Anda.
3. Dekripsi kembali dan verifikasi hasilnya.

### Soal Praktik 3: ARP Spoofing (Analisis)
Diberikan output `arpspoof` dan `tcpdump` berikut. Analisis:
- Siapa yang menjadi attacker, gateway, dan korban?
- Data apa yang berhasil di-intercept?
- Langkah apa yang harus dilakukan admin jaringan untuk mendeteksi serangan ini?

---

## 📚 Tips Persiapan UTS

1. **Review semua hands-on** dari Pertemuan 1–7 — pastikan bisa menjalankan setiap langkah tanpa melihat modul.
2. **Pahami konsep, bukan hafalan** — ujian akan menguji pemahaman alur serangan, bukan sintaks perintah.
3. **Latihan Docker Compose** — kemampuan membuat environment lab dari nol adalah skill utama.
4. **Buat cheat sheet pribadi** — tulis ulang perintah penting dalam kata-kata Anda sendiri.
5. **Kerjakan latihan mandiri** di setiap pertemuan sebelum ujian.

---

## 🔗 Referensi Persiapan

- [Docker Documentation](https://docs.docker.com/)
- [OpenSSL CLI Reference](https://www.openssl.org/docs/man1.1.1/man1/)
- [Aircrack-ng Wiki](https://www.aircrack-ng.org/documentation.html)
- [Scapy Documentation](https://scapy.readthedocs.io/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
