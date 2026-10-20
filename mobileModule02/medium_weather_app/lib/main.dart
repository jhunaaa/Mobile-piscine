import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'models/city.dart';
import 'models/weather.dart';
import 'services/weather_service.dart';
import 'utils/weather_code.dart';

void main() {
  runApp(const MyApp());
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final WeatherService _weatherService = WeatherService();

  List<City> _suggestions = [];
  City? _selectedCity;
  WeatherData? _weatherData;
  bool _isLoading = false;
  bool _showSuggestions = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  static final String _degreeSymbol = String.fromCharCode(176);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final results = await _weatherService.searchCities(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
        });
      }
    });
  }

  Future<void> _fetchWeatherForCity(City city) async {
    setState(() {
      _selectedCity = city;
      _isLoading = true;
      _errorMessage = null;
      _showSuggestions = false;
    });

    try {
      final weather = await _weatherService.getWeatherData(
        city.latitude,
        city.longitude,
      );
      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not fetch weather data. Please try again.';
        });
      }
    }
  }

  void _selectCity(City city) {
    _searchController.text = city.displayName;
    _focusNode.unfocus();
    _fetchWeatherForCity(city);
  }

  Future<void> _onSearchSubmitted(String query) async {
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });

    if (query.trim().isEmpty) return;

    if (_suggestions.isNotEmpty) {
      _selectCity(_suggestions.first);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await _weatherService.searchCities(query);
    if (results.isNotEmpty) {
      _selectCity(results.first);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not find location "$query"';
      });
    }
  }

  Future<void> _onGpsPressed() async {
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Position position = await _determinePosition();
      City currentCity = await _weatherService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      _searchController.text = currentCity.displayName;
      await _fetchWeatherForCity(currentCity);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatHour(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return isoTime;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildLocationHeader() {
    if (_selectedCity == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            _selectedCity!.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          if (_selectedCity!.region.isNotEmpty || _selectedCity!.country.isNotEmpty)
            Text(
              [_selectedCity!.region, _selectedCity!.country]
                  .where((s) => s.isNotEmpty)
                  .join(', '),
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentlyTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }
    if (_weatherData == null || _selectedCity == null) {
      return const Center(
        child: Text(
          'Search for a city or use GPS location',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final current = _weatherData!.currentWeather;
    final info = getWeatherInfo(current.weatherCode);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildLocationHeader(),
          const SizedBox(height: 20),
          Icon(info.icon, size: 80, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            '${current.temperature.toStringAsFixed(1)} $_degreeSymbol C',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(
            info.description,
            style: const TextStyle(fontSize: 22, color: Colors.grey),
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
  }

  Widget _buildTodayTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }
    if (_weatherData == null || _selectedCity == null) {
      return const Center(
        child: Text(
          'Search for a city or use GPS location',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final hourlyToday = _weatherData!.hourly.take(24).toList();

    return Column(
      children: [
        _buildLocationHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: hourlyToday.length,
            itemBuilder: (context, index) {
              final item = hourlyToday[index];
              final info = getWeatherInfo(item.weatherCode);
              final tempStr = item.temperature.toStringAsFixed(1);
              final windStr = item.windSpeed.toStringAsFixed(1);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: Icon(info.icon, color: Colors.blue),
                  title: Text(_formatHour(item.time)),
                  subtitle: Text(info.description),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$tempStr $_degreeSymbol C',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$windStr km/h',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
  }

  Widget _buildWeeklyTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }
    if (_weatherData == null || _selectedCity == null) {
      return const Center(
        child: Text(
          'Search for a city or use GPS location',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final dailyList = _weatherData!.daily;

    return Column(
      children: [
        _buildLocationHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: dailyList.length,
            itemBuilder: (context, index) {
              final item = dailyList[index];
              final info = getWeatherInfo(item.weatherCode);
              final minTemp = item.tempMin.toStringAsFixed(1);
              final maxTemp = item.tempMax.toStringAsFixed(1);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(info.icon, color: Colors.blue, size: 36),
                  title: Text(
                    _formatDate(item.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(info.description),
                  trailing: Text(
                    '$minTemp$_degreeSymbol C - $maxTemp$_degreeSymbol C',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Search city, country...',
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: _onGpsPressed,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildCurrentlyTab(),
                _buildTodayTab(),
                _buildWeeklyTab(),
              ],
            ),
            if (_showSuggestions && _suggestions.isNotEmpty)
              Positioned(
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
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final city = _suggestions[index];
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
                          onTap: () => _selectCity(city),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(
                icon: Icon(Icons.wb_sunny),
                text: "Currently",
              ),
              Tab(
                icon: Icon(Icons.today),
                text: "Today",
              ),
              Tab(
                icon: Icon(Icons.calendar_view_week),
                text: "Weekly",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
