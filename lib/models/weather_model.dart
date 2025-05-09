class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Safe access with null checks for required keys
    return Weather(
      cityName: json['name'] ?? 'Unknown', // Default value in case city name is missing
      temperature: json['main']['temp']?.toDouble() ?? 0.0, // Ensure the temp value is always a double
      mainCondition: json['weather'][0]['main'] ?? 'Unknown', // Default if main weather condition is missing
    );
  }
}
