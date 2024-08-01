class Validator {
  static String? phoneAuth(String value) {
    final RegExp phoneRegExp = RegExp(r'^(?:\+62|62)?(0?[1-9][0-9]{8,12})$');
    if (value.isEmpty) {
      return 'Nomor telpon harus diisi!';
    } else if (!phoneRegExp.hasMatch(value)) {
      return 'Masukkan nomor telpon yang valid!';
    }
    return null;
  }

  static String? passwordAuth(String value) {
    if (value.isEmpty) {
      return 'Kata sandi harus diisi!';
    } else if (value.trim().length < 6) {
      return 'Panjang kata sandi minimal 6 karakter!';
    }
    return null;
  }
}
