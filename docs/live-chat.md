# Live chat Top Mortar

Chat CS tersedia pada kartu bantuan Beranda dan tombol bantuan tab Akun. Layar Flutter menyiapkan sesi, menampilkan status koneksi dan tombol coba lagi/batal. Percakapan memakai layar native HaloChat: riwayat pesan, lampiran kamera/galeri/dokumen, status pengiriman, retry, serta realtime dengan polling fallback ditangani SDK.

## Dependensi dan build

Folder `halochat-sdk/` hanya referensi dokumentasi awal, sudah diabaikan oleh `.gitignore`, dan tidak dipakai saat build. Folder tersebut boleh tidak ada pada checkout/CI. Tidak ada server key HaloChat di aplikasi.

- Android: `com.github.afgventura.halochat-android:halochat-ui:0.2.1` melalui JitPack. Gradle membatasi repositori JitPack pada group SDK tersebut. Minimum aplikasi mengikuti Flutter (SDK Flutter saat integrasi: Android API 24); HaloChat sendiri mendukung API 21+. Compile SDK 36 dan Java 17.
- iOS: CocoaPods `HaloChat/UI` dari `https://github.com/afgventura/halochat-ios.git`, tag `0.2.0`. Versi dan checksum podspec dicatat dalam `ios/Podfile.lock`. Minimum iOS **15.0**, sesuai SDK. Pengguna iOS 13/14 tidak lagi termasuk target versi ini.
- Tidak ada paket Dart tambahan. Checkout bersih memerlukan akses internet ke pub.dev, Google/Maven Central, JitPack, GitHub dan CocoaPods untuk mengambil dependensi.

