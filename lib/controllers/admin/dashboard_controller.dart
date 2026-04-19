import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_kuy/models/order_model.dart';
import 'package:laundry_kuy/utils/constants.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalOrders = 0.obs;
  final RxInt pendingOrders = 0.obs;
  final RxInt processingOrders = 0.obs;
  final RxInt completedOrders = 0.obs;
  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;
  final RxList<OrderModel> allOrders = <OrderModel>[].obs; // Store all for filtering
  final RxBool isLoading = false.obs;
  
  // Navigation State
  final RxInt currentIndex = 0.obs;
  final RxString selectedStatus = AppStrings.statusMenunggu.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxString searchQuery = ''.obs;
  
  // Report State
  final RxInt selectedReportMonth = DateTime.now().month.obs;
  final RxInt selectedReportYear = DateTime.now().year.obs;
  
  // Computed Report Data
  List<OrderModel> get filteredReportOrders {
    return allOrders.where((o) {
      return o.createdAt.month == selectedReportMonth.value &&
             o.createdAt.year == selectedReportYear.value;
    }).toList();
  }

  double get monthlyRevenue {
    return filteredReportOrders.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get monthlyOrderCount => filteredReportOrders.length;
  
  double get dailyAverage {
    if (monthlyRevenue == 0) return 0;
    
    final now = DateTime.now();
    int days;
    
    if (selectedReportMonth.value == now.month && selectedReportYear.value == now.year) {
      days = now.day;
    } else {
      // Total days in selected month
      days = DateTime(selectedReportYear.value, selectedReportMonth.value + 1, 0).day;
    }
    
    return monthlyRevenue / days;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void changePage(int index) {
    currentIndex.value = index;
    // Reset report selection to current month when switching away/back
    if (index == 2) {
      selectedReportMonth.value = DateTime.now().month.obs.value;
      selectedReportYear.value = DateTime.now().year.obs.value;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Listen to real-time changes
      _firestore
          .collection(AppStrings.ordersCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        final orders = snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList();

        allOrders.value = orders;
        
        // Total Pesanan (Monthly Reset)
        final now = DateTime.now();
        totalOrders.value = orders.where((o) => 
          o.createdAt.month == now.month && 
          o.createdAt.year == now.year).length;
        
        // Calculate Daily Revenue (Today Only)
        final startOfToday = DateTime(now.year, now.month, now.day);
        
        totalRevenue.value = orders
            .where((o) => o.createdAt.isAfter(startOfToday))
            .fold(0.0, (sum, order) => sum + order.totalPrice);

        pendingOrders.value =
            orders.where((o) => o.status == AppStrings.statusMenunggu).length;
        processingOrders.value =
            orders.where((o) => o.status == AppStrings.statusDiproses).length;
        completedOrders.value =
            orders.where((o) => o.status == AppStrings.statusSelesai).length;

        // Recent 5 orders
        recentOrders.value = orders.take(5).toList();

        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> deleteAllOrders() async {
    try {
      isLoading.value = true;
      final querySnapshot = await _firestore.collection(AppStrings.ordersCollection).get();
      
      if (querySnapshot.docs.isEmpty) {
        Get.snackbar('Informasi', 'Tidak ada data pesanan untuk dihapus.',
            backgroundColor: AppColors.primary, colorText: AppColors.textWhite);
        return;
      }

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Get.snackbar('Berhasil', 'Semua data pesanan telah dihapus.',
          backgroundColor: AppColors.secondary, colorText: AppColors.textWhite);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data: $e',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
    } finally {
      isLoading.value = false;
    }
  }
}
