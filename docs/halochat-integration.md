# HaloChat: demo sekarang, backend asli nanti

Tombol chat di **home screen** membuka layar native HaloChat yang sama di Android
maupun iOS. Minimum iOS 15; Android mengikuti minimum Flutter. SDK tetap menangani
history, realtime, picker kamera/galeri/dokumen, upload, status pesan, dan retry.

Flutter minimum **3.41.0**. Lifecycle iOS sudah dimigrasikan ke UIScene, dengan
registrasi plugin dan MethodChannel pada `didInitializeImplicitFlutterEngine`.
Ini memperbaiki crash startup pada iOS 27/Xcode 27 akibat lifecycle lama; lihat
[panduan resmi Flutter](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate).

## Menjalankan demo

Build debug secara default memakai demo. Untuk memilih mode secara eksplisit:

```sh
flutter run --dart-define-from-file=config/halochat.demo.json
```

Login aplikasi seperti biasa, lalu tekan tombol chat di home. Mode ini tidak
membutuhkan endpoint token atau server key. Server dummy berjalan **di perangkat
yang sama**, hanya pada loopback localhost dengan port acak; tidak perlu komputer
server, IP LAN, emulator host alias, atau koneksi HaloAI.

Untuk mencoba tanpa akun toko, gunakan entry point preview yang terpisah:

```sh
flutter run -t tool/halochat_demo.dart --dart-define-from-file=config/halochat.demo.json
```

Preview langsung membuka SDK native dan menyediakan reset percakapan. Login dummy
hanya berada di memori, tidak menimpa login aplikasi yang tersimpan. Entry point ini
menolak mode live dan build selain debug; rilis aplikasi tetap memakai `lib/main.dart`.

Header bertuliskan **CS Top Mortar — Demo**. Percakapan awal menjelaskan bahwa data
adalah contoh, bukan layanan pelanggan sungguhan. Coba:

| Tindakan | Hasil demo |
| --- | --- |
| Kirim `pesanan`, `produk`, `pembayaran` | Balasan otomatis memakai data fiktif |
| Kirim pesan biasa | Balasan otomatis lokal |
| Kirim foto/dokumen | Upload dan buka kembali file melalui SDK native |
| Kirim `/retry` | Percobaan pertama gagal 503; ketuk pesan untuk retry, tanpa duplikasi |
| Kirim `/refresh` | Token lokal kedaluwarsa dan socket ditutup; SDK meminta token baru lalu tersambung kembali |
| Tutup lalu buka chat | History tetap ada dalam sesi yang sama |
| Logout atau restart aplikasi | Server dummy dan history di memori dihapus, sesi berikutnya mulai bersih |

Balasan muncul sekitar 800 ms setelah kirim. Maksimum lampiran 25 MB per file,
50 MB total dan 50 upload per sesi demo; logout untuk mereset. Validasi jenis file
mengikuti UI SDK. Demo bukan replika lengkap kebijakan server HaloAI.

Preview/cache file native mengikuti perilaku SDK dan OS. ID pesan demo unik per
sesi agar cache gambar sesi lama tidak ditampilkan pada percakapan baru.

Tidak ada password aplikasi yang dikirim ke server dummy, dan token `hct_demo_…`
tidak dikirim ke HaloAI. Demo hanya diizinkan pada **debug** oleh Dart dan native.
Build profile/release default ke live; memilih demo pada profile/release ditolak.
Android mengizinkan HTTP localhost hanya lewat manifest debug. iOS mengizinkan
local networking; URL demo hanya dapat dipakai oleh bridge dalam kompilasi DEBUG.

## Mengaktifkan backend asli

1. Tim backend implementasikan kontrak di bawah dan simpan `hck_…` di secret store
   backend. Server key tidak pernah masuk aplikasi atau dart-define.
2. Salin [konfigurasi live contoh](../config/halochat.live.example.json) menjadi
   `config/halochat.live.json`. Ganti `HALOCHAT_TOKEN_URL` dengan endpoint HTTPS
   yang benar. URL contoh merupakan kontrak yang diusulkan, **belum dianggap aktif**.
3. Jalankan/debug dan build dengan konfigurasi yang sama:

```sh
flutter run --dart-define-from-file=config/halochat.live.json
flutter build appbundle --dart-define-from-file=config/halochat.live.json
flutter build ipa --dart-define-from-file=config/halochat.live.json
```

`HALOCHAT_MODE` wajib `live`. `HALOCHAT_TOKEN_URL` menerima endpoint HTTPS lengkap
(staging atau production); URL tidak boleh berisi username/password, query atau
fragment. Alternatif lama `HALOCHAT_TOKEN_PATH=/api/halochat/token` tetap didukung
pada host API aplikasi; URL lengkap mengambil prioritas bila keduanya diisi.
Perubahan dart-define memerlukan restart/build ulang, bukan hot reload.

Jika mode live tidak dikonfigurasi, aplikasi menampilkan “Layanan chat belum
tersedia”; tidak diam-diam beralih ke demo. Request live memverifikasi sertifikat
TLS meskipun aplikasi lama mempunyai HttpOverrides global.

## Kontrak untuk tim backend

Spesifikasi mesin: [OpenAPI](./halochat-backend.openapi.yaml).
Adapter aplikasi: [HaloChatTokenApi](../lib/services/halochat/halochat_token_api.dart).
Jika autentikasi final tim berbeda (misalnya session bearer), ubah adapter dan
pemanggil credential-nya; SDK native tidak perlu diubah.

Request yang diusulkan, mengikuti login aplikasi saat ini:

```http
POST /api/halochat/token
Content-Type: application/json
Accept: application/json
```

```json
{"nomorhp":"08000000000","pass_contact":"dummy-password","forceRefresh":false}
```

