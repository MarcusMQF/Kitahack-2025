class Weather {
  final String cityName;
  final double temperature;
  final String weather;
  final String description;

  Weather({
    required this.cityName, 
    required this.temperature, 
    required this.weather,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      weather: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
    );
  }

  String getWeatherIconKey() {
    final String mainCondition = weather;
    final String desc = description.toLowerCase();
    
    if (desc.contains('light rain') || desc.contains('shower rain')) {
      return 'LightRain';
    } else if (desc.contains('rain')) {
      return 'Rain';
    } else if (desc.contains('drizzle')) {
      return 'Drizzle';
    } else if (desc.contains('thunderstorm')) {
      return 'Thunderstorm';
    } else if (desc.contains('snow')) {
      return 'Snow';
    } else if (desc.contains('mist') || 
              desc.contains('fog') || 
              desc.contains('haze') || 
              desc.contains('smoke') || 
              desc.contains('dust') || 
              desc.contains('sand') || 
              desc.contains('ash')) {
      return 'Mist';
    } else if (desc.contains('clear')) {
      return 'Clear';
    } else if (desc.contains('few clouds') || desc.contains('scattered clouds')) {
      return 'FewClouds';
    } else if (desc.contains('broken clouds') || desc.contains('overcast')) {
      return 'BrokenClouds';
    } else if (desc.contains('squall')) {
      return 'Squall';
    } else if (desc.contains('tornado')) {
      return 'Tornado';
    }
    
    return mainCondition;
  }
}