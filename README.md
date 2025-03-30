# TransitGo App

A public transportation companion app that helps users navigate transit systems efficiently.

## Features

- Find optimal routes using public transportation
- View real-time transit information
- Save favorite locations and routes
- Track travel history
- Earn rewards for sustainable travel

## Getting Started

### Prerequisites

- Flutter SDK (version 3.5.4 or higher)
- Google Maps API key (for transit directions)

### Setup

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Set up API keys:
   - Rename `lib/config/api_keys.example.dart` to `lib/config/api_keys.dart`
   - Add your Google Maps API key:
```dart
static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
```

4. Run the app:
```bash
flutter run
```

## Transit Routing

The app uses Google Maps Platform's Directions API to provide transit routing between locations. It displays:

- Multiple route options with different transit modes
- Step-by-step navigation instructions
- Walking segments between transit options
- Real-time arrival and departure times
- Transit line information and stops

To use this feature:

1. Enable the Directions API in your Google Cloud Platform project
2. Ensure your API key has the necessary permissions
3. Add your API key to the `lib/config/api_keys.dart` file

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
