import 'package:topmortarseller/models/auth_settings_model.dart';

const authSettings = {
  AuthType.login: AuthSettingsModel(
    'Top Mortar Seller',
    'Gunakan akun yang terdaftar untuk melanjutkan.',
    'Masuk',
    'Belum punya akun?',
    'Daftar Sekarang!',
  ),
  AuthType.register: AuthSettingsModel(
    'Daftar Akun',
    'Cek terlebih dahulu apakah nomor anda sudah terdaftar.',
    'Cek Nomor',
    'Sudah punya akun?',
    'Masuk Sekarang!',
  ),
  AuthType.forgot: AuthSettingsModel(
    'Reset Password',
    'Masukan nomor untuk mendapatkan kode otp reset password.',
    'Dapatkan OTP',
    'Sudah ingat sandi anda?',
    'Masuk Sekarang!',
  )
};