Backend wajib memverifikasi akun dengan mekanisme login yang sama, membatasi
percobaan, dan tidak mencatat password/token ke log. Tentukan ID kontak, nama toko,
serta nomor telepon dari akun terautentikasi, bukan dari identitas yang diklaim
client. Contoh urutan implementasi backend (pseudocode, bukan server siap deploy):

```text
account = authenticate(nomorhp, pass_contact)             // gagal: HTTP 401
identity = stableIdentity(account)                      // mis. contact:123
result = POST https://www.haloai.co.id/api/open/inApp/v1/clientToken
  Authorization: Bearer <server key dari secret store>
  JSON: {externalUserId: identity, displayName: account.storeName,
         phone: account.registeredPhoneIn62Format}
return HTTP 200 {data: {token: result.data.token,
                       expiresAt: result.data.expiresAt,
                       roomId: result.data.roomId}}
```

`externalUserId` harus stabil dan unik (sertakan distributor bila ID kontak hanya
unik per distributor), maksimum 128 karakter, hanya karakter yang diterima API.
Channel Top Mortar sudah ditentukan oleh server key; channel ID tidak diperlukan
dalam aplikasi. Lihat [API resmi yang disertakan SDK](../halochat-sdk/API.md).

Backend boleh selalu mint token baru pada endpoint ini. Bila mengimplementasikan
cache, cache harus per perangkat/sesi dan `forceRefresh: true` wajib mengabaikan
cache token yang ditolak. Saat ini request tidak membawa device-session ID,
sehingga **mint per request** adalah pilihan sederhana. Jangan memakai cache satu
token untuk seluruh perangkat pengguna. Aplikasi tidak meminta token baru setiap
membuka ulang chat; SDK meminta lagi bila perlu refresh.

Response sukses (nilai di bawah contoh, bukan kredensial yang valid):

```json
{"data":{"token":"hct_example_not_valid","expiresAt":"2030-01-01T00:00:00Z","roomId":"example-room"}}
```

| HTTP | Makna | Perilaku aplikasi |
| --- | --- | --- |
| 200 | `data.token` berupa client token `hct_…` | Buka chat / lanjutkan refresh |
| 401 / 403 | Akun tidak terautentikasi atau akses ditolak | Minta pengguna login kembali |
| 429 | Terlalu banyak percobaan | Pesan untuk mencoba sebentar lagi |
| 5xx / timeout / response tidak valid | Backend atau HaloAI gagal | Pesan gagal terhubung; dapat dicoba kembali |

`hck_…`, HTML, data kosong, atau token tidak valid ditolak aplikasi. Respons/error
mentah backend tidak ditampilkan kepada pengguna. Pada penghapusan akun atau force
logout, backend perlu memanggil HaloAI `POST /api/open/inApp/v1/revokeUser` dengan
ID stabil yang sama. Logout perangkat biasa sudah memanggil `DELETE /session`
melalui SDK; revokasi saat offline tetap best-effort.

## Yang masih perlu disediakan sebelum live

- Endpoint HTTPS sesuai kontrak, autentikasi pengguna, rate limit, dan server key
  channel Top Mortar dalam secret store backend.
- Mapping ID kontak/toko/telepon yang stabil dan integrasi revokasi saat akun dihapus.
- Uji kirim/balas melalui inbox HaloAI menggunakan akun uji asli, termasuk refresh,
  logout, perpindahan akun, offline/retry, kamera, dokumen, serta Android/iOS fisik.
- Push background adalah pekerjaan terpisah di bawah; demo tidak mensimulasikan
  keberhasilan pengiriman push provider.

## Push background: persiapan yang belum bisa digantikan dummy

Aplikasi belum memasang Firebase Messaging atau memiliki konfigurasi APNs untuk
HaloChat. Notifikasi lokal aplikasi tetap bekerja seperti sebelumnya. Untuk
mengaktifkan push end-to-end, sediakan:

| Android | iOS |
| --- | --- |
| Firebase project dan `google-services.json` untuk application ID aplikasi | Bundle ID, Team ID, capability Push Notifications dan provisioning yang cocok |
| Firebase service-account credential **di sisi HaloAI/server**, bukan aplikasi | APNs `.p8`, Key ID, Team ID, environment development/production **di sisi HaloAI/server** |
| Firebase Messaging listener dan token FCM | Registrasi remote notifications dan token APNs (bukan token FCM) |

Kemudian implementasikan registrasi token ke SDK setelah login/pergantian token,
foreground handling, tap routing (termasuk cold start setelah login pulih), dan
permission notification. Payload HaloAI: `type=halochat_message`, `roomId`,
`messageId`. Petunjuk native lengkap ada di [Android](../halochat-sdk/halochat-android/README.md)
dan [iOS](../halochat-sdk/halochat-ios/README.md). Jangan mengganti kredensial push
provider dengan nilai dummy pada release.

## Verifikasi dan build lokal

```sh
flutter test
flutter analyze lib/services/halochat lib/services/halochat_service.dart test
flutter build apk --debug --dart-define-from-file=config/halochat.demo.json
```

Test menjalankan server dummy pada localhost dan memeriksa auth, history/pagination,
WebSocket, retry/idempotency, upload/download, revokasi dan pemisahan sesi. Adapter
live diuji dengan response backend tiruan, tanpa menghubungi production.

Dengan Flutter 3.41.2 dan Xcode 27, pengemasan simulator multiarsitektur dapat gagal
meskipun framework berisi arm64 dan x86_64. Setelah konfigurasi Flutter/pod install,
verifikasi simulator Apple Silicon secara eksplisit:

```sh
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build
```

SDK Android lokal dan sample-nya memakai AGP 8.9.1 agar kompatibel dengan composite
build aplikasi. Ini tidak mengubah versi API HaloChat.
