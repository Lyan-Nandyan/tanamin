import 'package:flutter/material.dart';

class WeatherInfo extends StatelessWidget {
  final String weather;

  const WeatherInfo({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Text(weather);
  }
}
