import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Helpers {
  /// Format angka ke format Rupiah
  static String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format tanggal ke format Indonesia
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal + waktu
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Format tanggal singkat
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Generate Order ID: LKY-2026-0419-1212
  static String generateOrderId() {
    final now = DateTime.now();
    final year = DateFormat('yyyy').format(now);
    final monthDay = DateFormat('MMdd').format(now);
    final random = Random();
    final code = random.nextInt(9999).toString().padLeft(4, '0');
    return 'LKY-$year-$monthDay-$code';
  }


  /// Get warna berdasarkan status
  static Color getStatusColor(String status) {
    switch (status) {
      case AppStrings.statusMenunggu:
        return AppColors.statusMenunggu;
      case AppStrings.statusDiproses:
        return AppColors.statusDiproses;
      case AppStrings.statusSelesai:
        return AppColors.statusSelesai;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get icon berdasarkan status
  static IconData getStatusIcon(String status) {
    switch (status) {
      case AppStrings.statusMenunggu:
        return Icons.access_time_rounded;
      case AppStrings.statusDiproses:
        return Icons.local_laundry_service_rounded;
      case AppStrings.statusSelesai:
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline;
    }
  }

  /// Estimasi selesai berdasarkan kecepatan
  static DateTime getEstimatedDone(String speed) {
    final now = DateTime.now();
    switch (speed) {
      case 'Express':
        return now.add(const Duration(days: 1));
      default: // Reguler
        return now.add(const Duration(days: 3));
    }
  }

  /// Get unit label berdasarkan kategori
  static String getUnitLabel(String category) {
    switch (category) {
      case 'Kiloan':
      case 'Campuran':
        return 'kg';
      case 'Satuan':
        return 'pcs';
      default:
        return 'kg';
    }
  }
}
