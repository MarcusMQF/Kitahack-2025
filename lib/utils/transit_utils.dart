/// A utility class containing functions related to transit operations
class TransitUtils {
  /// Returns a random station name from KL MRT/LRT stations
  /// If [exclude] is provided, it will return a station different from the excluded one
  static String getRandomStation({String? exclude}) {
    // Real KL MRT/LRT station names
    final stations = [
      // MRT Kajang Line (MRT1)
      'Sungai Buloh MRT',
      'Kampung Selamat MRT',
      'Kwasa Damansara MRT',
      'Kwasa Sentral MRT',
      'Kota Damansara MRT',
      'Surian MRT',
      'Mutiara Damansara MRT',
      'Bandar Utama MRT',
      'TTDI MRT',
      'Phileo Damansara MRT',
      'Pusat Bandar Damansara MRT',
      'Semantan MRT',
      'Muzium Negara MRT',
      'Pasar Seni MRT',
      'Merdeka MRT',
      'Bukit Bintang MRT',
      'Tun Razak Exchange MRT',
      'Cochrane MRT',
      'Maluri MRT',
      'Taman Pertama MRT',
      'Taman Midah MRT',
      'Taman Connaught MRT',
      'Taman Suntex MRT',
      'Sri Raya MRT',
      'Bandar Tun Hussein Onn MRT',
      'Batu 11 Cheras MRT',
      'Bukit Dukung MRT',
      'Sungai Jernih MRT',
      'Stadium Kajang MRT',
      'Kajang MRT',
      
      // LRT Kelana Jaya Line
      'Gombak LRT',
      'Taman Melati LRT',
      'Wangsa Maju LRT',
      'Sri Rampai LRT',
      'Setiawangsa LRT',
      'Jelatek LRT',
      'Dato Keramat LRT',
      'Damai LRT',
      'Ampang Park LRT',
      'KLCC LRT',
      'Kampung Baru LRT',
      'Dang Wangi LRT',
      'Masjid Jamek LRT',
      'Pasar Seni LRT',
      'KL Sentral LRT',
      'Bangsar LRT',
      'Abdullah Hukum LRT',
      'Kerinchi LRT',
      'Universiti LRT',
      'Taman Jaya LRT',
      'Asia Jaya LRT',
      'Taman Paramount LRT',
      'Taman Bahagia LRT',
      'Kelana Jaya LRT',
      
      // LRT Sri Petaling Line
      'Sentul Timur LRT',
      'Sentul LRT',
      'Titiwangsa LRT',
      'PWTC LRT',
      'Sultan Ismail LRT',
      'Bandaraya LRT',
      'Masjid Jamek LRT',
      'Plaza Rakyat LRT',
      'Hang Tuah LRT',
      'Pudu LRT',
      'Chan Sow Lin LRT',
      'Cheras LRT',
      'Salak Selatan LRT',
      'Bandar Tun Razak LRT',
      'Bandar Tasik Selatan LRT',
      'Sungai Besi LRT',
      'Sri Petaling LRT',
      'Bukit Jalil LRT',
      'Awan Besar LRT',
      'Muhibbah LRT',
      'Alam Sutera LRT',
      'Kinrara BK5 LRT',
      'IOI Puchong LRT',
      'Puteri LRT',
      'Puchong Perdana LRT',
      'Puchong Prima LRT',
      'Putra Heights LRT',
    ];
    
    if (exclude != null) {
      stations.removeWhere((s) => s == exclude);
    }
    
    return stations[DateTime.now().millisecond % stations.length];
  }
  
  /// Calculates an estimated fare based on distance or time
  /// [entryStation] and [exitStation] are the station names
  /// [tripDurationMinutes] is the trip duration in minutes
  static double calculateFare(String entryStation, String exitStation, int tripDurationMinutes) {
    // Simple fare calculation based on trip duration
    // In a real app, this would be based on actual distance between stations
    if (tripDurationMinutes < 15) {
      return 1.50; // Short trip
    } else if (tripDurationMinutes < 30) {
      return 2.50; // Medium trip
    } else if (tripDurationMinutes < 45) {
      return 3.50; // Longer trip
    } else {
      return 4.00; // Very long trip
    }
  }

  /// Calculates estimated CO2 savings for a transit trip compared to car travel
  static double calculateCO2Savings(double distanceKm, String transitType) {
    // CO2 emissions per km for different transport modes in kg
    final Map<String, double> co2PerKm = {
      'car': 0.192, // Average car emits 192g CO2 per km
      'bus': 0.104, // Bus emits 104g CO2 per km per passenger
      'subway': 0.041, // Subway/Metro emits 41g CO2 per km per passenger
      'tram': 0.035, // Tram emits 35g CO2 per km per passenger
      'train': 0.028, // Train emits 28g CO2 per km per passenger
      'ferry': 0.120, // Ferry emits 120g CO2 per km per passenger
      'walk': 0.0, // Walking emits 0g CO2
    };

    // Calculate CO2 emitted by car vs public transit
    final double carEmissions = co2PerKm['car']! * distanceKm;
    final double transitEmissions = co2PerKm[transitType] ?? co2PerKm['bus']! * distanceKm;
    
    // Calculate CO2 savings
    return carEmissions - transitEmissions;
  }

  /// Calculates steps walked based on distance
  static int calculateStepsWalked(double walkingDistanceKm) {
    // Average person walks ~1312 steps per km
    const int stepsPerKm = 1312;
    return (walkingDistanceKm * stepsPerKm).round();
  }

  /// Calculates calories burned from walking
  static int calculateCaloriesBurned(int steps) {
    // Average person burns ~0.04 calories per step
    const double caloriesPerStep = 0.04;
    return (steps * caloriesPerStep).round();
  }

  /// Returns SDG number and name based on impact type
  static Map<String, String> getSdgDetails(String impactType) {
    final Map<String, Map<String, String>> sdgMap = {
      'co2': {'number': '13', 'name': 'Climate Action'},
      'walk': {'number': '3', 'name': 'Good Health & Well-being'},
      'transit': {'number': '11', 'name': 'Sustainable Cities & Communities'},
    };
    
    return sdgMap[impactType] ?? {'number': '?', 'name': 'Unknown SDG'};
  }
} 