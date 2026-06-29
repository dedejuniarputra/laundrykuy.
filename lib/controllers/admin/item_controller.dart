import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_kuy/models/item_model.dart';
import 'package:laundry_kuy/utils/constants.dart'; // Untuk warna AppColors dsb.

class AdminItemController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Controller Input Form
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  final noteController = TextEditingController();
  
  // State Rx
  final RxString selectedCategory = 'Kiloan'.obs;
  final RxBool isActive = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    // Selalu dispose text controller untuk mencegah kebocoran memori
    nameController.dispose();
    unitController.dispose();
    priceController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // 2. Fungsi menambahkan Item Baru ke Firestore
  Future<void> addNewItem() async {
    try {
      isLoading.value = true;

      // Membuat referensi dokumen baru di Firestore untuk mendapatkan ID unik
      final DocumentReference docRef = _firestore.collection('items').doc();

      // Membuat objek ItemModel dari data input form
      final newItem = ItemModel(
        itemId: docRef.id,
        name: nameController.text.trim(),
        unit: unitController.text.trim(),
        price: double.tryParse(priceController.text) ?? 0.0,
        note: noteController.text.trim(),
        category: selectedCategory.value,
        isActive: isActive.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simpan data model ke Firestore (dikonversi menggunakan toJson())
      await docRef.set(newItem.toJson());

      _resetForm();
      Get.back(); // Kembali ke halaman daftar item
      Get.snackbar('Berhasil', 'Item ${newItem.name} berhasil ditambahkan!',
          backgroundColor: AppColors.secondary, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan item: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    nameController.clear();
    unitController.clear();
    priceController.clear();
    noteController.clear();
    selectedCategory.value = 'Kiloan';
    isActive.value = true;
  }
}
