import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_kuy/controllers/user/tracking_controller.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/utils/helpers.dart';


class TrackingResultScreen extends StatelessWidget {
  const TrackingResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grayish-blue for contrast
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Hasil Tracking',
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
      ),
      body: Obx(() {
        final order = controller.trackedOrder.value;
        if (order == null) {
          return const Center(child: Text('Pesanan tidak ditemukan'));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Optimasi Web/Tablet
            child: RefreshIndicator(
              onRefresh: () => controller.refreshTracking(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Reduced top padding
                child: Column(
                  children: [
                    // 1. Branding Header (Asset Logo + Bold Uppercase Title)
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icon-laundry.png',
                            height: 90, // Slightly smaller logo
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12), // Reduced gap
                          Text(
                            'LAUNDRY.KUY TRACK',
                            style: GoogleFonts.poppins(
                              fontSize: 22, // Adjusted font size
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20), // Reduced gap

                    // 2. Status Card (Current Status + Horizontal Timeline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24), // Larger padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20), // More rounded
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Status Saat Ini',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Status Badge (Pill - Larger)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Helpers.getStatusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Helpers.getStatusColor(order.status),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Horizontal Timeline (Implemented below with larger icons)
                          _buildHorizontalTimeline(order.status),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Order Details Card (Divided Rows)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _detailRow('Nomor Order', order.orderId),
                          _dottedDivider(),
                          _detailRow('Nama Pelanggan', order.customerName),
                          _dottedDivider(),
                          _detailRow('Tanggal Masuk', Helpers.formatDateTime(order.createdAt)),
                          _dottedDivider(),
                          _detailRow('Estimasi Selesai', Helpers.formatDate(order.estimatedDone)),
                          _dottedDivider(),
                          _detailRow('Total Harga', Helpers.formatRupiah(order.totalPrice), isTotal: true),
                          const SizedBox(height: 12),
                          _buildSerratedEdge(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50, // Soft orange background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200), // Subtle orange border
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.orange.shade800, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Data resi pesanan akan otomatis terhapus sesaat setelah status cucian Selesai diambil.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.orange.shade900, // Darker orange text for readability
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHorizontalTimeline(String currentStatus) {
    final statusOrder = [
      AppStrings.statusMenunggu,
      AppStrings.statusDiproses,
      AppStrings.statusSelesai,
    ];

    final labels = ['Pending', 'Proses', 'Selesai'];
    final icons = [Icons.access_time_filled_rounded, Icons.local_laundry_service_rounded, Icons.check_circle_rounded];

    int currentIndex = statusOrder.indexOf(currentStatus);

    return Row(
      children: List.generate(statusOrder.length, (index) {
        final isActive = index <= currentIndex;
        final isLast = index == statusOrder.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  // Line before
                  Expanded(
                    child: Container(
                      height: 3, // Thicker line
                      color: index == 0
                          ? Colors.transparent
                          : (isActive ? AppColors.primary : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  // Icon Dot (Larger)
                  Container(
                    padding: const EdgeInsets.all(8), // More padding
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Icon(
                      icons[index],
                      size: 18, // Larger icon
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                  // Line after
                  Expanded(
                    child: Container(
                      height: 3, // Thicker line
                      color: isLast
                          ? Colors.transparent
                          : (index < currentIndex ? AppColors.primary : const Color(0xFFE2E8F0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                labels[index],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _detailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // More padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13, // Slightly larger
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14, // Slightly larger
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
              color: isTotal ? AppColors.primary : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: List.generate(
          150,
          (index) => Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.3),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSerratedEdge() {
    return SizedBox(
      height: 10,
      width: double.infinity,
      child: Row(
        children: List.generate(
          20,
          (index) => Expanded(
            child: CustomPaint(
              painter: TrianglePainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1F5F9) // Match background color for cut-out effect
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
