import 'package:flutter/material.dart';
import '../models/city.dart';

class LocationHeader extends StatelessWidget {
  final City? city;

  const LocationHeader({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    if (city == null) return const SizedBox.shrink();

    final locationSubtitle = [city!.region, city!.country]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            city!.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          if (locationSubtitle.isNotEmpty)
            Text(
              locationSubtitle,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
