<div align="center">

# 🌐 PresenSync
### *Presensi Tepat, Waktu Selaras, Karier Melesat*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Provider%20MVVM-orange?style=for-the-badge)](https://pub.dev/packages/provider)
[![Security](https://img.shields.io/badge/Anti--Fraud-Geofence%20%26%20TimeSync-red?style=for-the-badge)](https://github.com)
[![Tests](https://img.shields.io/badge/Tests-17%20Passed%20100%25-success?style=for-the-badge)](https://github.com)

<p align="center">
  <b>Sistem Presensi Digital Berbasis Lokasi (Geofencing) & Sinkronisasi Waktu Server Nyata</b><br>
  Dirancang khusus untuk monitoring kehadiran peserta pelatihan kejuruan <b>PPKD (Pusat Pelatihan Kerja Daerah)</b> dengan standar integritas industri modern.
</p>

---

</div>

## 📑 Daftar Isi
- [Tentang PresenSync](#-tentang-presensync)
- [Identitas Visual & Branding](#-identitas-visual--branding)
- [Fitur Utama & Keunggulan](#-fitur-utama--keunggulan)
- [Pembaruan UI/UX & Prinsip Desain](#-pembaruan-uiux--prinsip-desain)
- [Arsitektur & Diagram Sistem](#-arsitektur--diagram-sistem)
- [Mitigasi Keamanan & Anti-Fraud](#-mitigasi-keamanan--anti-fraud)
- [Struktur Proyek](#-struktur-proyek)
- [Panduan Instalasi & Menjalankan Aplikasi](#-panduan-instalasi--menjalankan-aplikasi)
- [Profil Pengembang](#-profil-pengembang)
- [Lisensi](#-lisensi)

---

## 📖 Tentang PresenSync

**PresenSync** adalah aplikasi presensi mobile generasi baru yang memadukan verifikasi biometrik lokasi (*High-Accuracy GPS Geofencing*) dengan sinkronisasi waktu server terdistribusi. Aplikasi ini dikembangkan untuk mengeliminasi celah kecurangan absensi tradisional (seperti manipulasi jam lokal smartphone atau penggunaan aplikasi *Fake GPS*), sekaligus menghadirkan antarmuka pengguna (UI/UX) yang intuitif, responsif, dan elegan.

---

## 🎨 Identitas Visual & Branding

PresenSync mengusung identitas visual modern bertema **Luxury Emerald Forest** dengan perpaduan warna dan tipografi berkontras tinggi:

| Elemen | Spesifikasi | Penerapan |
| :--- | :--- | :--- |
| **Logo Utama** | Pin Lokasi dengan Jam & Orbit Satelit | Digunakan sebagai *Launcher Icon* resmi Android (`flutter_launcher_icons`), Cold Launch Background, Splash Screen, dan Login Header. Menggantikan seluruh logo bawaan Flutter. |
| **Two-Tone Wordmark** | `Presen` (Ijo Tua `#034A36`) + `Sync` (Ijo Cerah `#00B377`) | Tipografi kode native (*zero image pixelation*) berbasis font `Plus Jakarta Sans`, diterapkan pada Splash Screen, Login, dan Header Dashboard. |
| **Sweeping Shimmer Animation** | Specular Light Beam (FoodCura Style) | Efek sapuan kilau cahaya (*animated shimmer sweep*) dari kiri ke kanan yang menyinari teks merek `PresenSync` secara dinamis saat splash screen memuat data sesi. |
| **Launcher Icon** | Adaptive Android Icon (`#064E3B` Background) | Ikon adaptif di seluruh launcher Android (HDPI hingga XXXHDPI) dengan latar belakang hijau zamrud tua. |

---

## ✨ Fitur Utama & Keunggulan

### 1. 📍 Validasi Presensi Geofencing Presisi Tinggi
* **Radius Resmi**: Memvalidasi lokasi peserta berada dalam radius aman (1000 meter) dari titik koordinat kantor PPKD Jakarta.
* **Deteksi Anti-Mock GPS**: Mendeteksi dan menolak koordinat tiruan dari aplikasi pihak ketiga (*Fake GPS / Location Spoofer*) via atribut `position.isMocked`.
* **High-Accuracy Fallback**: Mengombinasikan `getCurrentPosition` (akurasi tinggi) dengan fallback aman `getLastKnownPosition` untuk mencegah *timeout* di dalam ruangan.

### 2. ⏱️ Sinkronisasi Waktu Server Terpadu (*Anti-Time Tampering*)
* **Server Time Sync**: Menghitung selisih (*offset*) waktu perangkat dengan HTTP `Date` Header server resmi pada setiap permintaan jaringan.
* Waktu Check-In, Check-Out, dan jam digital (*Live Ticking Clock*) selalu merujuk pada waktu server aktual, kebal terhadap rekayasa jam/tanggal di pengaturan smartphone.

### 3. 🛡️ Proteksi Konflik Status & Anti-Race Condition
* **Debounce Guard**: Proteksi mutlak dari penekanan tombol berkali-kali secara simultan (*double tap / spam submit*).
* **State Conflict Guard**: Memvalidasi dan memblokir pengajuan izin sakit/keperluan bila pengguna sudah tercatat melakukan check-in di hari yang sama, mencegah tabrakan data (*inconsistent state*).

### 4. 📊 Dashboard KPI & Pelacakan Kehadiran Interaktif
* **Executive Milestone Benchmark Hub**: Visualisasi performa kehadiran horizontal proporsional berstandar kelulusan PPKD (80%).
* **Jam Digital Live**: Tampilan jam, menit, dan detik yang berdetak *real-time* dengan penanda waktu server.
* **Filter Riwayat Lengkap**: Penyaringan riwayat, badge status semantik (Hijau untuk Masuk, Biru untuk Lengkap, Amber untuk Izin), dan fitur *Pull-to-Refresh* yang mulus.

### 5. 📷 Manajemen Profil & Upload Berkas Izin
* Pengajuan surat keterangan izin terintegrasi kamera dan galeri perangkat.
* Pembaruan foto profil pengguna secara langsung dengan kompresi gambar otomatis.

### 6. 🌓 Desain Modern & Adaptif (Light & Dark Mode)
* Mendukung tema Terang (*Light Mode*) dan Gelap (*Deep Slate Dark Mode*) dengan kontras ramah mata berstandar WCAG.

---

## 📐 Pembaruan UI/UX & Prinsip Desain

Berdasarkan evaluasi terhadap prinsip proporsi, hierarki visual, dan *cognitive load*:

1. **Eliminasi Lingkaran Gauge yang Terdistorsi**:
   * Menghapus speedometer/circular arc gauge yang memakan ruang horizontal secara asimetris dan menyebabkan teks terpotong atau bertumpuk.
2. **Penerapan Linear Milestone Benchmark**:
   * Menggunakan bilah progres horizontal proporsional (*100% full card width*) dengan indikator pin patokan **Target 80% Kelulusan PPKD**.
   * Menampilkan rasio kehadiran yang jelas (`1 dari 2 Hari Terdata`) dan evaluasi langsung tanpa kebingungan grafis.
3. **Harmoni Warna Tema (Tanpa Washed-out Tint)**:
   * Menghilangkan pewarnaan latar belakang merah/cokelat keruh yang merusak tema dark mode emerald. Kartu tetap mempertahankan estetika *dark luxury card*, sementara status peringatan (*Perlu Evaluasi*) ditempatkan secara terarah pada lencana, bilah progres, dan ikon diagnostik.
4. **Penghapusan Redundansi Konten**:
   * Menghilangkan banner evaluasi ganda di bagian bawah layar yang mengulang informasi yang sama, sehingga alur halaman menjadi bersih, ringkas, dan fokus.

---

## 🏛️ Arsitektur & Diagram Sistem

Aplikasi dibangun menggunakan pola **Provider State Management (MVVM)** dengan pemisahan tanggung jawab (*Separation of Concerns*):

```mermaid
graph TD
    A[User / UI View Layer] -->|Dispatch Actions| B[ViewModel / Provider Layer]
    B -->|Request Data| C[Data & Services Layer]
    C -->|HTTP API / REST| D[(Backend Server PPKD)]
    C -->|GPS / Geolocation| E[Hardware GPS & Geocoder]
    C -->|Persistent Cache| F[SharedPreferences]
    
    subgraph Core Engines
        G[ServerTimeSync Engine]
        H[Geofence & Anti-Mock Validator]
        I[Conflict & Race-Condition Guard]
    end
    
    C --> G
    C --> H
    B --> I
```

---

## 🔒 Mitigasi Keamanan & Anti-Fraud

| Potensi Ancaman / Celah | Dampak pada Sistem Tradisional | Solusi Rekayasa di PresenSync |
| :--- | :--- | :--- |
| **Manipulasi Jam HP** | Pengguna memundurkan jam HP agar tidak terhitung terlambat. | **`ServerTimeSync`**: Menghitung selisih milidetik waktu server via *HTTP Date Header*. Jam lokal HP diabaikan. |
| **Aplikasi Fake GPS** | Titik lokasi dipalsukan dari rumah seolah berada di kelas PPKD. | **`isMocked Checking`**: Mendeteksi bendera mock location sistem operasi dan otomatis menggagalkan absensi. |
| **Spam / Double Submit** | Dua request terkirim bersamaan sehingga server menerima data duplikat. | **Atomic Processing Lock**: Menutup akses tombol dan menampilkan indikator loading transparan saat request aktif. |
| **Konflik Izin & Masuk** | User absen masuk jam 08:00, lalu jam 10:00 mengajukan izin di hari yang sama. | **Same-Day Conflict Blocker**: Mencegah form izin disubmit dan menampilkan peringatan visual jika check-in sudah ada. |
| **Session Leak** | Data sesi user A tertinggal saat user B login di perangkat yang sama. | **Explicit Provider Teardown**: Memanggil `reset()` pada seluruh state saat proses logout berlangsung. |

---

## 📁 Struktur Proyek

```text
absensi_ppkd/
├── android/                   # Konfigurasi Native Android (com.fauzil.presensync)
│   └── app/src/main/res/      # Icon launcher mipmap & drawable cold splash
├── assets/
│   ├── fonts/                 # Font Plus Jakarta Sans (Regular - ExtraBold)
│   ├── icons/                 # Ikon resmi PresenSync (app_logo.png)
│   └── images/                # Asset gambar & branding
├── lib/
│   ├── core/
│   │   ├── constants/         # URL API, Koordinat Geofence PPKD, Dimensi
│   │   ├── theme/             # Token Palet Warna (AppColors) & AppTheme
│   │   └── utils/             # LocationHelper, DateFormatter, Dialogs
│   ├── data/
│   │   ├── models/            # UserModel, AttendanceModel, dsb.
│   │   └── services/          # DioClient, AuthApiService, AttendanceApiService
│   ├── viewmodels/            # AuthProvider, AttendanceProvider, ThemeProvider
│   ├── views/
│   │   ├── attendance/        # CheckInScreen, CheckOutScreen, LeavePermitScreen
│   │   ├── auth/              # LoginScreen, RegisterScreen
│   │   ├── dashboard/         # DashboardScreen, MainNavigationScreen
│   │   ├── history/           # AttendanceHistoryScreen, AttendanceDetailScreen
│   │   ├── profile/           # ProfileScreen, EditProfileScreen
│   │   ├── splash/            # Animated SplashScreen (Sweeping Shimmer)
│   │   └── stats/             # AttendanceStatsScreen (Milestone Benchmark Hub)
│   ├── widgets/               # StatCard, LiveClockCard, CustomButton, dsb.
│   └── main.dart              # Titik Masuk Utama (Root Widget)
├── test/                      # 17 Unit, Widget & Logic Test Cases
└── pubspec.yaml               # Metadata Proyek & Asset Declarations
```

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

### 1. Prasyarat Sistem
* **Flutter SDK**: `^3.12.0` atau versi terbaru ([Panduan Instalasi Flutter](https://docs.flutter.dev/get-started/install))
* **Dart SDK**: `^3.x`
* **Android Studio / VS Code** dengan ekstensi Flutter & Dart
* Perangkat Android fisik atau Emulator dengan Google Play Services aktif

### 2. Kloning Repositori
```bash
git clone https://github.com/username/presensync.git
cd presensync
```

### 3. Mengunduh Dependensi
```bash
flutter pub get
```

### 4. Menghasilkan Ikon Aplikasi Resmi
```bash
dart run flutter_launcher_icons
```

### 5. Konfigurasi Google Maps API Key
Pastikan API Key telah terkonfigurasi pada berkas `android/local.properties`:
```properties
GOOGLE_MAPS_API_KEY=AIzaSyDk_IqTjxDnhlwFcVf8bYfNR0qBtEGAyJw
```

### 6. Menjalankan Mode Pengujian
```bash
# Menjalankan static analysis (linter)
flutter analyze

# Menjalankan unit & widget test
flutter test
```

### 7. Menjalankan Aplikasi
```bash
flutter run
```

### 8. Membangun Berkas APK Rilis
```bash
flutter build apk --release
```
Berkas APK siap didistribusikan pada direktori `build/app/outputs/flutter-apk/app-release.apk`.

---

## 👨‍💻 Profil Pengembang

* **Nama Pengembang**: **Fauzil**
* **Application ID**: `com.fauzil.presensync`
* **Program Pelatihan**: Mobile Application Development
* **Institusi**: **PPKD (Pusat Pelatihan Kerja Daerah)**

---

## 📄 Lisensi

Proyek ini dikembangkan untuk kebutuhan tugas pelatihan kerja di PPKD Jakarta. Hak Cipta dilindungi undang-undang © 2026 **PresenSync by Fauzil**.
