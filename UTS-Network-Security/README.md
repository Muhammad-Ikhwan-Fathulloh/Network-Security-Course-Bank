# UTS Praktik Infrastruktur & Network Attacks (Pertemuan 1–7)

Folder ini berisi seluruh bahan UTS praktik berbasis Docker: soal, source lab, dan lembar perintah per kasus. Semua serangan hanya boleh dijalankan di lingkungan lab lokal. Jangan memindai atau menyerang host di luar lab.

## Isi folder

```
UTS-Network-Security/
├── README.md                              ← file ini (penjelasan umum)
├── 01-sumber-lab/                         ← source lab (siap dijadikan repositori GitHub)
│   ├── README.md                          ← cara build image dan menjalankan lab
│   ├── images/
│   │   ├── uts-openssl/Dockerfile         ← image untuk Pertemuan 2 (OpenSSL)
│   │   ├── uts-kali-tools/Dockerfile      ← image untuk Pertemuan 3–7 (hping3, dig, tcpdump, scapy, aircrack-ng)
│   │   └── uts-dnsmasq/Dockerfile         ← image untuk Pertemuan 7 (resolver DNS lab)
│   ├── b/
│   │   ├── b1-compose/docker-compose.yml  ← Soal B1: jaringan internal
│   │   ├── b3-syn-flood/docker-compose.yml← Soal B3 dan Tugas 6: SYN flood
│   │   └── b4-dns-exfil/docker-compose.yml← Soal B4 dan Tugas 7: DNS exfiltration
│   └── kasus/
│       ├── k5-scapy/kirim_icmp.py         ← skrip ICMP dengan Scapy (Tugas 5)
│       └── k9-dns-detect/analisis_dns.py  ← skrip deteksi DNS exfiltration (Tugas 7)
└── 02-dokumen/
    ├── DOKUMEN-UTS-LENGKAP.md             ← struktur folder, tata cara, rubrik, seluruh kode, dan studi kasus
    └── LEMBAR-PERINTAH-PER-KASUS.md       ← perintah siap pakai untuk Kasus 1 sampai 10
```

## Urutan pemakaian

1. **Baca** `02-dokumen/DOKUMEN-UTS-LENGKAP.md` untuk memahami soal, rubrik, dan aturan ujian.
2. **Siapkan image** dari `01-sumber-lab`. Bagian B memakai jaringan `internal: true`, sehingga paket harus sudah ada di image sebelum ujian:
   ```bash
   cd 01-sumber-lab
   docker build -t uts-openssl images/uts-openssl
   docker build -t uts-kali-tools images/uts-kali-tools
   docker build -t uts-dnsmasq images/uts-dnsmasq
   docker pull alpine && docker pull nginx:alpine && docker pull vulnerables/web-dvwa && docker pull kalilinux/kali-rolling
   ```
3. **Tentukan kasus** dari NIM: jumlahkan seluruh digit, ambil sisa bagi 10, dan sisa 0 berarti Kasus 10. Contoh NIM 19552011024: jumlah digit 30, sisa 0, maka Kasus 10.
4. **Kerjakan kasus** dengan mengikuti `02-dokumen/LEMBAR-PERINTAH-PER-KASUS.md` pada bagian kasus Anda. Setiap kasus mencakup tujuh tugas (Pertemuan 1 sampai 7) dengan bobot sama.
5. **Lampirkan** jawaban, output terminal, dan jumlah digit beserta sisa bagi NIM di `jawaban.md`.

## Catatan untuk penguji

- Sebelum ujian, jalankan semua perintah sekali di lingkungan yang sama. Kode di folder ini belum pernah diuji di Docker.
- Siapkan file `handshake-KN.cap` dan `wordlist-KN.txt` untuk Tugas 4, karena keduanya disediakan penguji.
- Buat dua versi soal dengan mengganti nama container, volume, dan kata sandi untuk mengurangi contekan.
- Rubrik penilaian ada di `DOKUMEN-UTS-LENGKAP.md` bagian 5. Total nilai 100.
