# Panduan Lengkap Pengisian Google Play Console - PresenSync
*Berdasarkan Panduan Slide Presentasi Resmi (30 Halaman) & Regulasi Google Play Terbaru*

---

## 📑 Daftar Isi Formulir Play Console
1. [Kebijakan Privasi (Slide 10–11)](#1-kebijakan-privasi-slide-1011)
2. [Akses Aplikasi / Reviewer Login (Slide 12)](#2-akses-aplikasi--app-access-slide-12)
3. [Rating Konten / Kuesioner IARC (Slide 13–15)](#3-rating-konten--kuesioner-iarc-slide-1315)
4. [Target Audiens & Konten (Slide 16)](#4-target-audiens--konten-slide-16)
5. [Keamanan Data / Data Safety (Slide 17)](#5-keamanan-data--data-safety-slide-17)
6. [Aplikasi Pemerintah (Slide 18)](#6-aplikasi-pemerintah-slide-18)
7. [Fitur Keuangan (Slide 19)](#7-fitur-keuangan-slide-19)
8. [ID Iklan (Slide 20)](#8-id-iklan-slide-20)
9. [Aplikasi Kesehatan (Slide 21)](#9-aplikasi-kesehatan-slide-21)
10. [Kategori Aplikasi & Tag (Slide 22–23)](#10-kategori-aplikasi--tag-slide-2223)
11. [Detail Kontak Listingan Toko (Slide 24)](#11-detail-kontak-listingan-toko-slide-24)
12. [Siapkan Listingan Play Store (Slide 25–27)](#12-siapkan-listingan-play-store-slide-2527)
13. [Rilis & Pengujian Tertutup / Closed Testing (Slide 28–29)](#13-rilis--pengujian-tertutup-closed-testing-slide-2829)

---

### 1. Kebijakan Privasi (Slide 10–11)
- Masuk ke menu **Konten Aplikasi** > **Kebijakan Privasi**.
- **URL Kebijakan Privasi:** Masukkan URL tempat Anda meng-host file [privacy_policy.html](file:///c:/Users/Acer/Documents/tugass/presensync/playstore_assets/privacy_policy.html) (misalnya GitHub Pages `https://username.github.io/presensync/privacy-policy` atau link hosting web Anda).
- Alternatif gratis instan: Anda dapat menggunakan link dari [TermsFeed](https://www.termsfeed.com) seperti pada contoh slide materi (`https://www.termsfeed.com/live/...`).

---

### 2. Akses Aplikasi / App Access (Slide 12)
Google memerlukan akses untuk mencoba seluruh fitur aplikasi saat proses review:
- Pilih: **"Semua atau beberapa fungsi di aplikasi saya dibatasi"**
- Klik **"+ Tambahkan petunjuk"**:
  - **Nama Petunjuk:** `Akun Penguji Reviewer`
  - **Nama Pengguna / Nomor Telepon:** `reviewer@mobileprojp.com` (atau nomor telepon/email demo terdaftar)
  - **Sandi:** `ReviewerPass123!`
  - **Penjelasan Tambahan:**
    > *"Aplikasi presensi ini mewajibkan pengguna terautentikasi. Akun penguji di atas telah disiapkan untuk proses peninjauan Google Play. Penguji juga dapat mendaftarkan akun baru secara langsung melalui tombol 'Daftar Akun' di layar utama aplikasi."*
  - Centang: *"Izinkan Android menggunakan kredensial yang Anda berikan..."*

---

### 3. Rating Konten / Kuesioner IARC (Slide 13–15)
- **Alamat Email:** `mobileprojp@gmail.com`
- **Pilih Kategori:** **"Semua Jenis Aplikasi Lainnya"** (Utility, Productivity, Tools)
- **Pertanyaan Kuesioner:**
  - Apakah aplikasi berisi konten terkait seks, kekerasan, bahasa kasar? ➔ Pilih **"Tidak"**
  - Berbagi konten pengguna (suara/obrolan/gambar antar publik)? ➔ Pilih **"Tidak"**
  - Pembelian item digital (in-app purchase)? ➔ Pilih **"Tidak"**
  - Mengakses lokasi fisik presisi? ➔ Pilih **"Ya"** (untuk fungsi presensi)
- **Hasil Rating:** Aplikasi akan mendapatkan sertifikasi **Semua Umur / PEGI 3 / USK 0 (Rating L)**.

---

### 4. Target Audiens & Konten (Slide 16)
- **Kelompok Usia Target:** Centang **"18 tahun ke atas"** (Target pelatihan kerja PPKD/staf profesional).
- **Daya Tarik Bagi Anak:** Pilih **"Tidak"** (Aplikasi tidak dirancang khusus untuk menarik minat anak-anak).

---

### 5. Keamanan Data / Data Safety (Slide 17)
- Apakah aplikasi Anda mengumpulkan atau membagikan jenis data pengguna yang ditentukan? ➔ Pilih **"Ya"**
- Apakah semua data pengguna yang dikumpulkan oleh aplikasi Anda dienkripsi saat transit? ➔ Pilih **"Ya"** (Menggunakan protokol HTTPS)
- Apakah Anda menyediakan cara bagi pengguna untuk meminta data mereka dihapus? ➔ Pilih **"Ya"**
- **Detail Jenis Data:**
  1. **Lokasi (Location):**
     - Jenis: *Lokasi Akurat (Precise Location)*
     - Dikumpulkan? **Ya**
     - Dibagikan ke pihak ketiga? **Tidak**
     - Tujuan: **Fungsi Aplikasi (Presensi Geofencing)**
     - Diperlukan atau Opsional? **Diperlukan untuk fitur check-in**
  2. **Info Pribadi (Personal Info):**
     - Jenis: *Nama & Alamat Email*
     - Dikumpulkan? **Ya**
     - Dibagikan? **Tidak**
     - Tujuan: **Fungsi Aplikasi & Manajemen Akun**
  3. **Foto dan Video:**
     - Jenis: *Foto*
     - Dikumpulkan? **Ya** (Opsional untuk foto profil dan lampiran surat izin sakit)
     - Dibagikan? **Tidak**

---

### 6. Aplikasi Pemerintah (Slide 18)
- Apakah aplikasi Anda dikembangkan oleh atau atas nama pemerintah?
- Sesuai slide panduan materi: Pilih **"Tidak"** (Kecuali jika Anda memiliki surat kuasa/mandat khusus dari dinas terkait untuk mendapatkan lencana resmi pemerintah).

---

### 7. Fitur Keuangan (Slide 19)
- Centang pilihan di bagian paling bawah:
  ➔ **"Aplikasi saya tidak menyediakan fitur keuangan apa pun"**

---

### 8. ID Iklan (Slide 20)
- Apakah aplikasi Anda menggunakan ID iklan (Advertising ID)?
- Pilih **"Tidak"** (PresenSync bersih dari SDK iklan pihak ketiga seperti AdMob).

---

### 9. Aplikasi Kesehatan (Slide 21)
- Centang pilihan di bagian paling bawah:
  ➔ **"Aplikasi saya tidak memiliki fitur kesehatan apa pun"**

---

### 10. Kategori Aplikasi & Tag (Slide 22–23)
- **Aplikasi atau game:** Pilih **"Aplikasi"**
- **Kategori:** Pilih **"Alat"** *(Tools)* atau **"Produktivitas"** *(Productivity)*
- **Tag:** Pilih tag yang relevan:
  - `Alat`
  - `Produktivitas`
  - `Bisnis`

---

### 11. Detail Kontak Listingan Toko (Slide 24)
- **Alamat Email:** `mobileprojp@gmail.com`
- **Nomor Telepon:** *(Dapat dikosongkan atau diisi nomor pengembang)*
- **Situs Web:** `https://appabsensi.mobileprojp.com`

---

### 12. Siapkan Listingan Play Store (Slide 25–27)
Gunakan aset yang telah disiapkan di folder `playstore_assets/`:
- **Nama Aplikasi:** `PresenSync - Presensi Digital`
- **Deskripsi Singkat:** `Presensi digital berbasis lokasi geofencing & sinkronisasi waktu server terpadu.`
- **Deskripsi Lengkap:** Salin dari file `playstore_assets/STORE_LISTING.md`
- **Ikon Aplikasi (512x512):** Upload `playstore_assets/app_icon_512x512.png`
- **Gambar Fitur (1024x500):** Upload `playstore_assets/feature_graphic_1024x500.png`
- **Tangkapan Layar Ponsel:** Upload seluruh file tangkapan layar dari folder `playstore_assets/screenshots/` (minimal 2 file, disarankan mengunggah kelima screenshot).

---

### 13. Rilis & Pengujian Tertutup / Closed Testing (Slide 28–29)
Untuk akun developer Google Play perorangan (dibuat setelah Nov 2023), Google mewajibkan **Pengujian Tertutup selama 14 hari dengan minimal 20 penguji**:
1. Masuk ke **Uji Coba** > **Pengujian Tertutup (Closed Testing)** > Buat Jalur Uji Coba.
2. **Negara/Wilayah (Slide 28):** Pilih **"Indonesia"** (atau target negara Anda).
3. **Penguji (Slide 29):**
   - Buat Daftar Email penguji (misal grup `PPKD B4` atau rekan-rekan penguji).
   - Masukkan minimal 20 alamat email Google akun penguji.
4. **Buat Rilis Baru:**
   - Upload file App Bundle: `build/app/outputs/bundle/release/app-release.aab`
   - Beri nama rilis: `1.0.0 (1)`
   - Catatan rilis: `Rilis perdana PresenSync untuk pengujian keandalan sistem presensi geofencing.`
5. Simpan dan kirim untuk ditinjau. Setelah disetujui Google, bagikan link uji coba ke 20 penguji untuk diinstal dan aktif dibuka selama 14 hari berturut-turut sebelum mengajukan akses Produksi publik.
