import 'package:flutter/material.dart';

class LocationInfo extends StatelessWidget {
  final String location;

  const LocationInfo({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Text(location);
  }
}
