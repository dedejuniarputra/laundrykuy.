import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_kuy/controllers/admin/item_controller.dart';

class AdminAddItemScreen extends StatelessWidget {
  const AdminAddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller admin item
    final AdminItemController controller = Get.find<AdminItemController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Item Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Nama Item
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Nama Item'),
            ),
            const SizedBox(height: 12),
            // Input Satuan (Contoh: kg, pcs)
            TextField(
              controller: controller.unitController,
              decoration: const InputDecoration(labelText: 'Satuan (misal: kg, pcs)'),
            ),
            const SizedBox(height: 12),
            // Input Harga
            TextField(
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Satuan'),
            ),
            const SizedBox(height: 12),
            // Input Catatan (Note)
            TextField(
              controller: controller.noteController,
              decoration: const InputDecoration(labelText: 'Catatan'),
            ),
            const SizedBox(height: 12),
            // Pilihan Kategori (Dropdown)
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCategory.value,
                  items: ['Kiloan', 'Satuan', 'Karpet'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    controller.selectedCategory.value = newValue ?? 'Kiloan';
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                )),
            const SizedBox(height: 32),
            // Tombol Simpan
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      controller.addNewItem();
                    },
                    child: const Text('Simpan Item'),
                  )),
          ],
        ),
      ),
    );
  }
}
