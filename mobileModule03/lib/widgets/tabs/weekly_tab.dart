import 'package:flutter/material.dart';
import '../../models/city.dart';
import '../../models/weather.dart';
import '../../utils/date_formatter.dart';
import '../../utils/weather_code.dart';
import '../location_header.dart';
import '../weather_state_wrapper.dart';
import '../weekly_chart.dart';

class WeeklyTab extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final WeatherData? weatherData;
  final City? selectedCity;

  const WeeklyTab({
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
        final dailyList = data.daily;

        return Column(
          children: [
            LocationHeader(city: city),
            WeeklyChart(daily: dailyList),
            Expanded(
              child: ListView.builder(
                itemCount: dailyList.length,
                itemBuilder: (context, index) {
                  final item = dailyList[index];
                  final info = getWeatherInfo(item.weatherCode);
                  final minTemp = item.tempMin.toStringAsFixed(1);
                  final maxTemp = item.tempMax.toStringAsFixed(1);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(info.icon, color: Colors.blue[200], size: 36),
                      title: Text(
                        DateFormatter.formatDate(item.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(info.description),
                      trailing: Text(
                        '$minTemp°C - $maxTemp°C',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
