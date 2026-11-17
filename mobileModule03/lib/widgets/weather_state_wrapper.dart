import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/weather.dart';

class WeatherStateWrapper extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final WeatherData? weatherData;
  final City? selectedCity;
  final Widget Function(WeatherData weatherData, City selectedCity) builder;

  const WeatherStateWrapper({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.weatherData,
    required this.selectedCity,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (weatherData == null || selectedCity == null) {
      return const Center(
        child: Text(
          'Search for a city or use GPS location',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return builder(weatherData!, selectedCity!);
  }
}
