import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_kuy/controllers/admin/order_controller.dart';
import 'package:laundry_kuy/models/order_model.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/utils/helpers.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderDetailScreen extends GetView<OrderController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Process arguments in a post-frame callback to avoid build conflicts
    final OrderModel? argOrder = Get.arguments as OrderModel?;
    if (argOrder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectedOrder.value = argOrder;
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Detail Struk',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(10),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  // Notification for printer connection status (Compact Version)
                  Get.rawSnackbar(
                    messageText: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.print_disabled_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Printer belum tersambung!',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.white,
                    margin: const EdgeInsets.all(20),
                    borderRadius: 12,
                    duration: const Duration(seconds: 3),
                    snackPosition: SnackPosition.TOP,
                    boxShadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.print_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('Pesanan tidak ditemukan'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Status Indicator (Outside Struk)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Helpers.getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Helpers.getStatusColor(order.status).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      order.status == AppStrings.statusSelesai ? Icons.verified_rounded : Icons.info_outline_rounded,
                      size: 18,
                      color: Helpers.getStatusColor(order.status),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'STATUS: ${order.status.toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Helpers.getStatusColor(order.status),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. The Main Receipt (Paper)
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
                    // Header Branding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Branding Info (Left)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.appName.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'JL. SAMRATULANGI NO.15 BANDAR LAMPUNG',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  'WA: 0822-8985-8037',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // QR Code (Right)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: QrImageView(
                              data: order.orderId,
                              version: QrVersions.auto,
                              size: 70,
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
                        ],
                      ),
                    ),

                    _dottedDivider(),

                    // Order Info Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _receiptRow('Order ID', order.orderId, isBold: true),
                          const SizedBox(height: 10),
                          _receiptRow('Tanggal Masuk', DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt)),
                          const SizedBox(height: 10),
                          _receiptRow('Tanggal Selesai', DateFormat('dd MMM yyyy, HH:mm').format(order.estimatedDone)),
                        ],
                      ),
                    ),

                    _dottedDivider(),

                    // Customer Details Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _receiptHeader('PELANGGAN'),
                          const SizedBox(height: 16),
                          _receiptRow('Nama', order.customerName, isBold: true),
                          const SizedBox(height: 8),
                          _receiptRow('No. WhatsApp', order.customerPhone),
                        ],
                      ),
                    ),

                    _dottedDivider(),

                    // Items & Services List
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _receiptHeader('RINCIAN LAYANAN'),
                          const SizedBox(height: 20),
                          
                          // Item Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${order.serviceType} (${order.category})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      '${order.displayAmount} x ${Helpers.formatRupiah(order.pricePerUnit)}',
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
                                Helpers.formatRupiah(order.pricePerUnit * (order.category == 'Satuan' ? order.quantity : order.weight)),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          
                          // Surcharges
                          if (order.serviceSpeed == 'Express') ...[
                            const SizedBox(height: 14),
                            _receiptRow('Layanan Express (Flat)', 'Rp 4.000'),
                          ],
                        ],
                      ),
                    ),

                    _dottedDivider(),

                    // Combined Total Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL BAYAR',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            Helpers.formatRupiah(order.totalPrice),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Greetings Footer
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 40),
                      child: Column(
                        children: [
                          _dottedDivider(),
                          const SizedBox(height: 32),
                          Text(
                            'TERIMA KASIH',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KEPUASAN ANDA ADALAH PRIORITAS KAMI',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. Status Action Buttons (Outside Struk)
              _buildActionButtons(order, controller),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
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

  Widget _buildActionButtons(OrderModel order, OrderController controller) {
    if (order.status == AppStrings.statusMenunggu) {
      return _actionButton(
        'PROSES PESANAN',
        Icons.local_laundry_service_rounded,
        AppColors.primary,
        () => _showStatusConfirm(controller, order.orderId, AppStrings.statusDiproses),
      );
    }

    if (order.status == AppStrings.statusDiproses) {
      return _actionButton(
        'SELESAIKAN PESANAN',
        Icons.check_circle_rounded,
        const Color(0xFF10B981),
        () => _showStatusConfirm(controller, order.orderId, AppStrings.statusSelesai),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 20),
          const SizedBox(width: 12),
          Text(
            'PESANAN TELAH SELESAI',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF059669),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ),
    );
  }

  void _showStatusConfirm(OrderController controller, String orderId, String newStatus) {
    Get.dialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sync_rounded, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Konfirmasi Status',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B), height: 1.5),
                  children: [
                    const TextSpan(text: 'Ubah status pesanan ini menjadi '),
                    TextSpan(
                      text: newStatus.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFFF8FAFC),
                      ),
                      child: Text('Batal', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.updateOrderStatus(orderId, newStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Ya, Ubah', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
