import 'package:money_formatter/money_formatter.dart';

class CurrencyFormat {
  String format({required double amount, int? fractionDigits}) {
    try {
      var formatted = MoneyFormatter(
        amount: amount,
        settings: MoneyFormatterSettings(
          symbol: 'Rp',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: fractionDigits ?? 0,
          compactFormatType: CompactFormatType.short,
        ),
      );
      return formatted.output.symbolOnLeft;
    } catch (e) {
      return '-';
    }
  }
}
