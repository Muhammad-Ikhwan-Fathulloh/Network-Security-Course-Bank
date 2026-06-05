# Modul: Memahami CVE dan CVSS dalam Manajemen Kerentanan

## 1. Pendahuluan

Dalam dunia keamanan siber, ditemukan ribuan kerentanan baru setiap tahunnya. Untuk mengelolanya secara efektif, para profesional keamanan memerlukan dua hal: **identifikasi unik** untuk setiap kerentanan dan **standar pengukuran tingkat keparahannya**. Di sinilah peran **CVE** dan **CVSS**.

Modul ini akan membahas secara mendalam tentang CVE, CVSS, serta bagaimana keduanya saling terkait untuk membantu organisasi memprioritaskan tindakan keamanan.

## 2. CVE (Common Vulnerabilities and Exposures)

### 2.1 Apa itu CVE?
Berdasarkan situs resmi `cve.org`, **CVE adalah program internasional yang bertujuan untuk mengidentifikasi, mendefinisikan, dan mengkatalogkan kerentanan keamanan siber yang diungkapkan ke publik** .

CVE BUKANlah sistem penilaian atau basis data yang lengkap. CVE adalah **"daftar" (list)** yang berisi entri-entri dengan format standar.

### 2.2 Komponen Utama Sebuah Entri CVE
Setiap entri CVE, yang sering disebut sebagai **CVE ID**, memiliki format `CVE-TAHUN-NOMOR_UNIK` (contoh: `CVE-2021-44228`). Informasi minimal dalam sebuah entri CVE meliputi :
- **ID:** Pengidentifikasi unik.
- **Deskripsi:** Penjelasan naratif tentang kerentanan tersebut dalam bahasa Inggris.
- **Referensi Publik:** Tautan atau sumber yang terkait dengan kerentanan tersebut.

> **Poin Penting dari CVE.org:** Program CVE **tidak menyediakan skor keparahan (severity scoring) atau prioritas**. Tujuan tunggalnya adalah menyediakan **pengidentifikasi umum** .

### 2.3 Siapa yang Mengelola CVE?
Program CVE dikelola oleh **MITRE Corporation** dengan pendanaan dari Departemen Keamanan Dalam Negeri AS (US Department of Homeland Security / DHS). Namun, kontennya diperkaya oleh mitra global yang disebut **CVE Numbering Authorities (CNAs)** .

---

## 3. CVSS (Common Vulnerability Scoring System)

### 3.1 Apa itu CVSS?
Jika CVE memberikan "nama" pada kerentanan, maka **CVSS adalah "angka" yang menggambarkan seberapa parah kerentanan tersebut** .

**CVSS adalah standar terbuka untuk menilai keparahan kerentanan keamanan komputer.** Standar ini dikelola oleh **FIRST (Forum of Incident Response and Security Teams)**, **bukan oleh CVE atau MITRE** .

### 3.2 Komponen Metrik CVSS
CVSS versi 4.0 (versi terbaru) menyusun penilaian ke dalam beberapa kelompok metrik :

1.  **Base Metric Group (Wajib):**
    - Menggambarkan karakteristik intrinsik dari sebuah kerentanan yang tidak berubah seiring waktu atau tergantung lingkungan.
    - **Komponen Utama:**
        - **Attack Vector (AV):** Seberapa dekat akses penyerang? (Network, Adjacent, Local, Physical).
        - **Attack Complexity (AC):** Seberapa rumit serangan ini? (Low, High).
        - **Privileges Required (PR):** Apakah penyerang butuh akses level tertentu? (None, Low, High).
        - **User Interaction (UI):** Apakah butuh peran serta korban? (None, Passive, Active).
        - **Impact (C/I/A):** Dampak terhadap *Confidentiality, Integrity, Availability*.
    - *Hasil:* Menghasilkan skor numerik 0.0 - 10.0.

2.  **Threat Metric Group (Opsional):**
    - Mengukur ancaman berdasarkan ketersediaan *exploit* di dunia nyata.
    - **Metrik Utama:** *Exploit Maturity* (Attacked, Proof-of-Concept, Unreported).

