import 'package:flutter/material.dart';
import '../../models/city.dart';
import '../../models/weather.dart';
import '../../utils/weather_code.dart';
import '../location_header.dart';
import '../weather_state_wrapper.dart';

class CurrentlyTab extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final WeatherData? weatherData;
  final City? selectedCity;

  const CurrentlyTab({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.weatherData,
    required this.selectedCity,
  });

  @override
  Widget build(BuildContext context) {
    return WeatherStateWrapper(
      isLoading: isLoading,
      errorMessage: errorMessage,
      weatherData: weatherData,
      selectedCity: selectedCity,
      builder: (data, city) {
        final current = data.currentWeather;
        final info = getWeatherInfo(current.weatherCode);

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              LocationHeader(city: city),
              const SizedBox(height: 20),
              Icon(info.icon, size: 80, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                '${current.temperature.toStringAsFixed(1)} °C',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Text(
                info.description,
                style: const TextStyle(fontSize: 22, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.air, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Wind Speed: ${current.windSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
