import 'package:flutter/material.dart';

class LocationInfo extends StatelessWidget {
  final String location;

  const LocationInfo({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.green, size: 22),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            location.isNotEmpty ? location : 'Lokasi tidak diketahui',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
