import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'models/city.dart';
import 'models/weather.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';
import 'widgets/search_suggestions.dart';
import 'widgets/tabs/currently_tab.dart';
import 'widgets/tabs/today_tab.dart';
import 'widgets/tabs/weekly_tab.dart';

void main() {
  runApp(const MyApp());
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
      final cities = await _weatherService.searchCities(query);
      final results = cities.take(5).toList();
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
      Position position = await LocationService.determinePosition();
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
              hintText: 'Search location',
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
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            TabBarView(
              children: [
                CurrentlyTab(
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  weatherData: _weatherData,
                  selectedCity: _selectedCity,
                ),
                TodayTab(
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  weatherData: _weatherData,
                  selectedCity: _selectedCity,
                ),
                WeeklyTab(
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  weatherData: _weatherData,
                  selectedCity: _selectedCity,
                ),
              ],
            ),
            if (_showSuggestions)
              SearchSuggestionsOverlay(
                suggestions: _suggestions,
                onCitySelected: _selectCity,
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
