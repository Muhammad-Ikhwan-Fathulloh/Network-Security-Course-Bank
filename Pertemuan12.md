# 👁️ Pertemuan 12: IDS dengan Snort

## Daftar Isi
1. [Apa itu IDS (Intrusion Detection System)?](#1-apa-itu-ids-intrusion-detection-system)
2. [Arsitektur Snort](#2-arsitektur-snort)
3. [Mode Operasi Snort](#3-mode-operasi-snort)
4. [Anatomi Rules Snort](#4-anatomi-rules-snort)
5. [Hands-On: Instalasi & Konfigurasi Dasar Snort](#5-hands-on-instalasi--konfigurasi-dasar-snort)
6. [Hands-On: Menulis Custom Rules (Nmap & Brute Force)](#6-hands-on-menulis-custom-rules-nmap--brute-force)
7. [Hands-On: Analisis Alert Snort](#7-hands-on-analisis-alert-snort)
8. [Latihan Mandiri](#8-latihan-mandiri)

---

## 1. Apa itu IDS (Intrusion Detection System)?

**IDS** adalah sistem yang memantau trafik jaringan atau aktivitas sistem untuk mendeteksi aktivitas mencurigakan atau serangan yang sedang berlangsung.

**Perbedaan IDS vs IPS:**
- **IDS (Detection)**: Hanya mendeteksi dan memberi alert.
- **IPS (Prevention)**: Mendeteksi dan melakukan aksi blokir secara otomatis.

---

## 2. Arsitektur Snort

Snort adalah IDS/IPS open-source paling populer di dunia. Komponen utamanya:
1. **Packet Decoder**: Mengambil paket dari interface jaringan.
2. **Preprocessor**: Merapikan paket sebelum dianalisis (misal: HTTP dynamic decoding).
3. **Detection Engine**: Mencocokkan paket dengan database rules (aturan).
4. **Logging & Alerting**: Mengeluarkan hasil deteksi ke file log atau dashboard.

---

## 3. Mode Operasi Snort

- **Sniffer Mode**: Membaca paket dan menampilkan di layar (seperti tcpdump).
- **Packet Logger Mode**: Mencatat semua paket ke dalam folder log.
- **IDS Mode**: Mencocokkan paket dengan aturan dan mengeluarkan alert.

---

## 4. Anatomi Rules Snort

Struktur dasar sebuah rule:
`[Action] [Protocol] [Src IP] [Src Port] -> [Dst IP] [Dst Port] (Options)`

**Contoh:**
`alert icmp any any -> any any (msg:"Ping Terdeteksi"; sid:1000001; rev:1;)`

---

## 5. Hands-On: Instalasi & Konfigurasi Dasar Snort

Di container target (Ubuntu):

```bash
# 1. Install Snort
apt update && apt install -y snort

# 2. Cek versi
snort -V

# 3. Jalankan sniffer mode
snort -v -i eth0
```

---

## 6. Hands-On: Menulis Custom Rules (Nmap & Brute Force)

Kita akan membuat aturan sendiri di file `/etc/snort/rules/local.rules`.

### 6.1 Deteksi Nmap Stealth Scan
```bash
# Tambahkan ke local.rules
alert tcp any any -> $HOME_NET any (msg:"Nmap Stealth Scan Detected"; flags:S; sid:1000002;)
```

### 6.2 Deteksi SSH Brute Force
```bash
# Deteksi 5 attempt dalam 60 detik
alert tcp any any -> $HOME_NET 22 (msg:"SSH Brute Force Attempt"; detection_filter:track by_src, count 5, seconds 60; sid:1000003;)
```

---

## 7. Hands-On: Analisis Alert Snort

1. **Jalankan Snort dengan local.rules**:
```bash
snort -A console -q -c /etc/snort/snort.conf -i eth0
```

2. **Lakukan Serangan dari Kali**:
```bash
nmap -sS 172.20.0.10
```

3. **Lihat Output di Snort**:
Akan muncul alert: `[**] [1:1000002:0] Nmap Stealth Scan Detected [**]`

---

## 8. Latihan Mandiri

### Latihan 1: Deteksi HTTP Attack
Buatlah rule Snort untuk mendeteksi serangan SQL Injection sederhana yang mengandung kata kunci `UNION SELECT` di dalam request HTTP.

### Latihan 2: Snort sebagai IPS (Inline Mode)
Pelajari tentang mode **DAQ (Data Acquisition)** yang memungkinkan Snort berjalan secara inline untuk memblokir paket (IPS), bukan hanya memberi alert.
