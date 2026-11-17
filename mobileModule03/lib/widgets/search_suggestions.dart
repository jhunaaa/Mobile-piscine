import 'package:flutter/material.dart';
import '../models/city.dart';

class SearchSuggestionsOverlay extends StatelessWidget {
  final List<City> suggestions;
  final ValueChanged<City> onCitySelected;

  const SearchSuggestionsOverlay({
    super.key,
    required this.suggestions,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 12,
      right: 12,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final city = suggestions[index];
              final locationSubtitle = [city.region, city.country]
                  .where((s) => s.isNotEmpty)
                  .join(', ');
              return ListTile(
                dense: true,
                title: Text(
                  city.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: locationSubtitle.isNotEmpty
                    ? Text(locationSubtitle)
                    : null,
                onTap: () => onCitySelected(city),
              );
            },
          ),
        ),
      ),
    );
  }
}
