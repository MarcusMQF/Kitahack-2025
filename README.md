# <p align="center"><img src="lib/images/TransitGo.png" alt="TransitGo Logo" width="200"/></p>

<h1 align="center">TransitGo</h1>
<p align="center">Your ultimate public transportation companion app</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white" alt="Google Maps"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Google Cloud"/>
</p>

## 📱 About

TransitGo is a comprehensive public transportation companion app designed to help users navigate transit systems efficiently. With real-time updates, smart routing, and rewards for sustainable travel choices, TransitGo makes commuting simpler and more enjoyable.

## ✨ Features

- 🗺️ **Smart Routing** - Find optimal routes using public transportation
- ⏱️ **Real-time Updates** - Get accurate arrival and departure times
- 🔖 **Favorites** - Save frequent locations and routes for quick access
- 📊 **Travel History** - Track and analyze your travel patterns
- 🏆 **Rewards System** - Earn rewards for choosing sustainable transportation
- 📱 **Cross-platform** - Available on iOS and Android

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.5.4 or higher)
- Google Maps API key (for transit directions)
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/transit_go_app.git
   cd transit_go_app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Set up API keys:
   - Rename `lib/config/api_keys.example.dart` to `lib/config/api_keys.dart`
   - Add your Google Maps API key:
   ```dart
   static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
   ```

4. Run the app
   ```bash
   flutter run
   ```

## 🗺️ Transit Routing

TransitGo leverages Google Maps Platform's Directions API to provide comprehensive transit routing between locations. The app displays:

- Multiple route options with different transit modes
- Step-by-step navigation instructions
- Walking segments between transit options
- Real-time arrival and departure times
- Transit line information and stops

To use this feature:

1. Enable the Directions API in your Google Cloud Platform project
2. Ensure your API key has the necessary permissions
3. Add your API key to the `lib/config/api_keys.dart` file

## 🛠️ Tech Stack

<table>
  <tr>
    <th>Category</th>
    <th>Technologies</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>Framework</td>
    <td>Flutter & Dart</td>
    <td>Cross-platform UI development</td>
  </tr>
  <tr>
    <td>State Management</td>
    <td>Provider</td>
    <td>Application state management</td>
  </tr>
  <tr>
    <td>Maps & Location</td>
    <td>Google Maps Flutter, Geolocator, Geocoding</td>
    <td>Maps integration and location services</td>
  </tr>
  <tr>
    <td>Storage</td>
    <td>Shared Preferences</td>
    <td>Local data persistence</td>
  </tr>
  <tr>
    <td>Networking</td>
    <td>HTTP</td>
    <td>API communication</td>
  </tr>
  <tr>
    <td>UI Enhancement</td>
    <td>Lottie, Slide to Act</td>
    <td>Animations and interactive components</td>
  </tr>
  <tr>
    <td>Utilities</td>
    <td>QR Flutter, URL Launcher, Image Picker</td>
    <td>QR code generation, external links, image handling</td>
  </tr>
  <tr>
    <td>Configuration</td>
    <td>Flutter dotenv</td>
    <td>Environment variable management</td>
  </tr>
</table>

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

If you have any questions or feedback, please reach out to us at contact@transitgo.app
