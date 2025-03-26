class Weather {
  final String cityName;
  final double temperature;
  final String weather;

  Weather({
    required this.cityName, 
    required this.temperature, 
    required this.weather
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      weather: json['weather'][0]['main'],
    );
  }
}