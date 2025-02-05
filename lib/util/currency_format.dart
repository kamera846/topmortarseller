import 'package:money_formatter/money_formatter.dart';

class CurrencyFormat {
  String format(double amount) {
    var formatted = MoneyFormatter(
      amount: amount,
      settings: MoneyFormatterSettings(
          symbol: 'Rp',
          thousandSeparator: '.',
          decimalSeparator: ',',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 0,
          compactFormatType: CompactFormatType.short),
    );
    return formatted.output.symbolOnLeft;
  }
}
