import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatINR(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
