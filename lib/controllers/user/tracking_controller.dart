import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_kuy/models/order_model.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';

class TrackingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final orderIdController = TextEditingController();
  final Rx<OrderModel?> trackedOrder = Rx<OrderModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  
  StreamSubscription<DocumentSnapshot>? _trackingSubscription;

  @override
  void onClose() {
    orderIdController.dispose();
    _trackingSubscription?.cancel();
    super.onClose();
  }

  /// Track order by ID (Real-time)
  Future<void> trackOrder() async {
    final id = orderIdController.text.trim().toUpperCase();

    if (id.isEmpty) {
      Get.snackbar('Error', 'Masukkan ID Pesanan',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
      return;
    }

    isLoading.value = true;
    hasSearched.value = false; // Reset state for a new search
    _trackingSubscription?.cancel();

    _trackingSubscription = _firestore
        .collection(AppStrings.ordersCollection)
        .doc(id)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final order = OrderModel.fromJson(doc.data()!);
        
        // 24-hour Expiration Logic
        bool isExpired = false;
        if (order.status == AppStrings.statusSelesai) {
          final now = DateTime.now();
          final diff = now.difference(order.updatedAt);
          if (diff.inHours >= 24) {
            isExpired = true;
          }
        }

        if (isExpired) {
          trackedOrder.value = null;
          isLoading.value = false;
          hasSearched.value = false;
          Get.snackbar(
            'Pesanan Selesai',
            'Kode pesanan sudah selesai dan kadaluarsa.',
            backgroundColor: AppColors.error,
            colorText: AppColors.textWhite,
            duration: const Duration(seconds: 3),
          );
          _trackingSubscription?.cancel();
          return;
        }

        trackedOrder.value = order;
        
        if (!hasSearched.value) {
          // First time found, navigate to result
          hasSearched.value = true;
          isLoading.value = false;
          Get.toNamed(AppRoutes.userTrackingResult);
        }
      } else {
        // Document doesn't exist
        if (hasSearched.value) {
          // It was deleted while we were watching it
          trackedOrder.value = null;
          hasSearched.value = false;
          orderIdController.clear();
          
          Get.until((route) => Get.currentRoute == AppRoutes.userTracking);
          
          Get.snackbar(
            'Pesanan Selesai',
            'Kode pesanan sudah selesai dan kadaluarsa.',
            backgroundColor: AppColors.secondary,
            colorText: AppColors.textWhite,
            duration: const Duration(seconds: 4),
          );
        } else {
          // Never existed
          trackedOrder.value = null;
          isLoading.value = false;
          Get.snackbar(
            'Pesanan Selesai',
            'Kode pesanan sudah selesai atau kadaluarsa.',
            backgroundColor: AppColors.error,
            colorText: AppColors.textWhite,
            duration: const Duration(seconds: 3),
          );
        }
        _trackingSubscription?.cancel();
      }
    }, onError: (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal memuat data: $e',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
    });
  }

  /// Refresh tracking data (Kept for manual trigger if needed, though now real-time)
  Future<void> refreshTracking() async {
    // With real-time stream, manual refresh might just reset the listener
    // but usually not needed. We'll leave a small delay for UX feedback.
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
