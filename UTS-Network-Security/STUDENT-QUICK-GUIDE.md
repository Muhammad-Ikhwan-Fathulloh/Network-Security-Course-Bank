# UTS Network Security - Panduan Cepat Mahasiswa

**Baca file ini SAJA - ringkas, praktis, langsung bisa dikerjakan.**

---

## 1. Persiapan (15 menit)

### Clone Repository
```bash
git clone https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank.git
cd Network-Security-Course-Bank/UTS-Network-Security
```

### Tentukan Kasus Anda
- Ambil NIM Anda
- Jumlahkan semua digit
- Hitung `hasil % 10`
- Jika = 0 → Kasus 10, kalau tidak → nomor sisa

Contoh: NIM 19552011024 → 1+9+5+5+2+0+1+1+0+2+4 = 30 → 30 % 10 = 0 → **Kasus 10**

---

## 2. Ambil File Soal Anda

Buka: `02-dokumen/LEMBAR-PERINTAH-PER-KASUS.md`

Cari section: **Kasus X** (ganti X dengan nomor kasus Anda)

Copy SEMUA perintah dari 7 Tugas untuk kasus Anda.

---

## 3. Isi Jawaban

Buat file: `jawaban.md`

```markdown
# JAWABAN UTS Network Security

**NIM:** [ISIKAN]
**Kasus:** [ISIKAN]

## Perhitungan Kasus
- Digit NIM: [1, 9, 5, ...]
- Jumlah: [30]
- Sisa bagi 10: [0]
- Kasus: [10]

## Tugas 1 (Pertemuan 1): Docker & Volume
[Paste output terminal di sini]

## Tugas 2 (Pertemuan 2): Kriptografi
[Paste output terminal di sini]

[... dan seterusnya sampai Tugas 7]
```

---

## 4. Jalankan Perintah per Tugas

### Template untuk setiap tugas:

```bash
# Copy perintah dari LEMBAR-PERINTAH-PER-KASUS.md untuk kasus Anda

# Terminal 1: Jalankan perintah
docker ...

# Lihat output, salin ke jawaban.md
# Lanjut ke Tugas 2
```

**Waktu total:** 90 menit (7 tugas × ~13 menit per tugas)

---

## 5. PENTING: Cleanup Setelah Selesai

### ❌ JANGAN LUPA HAPUS SEMUA CONTAINER!

```bash
# Verifikasi sudah selesai semua 7 tugas

# HAPUS SEMUA container & network yang dibuat
docker ps -a                    # Lihat semua container
docker compose down -v          # Jika pakai compose, cleanup

# Hapus container manual
docker rm -f container-name     # Ganti dengan nama real

# Hapus network manual
docker network rm network-name  # Jika perlu

# VERIFIKASI BERSIH
docker ps -a          # Harus kosong/minimal
docker network ls     # Hanya bridge, host, none
docker volume ls      # Hanya local, TIDAK ada vol-k*
```

### ✅ Verifikasi Cleanup Berhasil

```bash
# Jalankan perintah ini - HARUS seperti ini:
docker ps | wc -l              # Harus: 1 (hanya header)
docker network ls | wc -l      # Harus: 4 (bridge, host, none, + 1 = 4)
```

---

## 6. Kumpulkan Jawaban

1. ✅ Buat file `jawaban.md` dengan:
   - NIM dan Kasus
   - Perhitungan digit NIM
   - Output dari semua 7 Tugas

2. ✅ Sudah hapus semua container

3. ✅ Kumpulkan ke penguji

---

## 7. Troubleshooting Cepat

| Error | Solusi |
|-------|--------|
| `docker: command not found` | Install Docker dulu |
| `connect: permission denied` | `sudo usermod -aG docker $USER` lalu logout/login |
| `no space left on device` | `docker system prune -af` untuk bersihkan |
| `container already exists` | `docker rm -f nama-container` |
| `network already exists` | `docker network rm nama-network` |

---

## 8. Jangan Lupa!

⚠️ **SEBELUM KUMPULKAN:**

- [ ] Semua 7 Tugas dikerjakan
- [ ] Output terminal ada di jawaban.md
- [ ] NIM & Kasus ada di jawaban.md
- [ ] Semua container SUDAH DIHAPUS
- [ ] Semua network SUDAH DIHAPUS
- [ ] Semua volume SUDAH DIHAPUS (kecuali `local` default)

---

## 9. Reference Cepat

### 7 Tugas yang Harus Dikerjakan

1. **Tugas 1 (Docker)** - Volume & port mapping
2. **Tugas 2 (Kriptografi)** - OpenSSL encryption & sertifikat
3. **Tugas 3 (ARP)** - ARP spoofing & mitigasi
4. **Tugas 4 (Wireless)** - WPA2 cracking dengan aircrack-ng
5. **Tugas 5 (ICMP)** - Scapy script untuk ICMP
6. **Tugas 6 (TCP)** - SYN flood & three-way handshake
7. **Tugas 7 (DNS)** - DNS exfiltration & deteksi

### Waktu Alokasi

- **15 menit** - Persiapan & ambil soal
- **90 menit** - Kerjakan 7 tugas
- **10 menit** - Cleanup & verifikasi
- **5 menit** - Kumpulkan

**TOTAL: 120 MENIT (2 JAM)**

---

## 10. Kontak & Bantuan

Jika ada error teknis:

1. **Cek di PENGUJI-CHECKLIST.md** section "Troubleshooting Umum"
2. **Tanyakan ke penguji** dengan screenshot error
3. **Jangan modifikasi** Dockerfile atau docker-compose.yml

---

**INGAT:** Hapus semua container & network setelah selesai!

```bash
docker system prune -af --volumes
```

---

**Good luck! 🚀**

