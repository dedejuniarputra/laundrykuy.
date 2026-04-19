import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laundry_kuy/models/order_model.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/utils/helpers.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Order List
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;
  final RxString selectedFilter = 'Semua'.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Input Order - Step 1: Customer Info
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final selectedGender = 'Laki-laki'.obs;

  // Input Order - Step 2: Service
  final selectedCategory = 'Kiloan'.obs;
  final selectedServiceType = 'Komplit'.obs;
  final selectedServiceSpeed = 'Reguler'.obs;
  final weightController = TextEditingController();
  final quantityController = TextEditingController();
  final rxWeight = 0.0.obs;
  final rxQuantity = 0.obs;
  final notesController = TextEditingController();

  // Step control
  final currentStep = 0.obs;
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();

  // Current order detail
  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);

  String get unitLabel =>
      (selectedCategory.value == 'Kiloan' || selectedCategory.value == 'Campuran') ? 'kg' : 'pcs';

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    weightController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Fetch all orders with real-time updates
  void fetchOrders() {
    isLoading.value = true;
    _firestore
        .collection(AppStrings.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      allOrders.value =
          snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
      _applyFilter();
      isLoading.value = false;
    });
  }

  /// Filter orders by status
  void filterByStatus(String status) {
    selectedFilter.value = status;
    _applyFilter();
  }

  /// Search orders
  void searchOrders(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    var result = allOrders.toList();

    // Apply status filter
    if (selectedFilter.value != 'Semua') {
      result = result.where((o) => o.status == selectedFilter.value).toList();
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((o) =>
          o.customerName.toLowerCase().contains(q) ||
          o.orderId.toLowerCase().contains(q)).toList();
    }

    filteredOrders.value = result;
  }

  /// Get base price per unit
  double get pricePerUnit {
    return AppPricing.getPrice(
      selectedCategory.value,
      selectedServiceType.value,
    );
  }

  /// Get base total (without surcharge)
  double get baseTotal {
    final amount = (selectedCategory.value == 'Kiloan' || selectedCategory.value == 'Campuran')
        ? rxWeight.value
        : rxQuantity.value.toDouble();
    return pricePerUnit * amount;
  }

  /// Get surcharge total (Flat Fee for Express)
  double get surchargeTotal {
    return selectedServiceSpeed.value == 'Express' 
        ? AppPricing.expressSurchargeFlat 
        : 0;
  }

  /// Get total calculated price
  double get calculatedPrice {
    return baseTotal + surchargeTotal;
  }

  /// Validate Step 1
  bool validateStep1() {
    return step1FormKey.currentState?.validate() ?? false;
  }

  /// Validate Step 2
  bool validateStep2() {
    return step2FormKey.currentState?.validate() ?? false;
  }

  /// Go to next step
  void nextStep() {
    if (currentStep.value == 0 && validateStep1()) {
      currentStep.value = 1;
    } else if (currentStep.value == 1 && validateStep2()) {
      currentStep.value = 2;
    }
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Submit order
  Future<void> submitOrder({Function(OrderModel)? onSuccess}) async {
    try {
      isLoading.value = true;

      final orderId = Helpers.generateOrderId();

      final finalPrice = calculatedPrice;

      final order = OrderModel(
        orderId: orderId,
        customerName: customerNameController.text.trim(),
        customerGender: selectedGender.value,
        customerPhone: customerPhoneController.text.trim(),
        category: selectedCategory.value,
        serviceType: selectedServiceType.value,
        serviceSpeed: selectedServiceSpeed.value,
        weight: rxWeight.value,
        quantity: rxQuantity.value,
        pricePerUnit: pricePerUnit,
        totalPrice: finalPrice,
        uniqueCode: 0,
        notes: notesController.text.trim(),
        status: AppStrings.statusMenunggu,
        createdBy: _auth.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        estimatedDone: Helpers.getEstimatedDone(selectedServiceSpeed.value),
      );

      await _firestore
          .collection(AppStrings.ordersCollection)
          .doc(orderId)
          .set(order.toJson());

      if (onSuccess != null) {
        onSuccess(order);
      } else {
        // Fallback
        _resetForm();
        Get.back();
        Get.snackbar('Berhasil', 'Pesanan $orderId berhasil dibuat!',
            backgroundColor: AppColors.secondary, colorText: AppColors.textWhite);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat pesanan: $e',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isLoading.value = true;

      await _firestore
          .collection(AppStrings.ordersCollection)
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update local state
      if (selectedOrder.value?.orderId == orderId) {
        selectedOrder.value = selectedOrder.value?.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      Get.snackbar('Berhasil', 'Status pesanan diubah ke $newStatus',
          backgroundColor: AppColors.secondary, colorText: AppColors.textWhite);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status: $e',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    customerNameController.clear();
    customerPhoneController.clear();
    weightController.clear();
    quantityController.clear();
    notesController.clear();
    selectedGender.value = 'Laki-laki';
    selectedCategory.value = 'Kiloan';
    selectedServiceType.value = 'Komplit';
    selectedServiceSpeed.value = 'Reguler';
    currentStep.value = 0;
  }
}
