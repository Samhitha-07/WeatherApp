import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/services/weather_service.dart';
import '/models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService("24ba533a16ec75c35c6154d195be87a3");
  Weather? _weather;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _errorMessage = null);

    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() => _weather = weather);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load weather: $e');
    }
  }

  String getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/sunny.json';
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'mist':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sun.json';
      default:
        return 'assets/sun.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.grey[600],
      body: Center(
        child: _errorMessage != null
            ? _buildError()
            : _weather == null
                ? const CircularProgressIndicator()
                : _buildWeatherInfo(),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _fetchWeather, child: const Text("Retry")),
      ],
    );
  }

  Widget _buildWeatherInfo() {
    final animation = getWeatherAnimation(_weather?.mainCondition);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 180, width: 180, child: Lottie.asset(animation)),
        const SizedBox(height: 20),
        Text(_weather!.cityName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(height: 10),
        Text('${_weather!.temperature.round()}°C',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Text(_weather!.mainCondition,
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white)),
      ],
    );
  }
}
