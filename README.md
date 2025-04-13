<div align="center">
  <img src="lib/images/readme_icon.png" alt="TransitGo Logo" width="180"/>
  <h1>TransitGo</h1>
  <p>Tap, ride, and earn—your all-in-one app for sustainable public transit in Malaysia.</p>

  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white" alt="Google Maps"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Google Cloud"/>

</div>

## 📱 About

**TransitGo** is a Flutter-based mobile application designed to **promote sustainable urban mobility in Malaysia** by simplifying public transit payments and rewarding eco-friendly travel. Built for a hackathon, it **simulates NFC-based tap-and-pay functionality for LRT, MRT,KTM and Bus rides**, allowing users to pay via an eWallet, earn points with a swipe-to-claim system, and track trip history with **Google Maps integration**. Leveraging **Google AI technologies like Firebase for real-time data and Google Maps Platform API for route visualization, and Google Gemini AI Assistant** TransitGo aligns with SDG 11 (Sustainable Cities) and SDG 13 (Climate Action). Whether you're commuting in Kuala Lumpur or beyond, TransitGo makes public transit seamless, rewarding, and green.

- **Key Features:** Simulated NFC payments, eWallet, points system, transit history with maps.
- **Tech Stack:** Flutter, Dart, Firebase, Google Maps Platform API, Google Gemini
- **Purpose:** Encourage public transit use to reduce urban congestion and carbon emissions.

<img src="lib/images/mockup.png" alt="Mockup"/>

## ✨ Features

- 🗺️ **Route Planning** - Find optimal routes to a destination using public transportation
- ⏱️ **Real-time Updates** - Get accurate arrival and departure times
- 🔖 **Favorites** - Save frequent locations and routes for quick access
- 📊 **Travel History** - Track and analyze your travel patterns
- 🏆 **Rewards System** - Earn points and credits for using sustainable public transportation
- 📱 **Cross-platform** - Available on iOS and Android

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
    <td>
      <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
      <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/></a>
    </td>
    <td>Cross-platform UI development</td>
  </tr>
  <tr>
    <td>State Management</td>
    <td>
      <a href="https://pub.dev/packages/provider"><img src="https://img.shields.io/badge/Provider-4285F4?style=for-the-badge&logo=flutter&logoColor=white" alt="Provider"/></a>
    </td>
    <td>Application state management</td>
  </tr>
  <tr>
    <td>Maps & Location</td>
    <td>
      <a href="https://developers.google.com/maps"><img src="https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white" alt="Google Maps"/></a>
      <a href="https://pub.dev/packages/geolocator"><img src="https://img.shields.io/badge/Geolocator-4285F4?style=for-the-badge&logo=location&logoColor=white" alt="Geolocator"/></a>
    </td>
    <td>Maps integration and location services</td>
  </tr>
  <tr>
    <td>Storage</td>
    <td>
      <a href="https://pub.dev/packages/shared_preferences"><img src="https://img.shields.io/badge/Shared_Preferences-0175C2?style=for-the-badge&logo=flutter&logoColor=white" alt="Shared Preferences"/></a>
    </td>
    <td>Local data persistence</td>
  </tr>
  <tr>
    <td>Networking</td>
    <td>
      <a href="https://pub.dev/packages/http"><img src="https://img.shields.io/badge/HTTP-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="HTTP"/></a>
    </td>
    <td>API communication</td>
  </tr>
  <tr>
    <td>UI Enhancement</td>
    <td>
      <a href="https://pub.dev/packages/lottie"><img src="https://img.shields.io/badge/Lottie-FF5A5F?style=for-the-badge&logo=airbnb&logoColor=white" alt="Lottie"/></a>
      <a href="https://pub.dev/packages/slide_to_act"><img src="https://img.shields.io/badge/Slide_to_Act-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Slide to Act"/></a>
    </td>
    <td>Animations and interactive components</td>
  </tr>
  <tr>
    <td>Utilities</td>
    <td>
      <a href="https://pub.dev/packages/qr_flutter"><img src="https://img.shields.io/badge/QR_Flutter-000000?style=for-the-badge&logo=qrcode&logoColor=white" alt="QR Flutter"/></a>
      <a href="https://pub.dev/packages/url_launcher"><img src="https://img.shields.io/badge/URL_Launcher-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="URL Launcher"/></a>
      <a href="https://pub.dev/packages/image_picker"><img src="https://img.shields.io/badge/Image_Picker-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Image Picker"/></a>
    </td>
    <td>QR code generation, external links, image handling</td>
  </tr>
  <tr>
    <td>Configuration</td>
    <td>
      <a href="https://pub.dev/packages/flutter_dotenv"><img src="https://img.shields.io/badge/Flutter_dotenv-02569B?style=for-the-badge&logo=dotenv&logoColor=white" alt="Flutter dotenv"/></a>
    </td>
    <td>Environment variable management</td>
  </tr>
  <tr>
    <td>Cloud Services</td>
    <td>
      <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/></a>
    </td>
    <td>Backend services and authentication</td>
  </tr>
  <tr>
    <td>External APIs</td>
    <td>
      <a href="https://openweathermap.org/api"><img src="https://img.shields.io/badge/OpenWeather_API-EB6E4B?style=for-the-badge&logo=openweathermap&logoColor=white" alt="OpenWeather API"/></a>
    </td>
    <td>Real-time weather data and forecasts</td>
  </tr>
  <tr>
    <td>AI Integration</td>
    <td>
      <a href="https://ai.google.dev/"><img src="https://img.shields.io/badge/Google_Generative_AI-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Google Generative AI"/></a>
      <a href="https://ai.google.dev/studio"><img src="https://img.shields.io/badge/Google_Studio_AI-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Google Studio AI"/></a>
    </td>
    <td>AI assistant capabilities</td>
  </tr>
  <tr>
    <td>Voice Recognition</td>
    <td>
      <a href="https://pub.dev/packages/speech_to_text"><img src="https://img.shields.io/badge/Flutter_Speech_to_Text-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Speech to Text"/></a>
    </td>
    <td>Voice input and recognition</td>
  </tr>
</table>