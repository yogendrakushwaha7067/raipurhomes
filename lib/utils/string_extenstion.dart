import 'package:intl/intl.dart';

extension StringExtention<T extends String> on T {
  // T firstUpperCase() {
  //   String upperCase = "";
  //   var suffix = "";
  //   if (isNotEmpty) {
  //     upperCase = this[0].toUpperCase();
  //     suffix = substring(1, length);
  //   }
  //   return (upperCase + suffix) as T;
  // }

  ///Number with suffix 10k,10M ,1b
  String priceFormate({bool? disabled}) {
    String formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 2,
      symbol:
          '', // if you want to add currency symbol then pass that in this else leave it empty.
    ).format(num.parse(this));

    if (disabled == true) {
      return toString();
    }

    return formattedNumber;
  }
}
