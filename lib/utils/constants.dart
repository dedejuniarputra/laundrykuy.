import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusMenunggu = Color(0xFFFF9800);
  static const Color statusDiproses = Color(0xFF2196F3);
  static const Color statusSelesai = Color(0xFF4CAF50);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Other
  static const Color error = Color(0xFFE53935);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppPricing {
  // Biaya Tetap Express (Flat Fee)
  static const double expressSurchargeFlat = 4000;

  // Harga Kiloan (Reguler)
  static const Map<String, double> kiloanPrices = {
    'Komplit': 7000,
    'Strika': 5000,
    'Kering': 6000,
    'Slep': 6000,
  };

  // Harga Satuan (Reguler)
  static const Map<String, double> satuanPrices = {
    'Komplit': 15000,
    'Strika': 8000,
    'Kering': 10000,
    'Slep': 6000,
  };

  // Harga Campuran (Reguler)
  static const Map<String, double> comforterPrices = {
    'Komplit': 10000,
    'Strika': 7000,
    'Kering': 8000,
    'Slep': 8000,
  };

  static double getPrice(String category, String serviceType) {
    Map<String, double> priceMap;

    switch (category) {
      case 'Satuan':
        priceMap = satuanPrices;
        break;
      case 'Campuran':
        priceMap = comforterPrices;
        break;
      default:
        priceMap = kiloanPrices;
    }

    return priceMap[serviceType] ?? 0;
  }
}

class AppStrings {
  static const String appName = 'Laundry.kuy';
  static const String appTagline = 'Solusi Laundry Terpercaya';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Order Status
  static const String statusMenunggu = 'Menunggu';
  static const String statusDiproses = 'Diproses';
  static const String statusSelesai = 'Selesai';

  // Categories
  static const List<String> categories = ['Kiloan', 'Satuan', 'Campuran'];
  static const List<String> serviceTypes = ['Komplit', 'Strika', 'Kering', 'Slep'];
  static const List<String> serviceSpeeds = ['Reguler', 'Express'];
  static const List<String> genders = ['Laki-laki', 'Perempuan'];

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String ordersCollection = 'orders';
}
