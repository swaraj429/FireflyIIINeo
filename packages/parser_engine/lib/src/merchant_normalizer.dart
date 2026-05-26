class MerchantNormalizer {
  static const Map<String, String> _normalizations = {
    // Food delivery
    'SWIGGY': 'Swiggy',
    'ZOMATO': 'Zomato',
    'BLINKIT': 'Blinkit',
    'DUNZO': 'Dunzo',
    // E-commerce
    'AMAZON': 'Amazon',
    'FLIPKART': 'Flipkart',
    'MYNTRA': 'Myntra',
    'MEESHO': 'Meesho',
    // Travel
    'MAKEMYTRIP': 'MakeMyTrip',
    'IRCTC': 'IRCTC',
    'OLA': 'Ola',
    'UBER': 'Uber',
    'RAPIDO': 'Rapido',
    // Utilities
    'BSNL': 'BSNL',
    'AIRTEL': 'Airtel',
    'JIO': 'Jio',
    'VODAFONE': 'Vodafone',
    // Streaming
    'NETFLIX': 'Netflix',
    'HOTSTAR': 'Disney+ Hotstar',
    'PRIMEVIDEO': 'Amazon Prime',
    'SPOTIFYAB': 'Spotify',
    // Fuel
    'HPCL': 'HPCL',
    'IOCL': 'Indian Oil',
    'BPCL': 'BPCL',
    'BHARAT PETROLEUM': 'BPCL',
    'HINDUSTAN PETROLEUM': 'HPCL',
    // Grocery
    'BIGBASKET': 'BigBasket',
    'ZEPTO': 'Zepto',
    'DMART': 'DMart',
    // Healthcare
    'APOLLO': 'Apollo',
    'PHARMEASY': 'PharmEasy',
    'NETMEDS': 'Netmeds',
  };

  static String normalize(String raw) {
    if (raw.isEmpty) return 'Unknown Merchant';
    
    final upper = raw.toUpperCase().trim();
    
    // Direct match check
    for (final entry in _normalizations.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }
    
    // Clean up UPI ID format: merchant@upi -> Merchant
    if (raw.contains('@')) {
      final parts = raw.split('@');
      if (parts.isNotEmpty) {
        return _titleCase(parts[0].replaceAll('.', ' ').replaceAll('-', ' ').replaceAll(RegExp(r'\d+'), ''));
      }
    }
    
    // Fallback title case
    return _titleCase(raw);
  }

  static String _titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ').trim();
  }
}
