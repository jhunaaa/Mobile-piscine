import 'package:flutter/material.dart';

class WeatherCodeInfo {
  final String description;
  final IconData icon;

  const WeatherCodeInfo(this.description, this.icon);
}

WeatherCodeInfo getWeatherInfo(int? code) {
  if (code == null) {
    return const WeatherCodeInfo('Unknown', Icons.help_outline);
  }

  switch (code) {
    case 0:
      return const WeatherCodeInfo('Clear sky', Icons.wb_sunny);
    case 1:
      return const WeatherCodeInfo('Mainly clear', Icons.wb_sunny_outlined);
    case 2:
      return const WeatherCodeInfo('Partly cloudy', Icons.cloud_queue);
    case 3:
      return const WeatherCodeInfo('Overcast', Icons.cloud);
    case 45:
    case 48:
      return const WeatherCodeInfo('Foggy', Icons.cloud_outlined);
    case 51:
    case 53:
    case 55:
      return const WeatherCodeInfo('Drizzle', Icons.grain);
    case 56:
    case 57:
      return const WeatherCodeInfo('Freezing Drizzle', Icons.grain);
    case 61:
      return const WeatherCodeInfo('Slight rain', Icons.water_drop_outlined);
    case 63:
      return const WeatherCodeInfo('Moderate rain', Icons.water_drop);
    case 65:
      return const WeatherCodeInfo('Heavy rain', Icons.grain);
    case 66:
    case 67:
      return const WeatherCodeInfo('Freezing rain', Icons.ac_unit);
    case 71:
      return const WeatherCodeInfo('Slight snow', Icons.ac_unit_outlined);
    case 73:
      return const WeatherCodeInfo('Moderate snow', Icons.ac_unit);
    case 75:
      return const WeatherCodeInfo('Heavy snow', Icons.severe_cold);
    case 77:
      return const WeatherCodeInfo('Snow grains', Icons.ac_unit);
    case 80:
    case 81:
    case 82:
      return const WeatherCodeInfo('Rain showers', Icons.shower);
    case 85:
    case 86:
      return const WeatherCodeInfo('Snow showers', Icons.ac_unit);
    case 95:
      return const WeatherCodeInfo('Thunderstorm', Icons.flash_on);
    case 96:
    case 99:
      return const WeatherCodeInfo('Thunderstorm with hail', Icons.thunderstorm);
    default:
      return const WeatherCodeInfo('Unknown', Icons.wb_cloudy);
  }
}
