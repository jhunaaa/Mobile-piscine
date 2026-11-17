import 'package:flutter/material.dart';
import '../../models/city.dart';
import '../../models/weather.dart';
import '../../utils/date_formatter.dart';
import '../../utils/weather_code.dart';
import '../hourly_chart.dart';
import '../location_header.dart';
import '../weather_state_wrapper.dart';

class TodayTab extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final WeatherData? weatherData;
  final City? selectedCity;

  const TodayTab({
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
        final hourlyToday = data.hourly.take(24).toList();

        return Column(
          children: [
            LocationHeader(city: city),
            HourlyChart(hourly: hourlyToday),
            Expanded(
              child: ListView.builder(
                itemCount: hourlyToday.length,
                itemBuilder: (context, index) {
                  final item = hourlyToday[index];
                  final info = getWeatherInfo(item.weatherCode);
                  final tempStr = item.temperature.toStringAsFixed(1);
                  final windStr = item.windSpeed.toStringAsFixed(1);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: Icon(info.icon, color: Colors.blue[200]),
                      title: Text(DateFormatter.formatHour(item.time)),
                      subtitle: Text(info.description),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$tempStr °C',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$windStr km/h',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
