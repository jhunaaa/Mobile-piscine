import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city.dart';
import '../models/weather.dart';

class WeatherService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  Future<List<City>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
        '$_geocodingBaseUrl?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('results') && data['results'] != null) {
          final results = data['results'] as List<dynamic>;
          return results.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<WeatherData> getWeatherData(double lat, double lon) async {
    final url = Uri.parse(
        '$_weatherBaseUrl?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(data);
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  Future<City> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        String cityName = (data['city'] as String?)?.isNotEmpty == true
            ? data['city'] as String
            : (data['locality'] as String?)?.isNotEmpty == true
                ? data['locality'] as String
                : 'Current Location';
        String region = data['principalSubdivision'] as String? ?? '';
        String country = data['countryName'] as String? ?? '';

        return City(
          name: cityName,
          region: region,
          country: country,
          latitude: lat,
          longitude: lon,
        );
      }
    } catch (_) {}

    return City(
      name: 'Current Location',
      region: '',
      country: '',
      latitude: lat,
      longitude: lon,
    );
  }
}
