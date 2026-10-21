class CurrentWeather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String time;

  CurrentWeather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windspeed'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weathercode'] as num?)?.toInt() ?? 0,
      time: json['time'] as String? ?? '',
    );
  }
}

class HourlyItem {
  final String time;
  final double temperature;
  final int weatherCode;
  final double windSpeed;

  HourlyItem({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });
}

class DailyItem {
  final String date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;

  DailyItem({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
  });
}

class WeatherData {
  final CurrentWeather currentWeather;
  final List<HourlyItem> hourly;
  final List<DailyItem> daily;

  WeatherData({
    required this.currentWeather,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current_weather'] as Map<String, dynamic>? ?? {};
    final currentWeather = CurrentWeather.fromJson(currentJson);

    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final times = (hourlyJson['time'] as List<dynamic>?)?.cast<String>() ?? [];
    final temps = (hourlyJson['temperature_2m'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
    final codes = (hourlyJson['weather_code'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];
    final winds = (hourlyJson['wind_speed_10m'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];

    List<HourlyItem> hourlyItems = [];
    int hourlyLength = times.length;
    for (int i = 0; i < hourlyLength; i++) {
      hourlyItems.add(
        HourlyItem(
          time: times[i],
          temperature: i < temps.length ? temps[i] : 0.0,
          weatherCode: i < codes.length ? codes[i] : 0,
          windSpeed: i < winds.length ? winds[i] : 0.0,
        ),
      );
    }

    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final dates = (dailyJson['time'] as List<dynamic>?)?.cast<String>() ?? [];
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
    final dailyCodes = (dailyJson['weather_code'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];

    List<DailyItem> dailyItems = [];
    int dailyLength = dates.length;
    for (int i = 0; i < dailyLength; i++) {
      dailyItems.add(
        DailyItem(
          date: dates[i],
          tempMax: i < maxTemps.length ? maxTemps[i] : 0.0,
          tempMin: i < minTemps.length ? minTemps[i] : 0.0,
          weatherCode: i < dailyCodes.length ? dailyCodes[i] : 0,
        ),
      );
    }

    return WeatherData(
      currentWeather: currentWeather,
      hourly: hourlyItems,
      daily: dailyItems,
    );
  }
}
