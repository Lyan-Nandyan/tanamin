import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConverterService {
  static const List<String> _currencySymbols = [
    'Rp', // IDR
    '\$', // USD
    '€', // EUR
    '£', // GBP
    '¥', // JPY
    'S\$', // SGD
    'A\$', // AUD
  ];
  static const List<String> _currencyCodes = [
    'IDR',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'SGD',
    'AUD'
  ];

  /// Konversi nilai [amount] dari IDR ke mata uang berdasarkan [option] (0-5).
  /// Mengembalikan nilai hasil konversi sebagai double.
  Future<double?> convertCurrency(double amount, int option) async {
    if (option < 0 || option >= _currencyCodes.length) {
      throw ArgumentError('Opsi tidak valid. Harus antara 0 sampai 6.');
    }

    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final targetCurrency = _currencyCodes[option];
      final rate = data['rates'][targetCurrency];

      if (rate != null) {
        debugPrint('Rate untuk $targetCurrency: $rate');
        // Menghitung nilai konversi
        debugPrint('Mengonversi $amount IDR ke $targetCurrency');
        debugPrint('Hasil konversi: ${amount * rate}');
        return amount * rate;
      } else {
        print('Rate untuk $targetCurrency tidak ditemukan.');
        return 0;
      }
    } else {
      print('Gagal mengambil data rate. Status: ${response.statusCode}');
      return 0;
    }
  }

  String getCurrencySymbols(int option) {
    return _currencySymbols[option];
  }
}