3.  **Environmental Metric Group (Opsional):**
    - Metrik yang **disesuaikan oleh pengguna akhir (organisasi)** untuk mencerminkan dampak sesungguhnya di lingkungan mereka sendiri. Misalnya, apakah kerentanan ini berdampak pada server yang menyimpan data sangat rahasia atau server tes biasa?

### 3.3 Interpretasi Skor (Severity Rating)
Skor mentah (0.0-10.0) biasanya diterjemahkan ke dalam kategori kualitatif untuk memudahkan prioritas :

| **Kategori** | **Rentang Skor (CVSS v3/4)** |
| :----------- | :--------------------------- |
| **Critical** | 9.0 - 10.0                   |
| **High**     | 7.0 - 8.9                    |
| **Medium**   | 4.0 - 6.9                    |
| **Low**      | 0.1 - 3.9                    |

---

## 4. Hubungan CVE dan CVSS

Sering terjadi kebingungan antara CVE dan CVSS. Berikut adalah analogi dan fakta kuncinya:

- **CVE memberi Anda ID (Siapa namanya?).**
- **CVSS memberi Anda Skor (Seberapa berbahayanya?).**

### 4.1 Dimana mereka bertemu?
Meskipun `cve.org` tidak memberikan skor, basis data **NVD (National Vulnerability Database)** yang dikelola oleh NIST (AS) mengambil daftar CVE dan **menambahkan skor CVSS** untuk setiap entri .

**Alur Kerja Standar:**
1.  Seorang peneliti menemukan bug dan mempublikasikannya -> Mendapat **CVE ID**.
2.  NVD mereview CVE tersebut dan menghitung **CVSS Score** (biasanya Base Score).
3.  Tim keamanan perusahaan melihat NVD, membaca Deskripsi CVE, melihat Skor CVSS-nya (misal: 9.8 Critical), lalu memutuskan untuk memprioritaskan penambalan tersebut.

### 4.2 Contoh Konkret (Log4Shell)
- **CVE ID:** `CVE-2021-44228`
- **Deskripsi CVE:** "Apache Log4j2 ... JNDI features ... remote code execution..."
- **CVSS Score (NVD):** 10.0 (Critical) - Menggunakan vektor CVSS: `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H` .

> **Kesimpulan Hubungan:** **CVE** mengidentifikasi bahwa "Log4Shell" adalah masalah. **CVSS** memberi tahu bahwa masalah ini adalah "**Kritis (10.0)**" karena bisa dieksploitasi dari jarak jauh tanpa login.

---

## 5. Ringkasan dan Praktik Terbaik

1.  **Jangan hanya melihat CVE:** CVE hanya memberi tahu Anda *apa* yang perlu diperbaiki, bukan *seberapa cepat*.
2.  **Gunakan CVSS sebagai panduan awal:** Skor CVSS (terutama dari NVD) adalah titik awal yang baik untuk memfilter kerentanan. Fokus pada yang "Critical" dan "High" terlebih dahulu .
3.  **Terapkan Environmental Metrics:** Jangan percaya mentah-mentah skor 7.0 (High) untuk server internal yang tidak penting. Sebaliknya, skor 4.3 (Medium) untuk server public-facing yang menyimpan data kartu kredit mungkin lebih penting untuk segera ditambal .
4.  **Perhatikan Versi:** CVSS saat ini sudah memasuki **versi 4.0**. Pastikan alat yang Anda gunakan sudah mendukung versi terbaru untuk akurasi yang lebih baik .

### Tabel Perbandingan Cepat

| Fitur                        | **CVE**                                        | **CVSS**                                       |
| :--------------------------- | :--------------------------------------------- | :--------------------------------------------- |
| **Kepanjangan**              | Common Vulnerabilities and Exposures           | Common Vulnerability Scoring System            |
| **Fungsi Utama**             | Memberi ID/nama pada kerentanan                | Menilai tingkat keparahan (skor)               |
| **Output**                   | ID (Contoh: CVE-2024-1234) + Deskripsi singkat | Angka (0.0 - 10.0) + Kategori (Low, High, dll) |
| **Pengelola**                | MITRE (dengan CNAs)                            | FIRST                                          |
| **Apakah menyediakan skor?** | **Tidak** (Lihat NVD untuk skornya)            | **Ya** (Ini adalah tujuan utamanya)            |