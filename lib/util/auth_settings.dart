import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/util/enum.dart';

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
    'Masukkan nomor untuk mendapatkan kode otp reset password.',
    'Dapatkan OTP',
    'Sudah ingat sandi anda?',
    'Masuk Sekarang!',
  ),
  AuthType.otp: AuthSettingsModel(
    'Masukkan Kode OTP',
    'Kode otp sudah dikirim ke nomor tujuan.',
    'Lanjutkan',
    null,
    null,
  ),
  AuthType.resetPassword: AuthSettingsModel(
    'Reset Password',
    'Simpanlah password anda agar tidak lupa.',
    'Reset Sekarang',
    null,
    null,
  ),
};

Future<void> saveLoginState(String phone, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(GlobalEnum.isLoggedIn.toString(), true);
  await prefs.setString(GlobalEnum.loggedInPhone.toString(), phone);
  await prefs.setString(GlobalEnum.loggedInPassword.toString(), password);
}

Future<bool> getLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final loginState = prefs.getBool(GlobalEnum.isLoggedIn.toString());
  if (loginState != null) {
    return loginState;
  }
  return false;
}

Future<String> getLoginPhone() async {
  final prefs = await SharedPreferences.getInstance();
  final loginPhone = prefs.getString(GlobalEnum.loggedInPhone.toString());
  if (loginPhone != null) {
    return loginPhone;
  }
  return '';
}

Future<String> getLoginPassword() async {
  final prefs = await SharedPreferences.getInstance();
  final loginPassword = prefs.getString(GlobalEnum.loggedInPassword.toString());
  if (loginPassword != null) {
    return loginPassword;
  }
  return '';
}

Future<void> removeLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(GlobalEnum.isLoggedIn.toString());
  await prefs.remove(GlobalEnum.loggedInPhone.toString());
  await prefs.remove(GlobalEnum.loggedInPassword.toString());
}
