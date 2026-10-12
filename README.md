# Aplikasi Scan Surat Jalan dan GRN

Aplikasi Flutter untuk membantu proses pencatatan dokumen logistik, khususnya **Surat Jalan** dan **GRN (Goods Receipt Note)**. Repository ini berisi source code aplikasi dan konfigurasi untuk pengembangan menggunakan Flutter.

> **Status:** Dalam pengembangan. Detail fitur dapat berubah mengikuti implementasi aplikasi.

## Fitur dan teknologi

Berdasarkan dependency yang digunakan project saat ini, aplikasi disiapkan dengan dukungan:

- **Pemindaian barcode/QR code** menggunakan `mobile_scanner`.
- **Pengenalan teks dari gambar (OCR)** menggunakan Google ML Kit Text Recognition.
- **Pemilihan atau pengambilan gambar** melalui `image_picker`.
- **Pembuatan dokumen PDF** menggunakan package `pdf`.
- **Preview dan pencetakan PDF** menggunakan `printing`.
- **Tanda tangan digital** melalui package `signature`.
- **Penyimpanan preferensi lokal** menggunakan `shared_preferences`.
- **Penyimpanan file** dengan dukungan `path_provider` dan `public_file_saver`.

Ketersediaan fitur di atas bergantung pada bagian yang sudah diimplementasikan di source code aplikasi.

## Teknologi

- Flutter
- Dart
- Google ML Kit Text Recognition
- Mobile Scanner
- PDF dan Printing

## Persyaratan pengembangan

Sebelum menjalankan project, siapkan:

- Flutter SDK yang kompatibel dengan batas SDK di `pubspec.yaml`.
- Dart SDK yang disertakan dengan Flutter.
- Android Studio atau Visual Studio Code.
- Android SDK dan perangkat Android atau emulator untuk pengujian Android.

Periksa instalasi Flutter dengan:

```bash
flutter doctor
```

## Cara menjalankan project

1. Clone repository:

   ```bash
   git clone https://github.com/maru-ins/Aplikasi-Scan-Surat-Jalan-dan-GRN.git
   ```

2. Masuk ke folder project:

   ```bash
   cd Aplikasi-Scan-Surat-Jalan-dan-GRN
   ```

3. Unduh dependency:

   ```bash
   flutter pub get
   ```

4. Jalankan aplikasi pada perangkat atau emulator yang terhubung:

   ```bash
   flutter run
   ```

## Struktur folder

```text
.
├── android/       # Konfigurasi platform Android
├── assets/        # Aset aplikasi, termasuk ikon
├── ios/           # Konfigurasi platform iOS
├── lib/           # Source code utama Flutter
├── linux/         # Konfigurasi platform Linux
├── macos/         # Konfigurasi platform macOS
├── web/           # Konfigurasi platform web
├── windows/       # Konfigurasi platform Windows
├── pubspec.yaml   # Konfigurasi project dan dependency
└── README.md      # Dokumentasi project
```

## Build APK Android

Untuk membuat APK release:

```bash
flutter build apk --release
```

File hasil build biasanya tersedia di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Folder `build/` merupakan hasil kompilasi dan tidak perlu dimasukkan ke Git karena dapat dibuat kembali melalui perintah build.

## Catatan

- Pastikan izin kamera diberikan jika menggunakan pemindaian barcode atau OCR dari kamera.
- Uji fitur kamera, penyimpanan file, PDF, dan tanda tangan pada perangkat yang benar-benar akan digunakan.
- Jangan mengunggah password, token, private key, atau data dokumen perusahaan yang bersifat rahasia ke repository publik.
- Informasi mengenai lisensi dan kontribusi dapat ditambahkan sesuai kebijakan pemilik repository.

## Repository

Source code: https://github.com/maru-ins/Aplikasi-Scan-Surat-Jalan-dan-GRN
