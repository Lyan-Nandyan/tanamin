import 'package:flutter/material.dart';
import '../../../widgets/search_plant.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Cari tanaman...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        style: const TextStyle(color: Colors.black),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPlant()),
        ),
      ),
    );
  }
}
