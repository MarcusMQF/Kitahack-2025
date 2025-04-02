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
} 