```sh
flutter pub get
cd ios
pod install
cd ..
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

Untuk iPhone fisik, buka workspace iOS di Xcode dan gunakan signing/provisioning milik proyek. Kamera membutuhkan perangkat fisik; simulator dapat menguji dokumen dan gambar yang tersedia.

## Kontrak backend

[`LiveChatApi`](../lib/services/live_chat_api.dart) menggunakan host `baseUrl` pada [konfigurasi API](../lib/services/api.dart):

```http
POST /api/livechat/get-token
Content-Type: application/json
Accept: application/json
Cache-Control: no-store
```

Body diambil dari `ContactModel` akun aktif, bukan data contoh yang ditanam di aplikasi:

```json
{
  "id_contact": "2726",
  "nama": "Trial Toko Bangunan Rafli",
  "nomorhp": "62895636998639"
}
```

Response yang diharapkan:

```json
{
  "code": 200,
  "status": "ok",
  "msg": "Success get token",
  "data": {
    "token": "hct_...",
    "expiresAt": "2026-11-29T09:31:05.815Z",
    "roomId": "01a16321..."
  }
}
```

Token harus berupa client token `hct_`, belum kedaluwarsa, dan memiliki room ID. Server key `hck_` hanya disimpan backend. Saat SDK meminta refresh, aplikasi memanggil endpoint POST yang sama lagi; backend harus memberikan token baru yang valid. Jangan menyimpan hasil endpoint dalam cache CDN/proxy.

Kontrak yang diberikan belum mencakup Bearer token atau cookie. Aplikasi mengirim tiga field body di atas sesuai kontrak; backend tetap bertanggung jawab memverifikasi identitas peminta sebelum menerbitkan token.

Pada 29 Oktober 2026, request dengan data contoh ke host development `devseller.topmortarindonesia.com` dari lingkungan pengembangan ini ditolak Cloudflare dengan HTTP 403 / error 1010 (`browser_signature_banned`). Ini belum merupakan pengujian berhasil ke backend HaloChat. Tim pemilik domain perlu memeriksa aturan akses API; jangan menonaktifkan verifikasi sertifikat TLS untuk mengatasinya. Tidak ada pesan yang dikirim ke CS selama pemeriksaan ini.

## Struktur kode

- [`live_chat_api.dart`](../lib/services/live_chat_api.dart): POST token, parsing response, timeout, error aman, backoff 429. Koneksi chat memverifikasi TLS meskipun aplikasi mempunyai `HttpOverrides` lama.
- [`live_chat_service.dart`](../lib/services/live_chat_service.dart): cache token hanya di memori, refresh, penggabungan request token bersamaan, validasi akun aktif dan penghubung native.
- [`live_chat_screen.dart`](../lib/screen/live_chat/live_chat_screen.dart): loading, pembatalan, retry, dan pesan gagal.
- [`live_chat_card.dart`](../lib/widget/dashboard/live_chat_card.dart): kartu bantuan di Beranda.
- [`LiveChatPlugin.kt`](../android/app/src/main/kotlin/com/example/mytopseller/LiveChatPlugin.kt): lifecycle Android, presentasi SDK dan callback token.
- [`LiveChatBridge.swift`](../ios/Runner/LiveChatBridge.swift): presentasi layar iOS dan callback token.

MethodChannel `com.topmortar.seller/live_chat`:

| Arah | Metode | Argumen / hasil |
| --- | --- | --- |
| Flutter → native | `setUser` | `{userId}` |
| Flutter → native | `openChat` | Selesai setelah layar native tampil |
| Flutter → native | `clearUser` | Hapus sesi lokal segera; pencabutan server best effort |
| Native → Flutter | `getToken` | `{userId, forceRefresh}` → client token |

Tidak ada pesan pembuka otomatis. Menutup chat mengembalikan pengguna ke halaman sebelumnya. Warna merah digunakan untuk header/tombol; gelembung pengguna merah muda dengan teks gelap agar waktu pesan dan status baca tetap terlihat.

Logout dan pengajuan penghapusan akun memakai `removeLoginState`, yang juga menghapus sesi chat. Respons token terlambat tidak boleh membuka chat atau mengembalikan sesi akun sebelumnya. Pencabutan sesi server dibatasi waktunya agar pengguna tetap dapat logout saat offline.

## Pengujian

Tes otomatis mencakup kontrak POST, parsing/masa berlaku token, respons tidak valid, pembatasan request, token refresh, pemisahan akun, logout ketika request berjalan, pembatalan, retry, dan navigasi kembali. Tes memakai mock; tidak mengirim pesan atau menyimpan token backend.

Hasil validasi implementasi: suite Flutter yang sudah ada beserta integrasi lulus, lalu seluruh regresi tambahan lulus (6 tes API, 10 tes sesi, 5 tes widget chat). Analisis statis kode integrasi bersih. Build APK debug Android dan build simulator iOS arm64 dengan signing dinonaktifkan berhasil menggunakan dependensi remote. Ini belum menggantikan pengujian percakapan pada perangkat dengan akses backend yang diizinkan.

Setelah backend dapat diakses, jalankan smoke test pada Android dan iOS:

1. Login, buka Chat CS dari Beranda dan Akun; tombol kembali harus kembali ke halaman asal.
2. Kirim pesan dan pastikan balasan CS tampil; buka ulang chat untuk memeriksa riwayat.
3. Kirim foto/dokumen; coba menolak izin kamera dan membuka file tidak didukung.
4. Putuskan internet, coba kirim lalu pulihkan koneksi; retry tidak boleh menggandakan pesan.
5. Uji token kedaluwarsa dan login ulang, serta logout/login akun berbeda agar riwayat tidak tertukar.
6. Uji keyboard, layar kecil, text scaling perangkat, dan keluar/masuk aplikasi saat chat terbuka.

## Notifikasi latar belakang

Integrasi ini mendukung chat saat layar chat dibuka. Push chat saat aplikasi berada di latar belakang belum diaktifkan karena membutuhkan konfigurasi Firebase Android/APNs iOS dan kredensial backend HaloAI. Layanan notifikasi lokal aplikasi yang sudah ada tetap berjalan. Riwayat chat dimuat lagi saat layar chat dibuka.
