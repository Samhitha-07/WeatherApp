import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart'; // Make sure to import your WeatherModel file

class WeatherService {
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  // Function to fetch the weather based on city name
  Future<Weather> getWeather(String cityName) async {
    // Check if the city name is valid
    if (cityName.trim().isEmpty || cityName.contains('Error') || cityName.contains('Permission')) {
      throw Exception("Invalid city name: $cityName");
    }

    try {
      // Make HTTP request to OpenWeather API
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$cityName&appid=$apiKey&units=metric'),
      );

      // Check if the response status is successful (200)
      if (response.statusCode == 200) {
        // Parse and return the weather data
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather: $e');
    }
  }

  // Function to get current city based on geolocation
  Future<String> getCurrentCity() async {
    try {
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          throw Exception('Location permission denied');
        }
      }

      // Get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}'); // Debugging Coordinates

      // Use Geocoding to get the city name from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      // Check if any placemarks were returned
      if (placemarks.isEmpty) throw Exception('Failed to get location');

      // Extract city, sub-administrative area, and administrative area
      final placemark = placemarks[0];
      print('Placemark: $placemark'); // Debugging Placemark

      final city = placemark.locality;
      final subArea = placemark.subAdministrativeArea;
      final adminArea = placemark.administrativeArea;

      // Return the first valid location component
      if (city != null && city.trim().isNotEmpty) return city;
      if (subArea != null && subArea.trim().isNotEmpty) return subArea;
      if (adminArea != null && adminArea.trim().isNotEmpty) return adminArea;

      return 'India'; // Fallback if no valid city is found
    } catch (e) {
      return 'India'; // Return fallback location if error occurs
    }
  }
}
