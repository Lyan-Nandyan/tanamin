import 'package:flutter/material.dart';
import '../../../widgets/search_plant.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Search Plants...',
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.black),
      ),
      style: const TextStyle(color: Colors.black),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchPlant()),
      ),
    );
  }
}
