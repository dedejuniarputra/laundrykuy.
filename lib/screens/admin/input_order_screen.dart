import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';
import 'package:laundry_kuy/controllers/admin/order_controller.dart';
import 'package:laundry_kuy/models/order_model.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/utils/helpers.dart';
import 'package:laundry_kuy/widgets/custom_button.dart';
import 'package:laundry_kuy/widgets/custom_textfield.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InputOrderScreen extends StatelessWidget {
  const InputOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tambah Order',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Material(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  if (controller.currentStep.value > 0) {
                    controller.previousStep();
                  } else {
                    Get.back();
                  }
                },
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            // Step Indicator
            _buildStepIndicator(controller.currentStep.value),

            // Step Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildStepContent(context, controller),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    final steps = ['Pelanggan', 'Pesanan', 'Ringkasan'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isPending = index > currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Left Connector
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= currentStep
                                ? AppColors.primary
                                : const Color(0xFFF1F5F9)),
                      ),
                    ),
                    // Step Circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isPending ? Colors.white : AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPending
                              ? const Color(0xFFE2E8F0)
                              : AppColors.primary,
                          width: 2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isPending
                                      ? const Color(0xFF94A3B8)
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    // Right Connector
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == steps.length - 1
                            ? Colors.transparent
                            : (index < currentStep
                                ? AppColors.primary
                                : const Color(0xFFF1F5F9)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Label
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isPending
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, OrderController controller) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildStep1(controller);
      case 1:
        return _buildStep2(controller);
      case 2:
        return _buildStep3(context, controller);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1(OrderController controller) {
    return Form(
      key: controller.step1FormKey,
      child: SingleChildScrollView(
        key: const ValueKey('step1'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pelanggan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Masukkan data pelanggan untuk membuat pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nama Pelanggan
          CustomTextField(
            controller: controller.customerNameController,
            label: 'Nama Pelanggan',
            hint: 'Masukkan nama pelanggan',
            prefixIcon: Icons.person_outlined,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            validator: (val) {
              if (val == null || val.isEmpty) return 'Nama tidak boleh kosong';
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(val)) {
                return 'Hanya boleh berisi huruf';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Jenis Kelamin
          Text(
            'Jenis Kelamin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: AppStrings.genders.map((gender) {
                  final selected = controller.selectedGender.value == gender;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedGender.value = gender,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                            right: gender == 'Laki-laki' ? 8 : 0,
                            left: gender == 'Perempuan' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              gender == 'Laki-laki'
                                  ? Icons.male_rounded
                                  : Icons.female_rounded,
                              size: 20,
                              color: selected
                                  ? AppColors.textWhite
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              gender,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.textWhite
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: 20),

          // Nomor WhatsApp
          CustomTextField(
            controller: controller.customerPhoneController,
            label: 'Nomor WhatsApp',
            hint: '08xxxxxxxxxx',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            validator: (val) {
              if (val == null || val.isEmpty) return 'Nomor tidak boleh kosong';
              if (!val.startsWith('08')) return 'Harus diawali 08';
              if (val.length < 10) return 'Terlalu pendek';
              return null;
            },
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Kembali',
                  isOutlined: true,
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Lanjutkan',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => controller.nextStep(),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildStep2(OrderController controller) {
    return Form(
      key: controller.step2FormKey,
      child: SingleChildScrollView(
        key: const ValueKey('step2'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            _sectionLabel('Kategori'),
            const SizedBox(height: 12),
            Row(
              children: AppStrings.categories.asMap().entries.map((entry) {
                final index = entry.key;
                final cat = entry.value;
                IconData icon;
                switch (cat) {
                  case 'Satuan':
                    icon = Icons.checkroom_rounded;
                    break;
                  case 'Kiloan':
                    icon = Icons.scale_rounded;
                    break;
                  case 'Campuran':
                    icon = Icons.inventory_2_rounded;
                    break;
                  default:
                    icon = Icons.inventory_2_rounded;
                }
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < AppStrings.categories.length - 1 ? 12 : 0,
                    ),
                    child: Obx(() => _buildSelectionCard(
                          title: cat,
                          icon: icon,
                          isSelected: controller.selectedCategory.value == cat,
                          onTap: () => controller.selectedCategory.value = cat,
                          isVertical: true,
                        )),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Jenis Layanan
            _sectionLabel('Jenis Layanan'),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _serviceCard(controller, 'Komplit', Icons.auto_awesome_rounded,
                      'Cuci + Setrika', width),
                  _serviceCard(controller, 'Strika', Icons.iron_rounded,
                      'Hanya Setrika', width),
                  _serviceCard(controller, 'Kering', Icons.dry_cleaning_rounded,
                      'Hanya Cuci', width),
                  _serviceCard(controller, 'Slep', Icons.shopping_bag_rounded,
                      'Setrika Uap', width),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Kecepatan Layanan
            _sectionLabel('Kecepatan Layanan'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildSelectionCard(
                        title: 'Reguler',
                        subtitle: '2-3 Hari',
                        icon: Icons.schedule_rounded,
                        isSelected:
                            controller.selectedServiceSpeed.value == 'Reguler',
                        onTap: () =>
                            controller.selectedServiceSpeed.value = 'Reguler',
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildSelectionCard(
                        title: 'Express',
                        subtitle: '1 Hari',
                        icon: Icons.flash_on_rounded,
                        isSelected:
                            controller.selectedServiceSpeed.value == 'Express',
                        onTap: () =>
                            controller.selectedServiceSpeed.value = 'Express',
                      )),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Berat / Jumlah
            Obx(() {
              final isWeightBased =
                  controller.selectedCategory.value == 'Kiloan' ||
                      controller.selectedCategory.value == 'Campuran';
              return CustomTextField(
                controller: isWeightBased
                    ? controller.weightController
                    : controller.quantityController,
                label: isWeightBased ? 'Berat (kg)' : 'Jumlah (pcs)',
                hint: isWeightBased ? '0.0' : '0',
                prefixIcon: isWeightBased
                    ? Icons.scale_rounded
                    : Icons.format_list_numbered_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  if (isWeightBased)
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$'))
                  else
                    FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (val) {
                  if (isWeightBased) {
                    controller.rxWeight.value = double.tryParse(val) ?? 0;
                  } else {
                    controller.rxQuantity.value = int.tryParse(val) ?? 0;
                  }
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return isWeightBased ? 'Masukkan berat' : 'Masukkan jumlah';
                  }
                  final n = double.tryParse(val);
                  if (n == null || n <= 0) return 'Tidak valid';
                  return null;
                },
              );
            }),

            const SizedBox(height: 24),

            // Ringkasan Harga
            Obx(() {
              final total = controller.calculatedPrice;
              if (total <= 0) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Harga',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _priceSummaryRow(
                      'Harga Dasar',
                      Helpers.formatRupiah(controller.baseTotal),
                    ),
                    if (controller.surchargeTotal > 0) ...[
                      const SizedBox(height: 8),
                      _priceSummaryRow(
                        'Biaya ${controller.selectedServiceSpeed.value}',
                        '+ ${Helpers.formatRupiah(controller.surchargeTotal)}',
                        isSurcharge: true,
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          Helpers.formatRupiah(total),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Catatan
            CustomTextField(
              controller: controller.notesController,
              label: 'Catatan Khusus (Opsional)',
              hint: 'e.g. Gunakan deterjen lembut, jangan putar kering...',
              prefixIcon: Icons.note_alt_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Kembali',
                    isOutlined: true,
                    onPressed: () => controller.previousStep(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Lanjutkan',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => controller.nextStep(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSummaryRow(String label, String value,
      {bool isSurcharge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSurcharge ? Colors.orange.shade700 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _serviceCard(OrderController controller, String label, IconData icon,
      String desc, double width) {
    return SizedBox(
      width: width,
      child: Obx(() => _buildSelectionCard(
            title: label,
            subtitle: desc,
            icon: icon,
            isSelected: controller.selectedServiceType.value == label,
            onTap: () => controller.selectedServiceType.value = label,
          )),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isVertical = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 28),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Step 3: Ringkasan Pesanan
  Widget _buildStep3(BuildContext context, OrderController controller) {
    return SingleChildScrollView(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Physical Receipt Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Receipt Header
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RINGKASAN PESANAN BARU',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                _dottedDivider(),

                // Customer Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _receiptHeader('PELANGGAN'),
                      const SizedBox(height: 16),
                      _receiptRow('Nama', controller.customerNameController.text, isBold: true),
                      const SizedBox(height: 8),
                      _receiptRow('WhatsApp', controller.customerPhoneController.text),
                      const SizedBox(height: 8),
                      _receiptRow('Gender', controller.selectedGender.value),
                    ],
                  ),
                ),
                _dottedDivider(),
                // Services Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _receiptHeader('RINCIAN LAYANAN'),
                      const SizedBox(height: 16),
                      
                      // Item Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${controller.selectedServiceType.value} (${controller.selectedCategory.value})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${controller.selectedCategory.value == 'Kiloan' || controller.selectedCategory.value == 'Campuran' ? controller.rxWeight.value : controller.rxQuantity.value}${controller.unitLabel} x ${Helpers.formatRupiah(controller.pricePerUnit)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Helpers.formatRupiah(controller.baseTotal),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      // Surcharges
                      if (controller.surchargeTotal > 0) ...[
                        const SizedBox(height: 12),
                        _receiptRow('Layanan ${controller.selectedServiceSpeed.value}', Helpers.formatRupiah(controller.surchargeTotal)),
                      ],
                    ],
                  ),
                ),
                _dottedDivider(),
                // Total Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ESTIMASI TOTAL',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Obx(() => Text(
                        Helpers.formatRupiah(controller.calculatedPrice),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Footer Actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Kembali',
                  isOutlined: true,
                  onPressed: () => controller.previousStep(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => CustomButton(
                      text: 'Buat Pesanan',
                      icon: Icons.add_task_rounded,
                      isLoading: controller.isLoading.value,
                      onPressed: () => controller.submitOrder(
                        onSuccess: (order) => _showSuccessDialog(context, order, controller),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, OrderModel order, OrderController controller) {
    Get.dialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon (Cleaner Version)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Pesanan Berhasil Dibuat',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'ORDER ID',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              
              // Clean White Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  order.orderId,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // QR Code Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: QrImageView(
                  data: order.orderId,
                  version: QrVersions.auto,
                  size: 130,
                  gapless: false,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Lihat Struk',
                onPressed: () {
                  Get.back(); // Close dialog
                  // Navigate to detail order
                  Get.offNamed(AppRoutes.adminOrderDetail, arguments: order);
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _summaryCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _costBreakdownRow({
    required String title,
    required String amount,
    required String subtitle,
    bool isSurcharge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSurcharge ? Colors.orange.shade700 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _chipSelector(
    List<String> options,
    String selected,
    Function(String) onSelect, {
    Map<String, IconData>? icons,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icons != null && icons.containsKey(option)) ...[
                  Icon(
                    icons[option],
                    size: 16,
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false, bool isAccent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isAccent ? AppColors.primary : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _dottedDivider() {
    return Row(
      children: List.generate(
        80,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.3),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
