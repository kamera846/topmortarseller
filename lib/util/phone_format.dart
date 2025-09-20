class MyPhoneFormat {
  static String format(String phone) {
    try {
      phone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (phone.startsWith('+62')) {
        phone = phone.substring(3);
      } else if (phone.startsWith('62')) {
        phone = phone.substring(2);
      } else if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }

      final part1 = phone.substring(0, 4);
      final part2 = phone.substring(4, 8);
      final part3 = phone.substring(8);

      return '(+62) $part1-$part2-$part3';
    } catch (e) {
      return '-';
    }
  }
}
