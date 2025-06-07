import 'package:flutter/material.dart';
import 'package:tanamin/core/service/currency_converter_service.dart';

class ConvertedPriceText extends StatelessWidget {
  final double amount;
  final int currencyOption;

  const ConvertedPriceText({
    super.key,
    required this.amount,
    required this.currencyOption,
  });

  @override
  Widget build(BuildContext context) {
    final currencyService = CurrencyConverterService();

    return FutureBuilder<double?>(
      future: currencyService.convertCurrency(amount, currencyOption),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Menghitung...', style: TextStyle(fontSize: 12));
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text('Gagal menghitung', style: TextStyle(color: Colors.red));
        } else {
          final symbol = currencyService.getCurrencySymbols(currencyOption);
          final converted = snapshot.data!;
          return Text(
            '$symbol${converted.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          );
        }
      },
    );
  }
}
