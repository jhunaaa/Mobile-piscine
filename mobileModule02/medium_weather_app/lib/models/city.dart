class City {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  City({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    String regionName = json['admin1'] as String? ??
        json['admin2'] as String? ??
        json['admin3'] as String? ??
        '';

    return City(
      name: json['name'] as String? ?? '',
      region: regionName,
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get displayName {
    List<String> parts = [];
    if (name.isNotEmpty) parts.add(name);
    if (region.isNotEmpty) parts.add(region);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}
