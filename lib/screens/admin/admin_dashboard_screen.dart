import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_kuy/controllers/admin/dashboard_controller.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';
import 'package:laundry_kuy/widgets/order_card.dart';
import 'package:laundry_kuy/widgets/loading_widget.dart';
import 'package:laundry_kuy/controllers/admin/order_controller.dart';
import 'package:laundry_kuy/controllers/auth_controller.dart';
import 'package:laundry_kuy/utils/helpers.dart';
import 'package:laundry_kuy/utils/report_helper.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();

    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(dashboardCtrl),
        body: _buildBody(dashboardCtrl),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.adminInputOrder),
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNavBar(dashboardCtrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DashboardController controller) {
    String title = 'Beranda';
    switch (controller.currentIndex.value) {
      case 1:
        title = 'Daftar Pesanan';
        break;
      case 2:
        title = 'Laporan Keuangan';
        break;
      case 3:
        title = 'Pengaturan';
        break;
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      leading: (controller.currentIndex.value != 0)
          ? Container(
              margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Material(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => controller.currentIndex.value = 0,
                  borderRadius: BorderRadius.circular(10),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        if (controller.currentIndex.value == 1)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _showDeleteAllConfirmation(controller),
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.red.withOpacity(0.3),
                highlightColor: Colors.red.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        // Logout Button - Visible ONLY on Beranda tab
        if (controller.currentIndex.value == 0)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Material(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => _showLogoutConfirmation(),
                borderRadius: BorderRadius.circular(10),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(DashboardController controller) {
    switch (controller.currentIndex.value) {
      case 0:
        return _buildHomeView(controller);
      case 1:
        return _buildOrdersView(controller);
      case 2:
        return _buildLaporanView(controller);
      case 3:
        return _buildSettingsView(controller);
      default:
        return _buildHomeView(controller);
    }
  }

  Widget _buildHomeView(DashboardController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Bisnis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statTile(
                'Total Pesanan',
                controller.totalOrders.value.toString(),
                const Color(0xFF0EA5E9),
              ),
              const SizedBox(width: 12),
              _statTile(
                'Proses',
                controller.processingOrders.value.toString(),
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile(
                'Menunggu',
                controller.pendingOrders.value.toString(),
                const Color(0xFF6366F1),
              ),
              const SizedBox(width: 12),
              _statTile(
                'Selesai',
                controller.completedOrders.value.toString(),
                const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Terbaru',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => controller.currentIndex.value = 1,
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentOrders(controller),
        ],
      ),
    );
  }

  Widget _buildOrdersView(DashboardController controller) {
    return Column(
      children: [
        // Status Filter Tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statusTab(
                controller,
                'Menunggu',
                controller.pendingOrders.value,
              ),
              _statusTab(
                controller,
                'Diproses',
                controller.processingOrders.value,
              ),
              _statusTab(
                controller,
                'Selesai',
                controller.completedOrders.value,
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Cari Pelanggan...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Orders List
        Expanded(child: _buildFilteredOrders(controller)),
      ],
    );
  }

  Widget _buildRecentOrders(DashboardController controller) {
    if (controller.isLoading.value) return const LoadingWidget(itemCount: 3);
    if (controller.recentOrders.isEmpty) return _emptyState();

    return Column(
      children: controller.recentOrders
          .map(
            (order) => OrderCard(
              order: order,
              onTap: () {
                final orderCtrl = Get.find<OrderController>();
                orderCtrl.selectedOrder.value = order;
                Get.toNamed(AppRoutes.adminOrderDetail, arguments: order);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildFilteredOrders(DashboardController controller) {
    final filtered = controller.allOrders.where((o) {
      final matchesStatus = o.status == controller.selectedStatus.value;
      final matchesSearch = o.customerName.toLowerCase().contains(
        controller.searchQuery.value.toLowerCase(),
      );
      return matchesStatus && matchesSearch;
    }).toList();

    if (controller.isLoading.value) return const LoadingWidget(itemCount: 5);
    if (filtered.isEmpty) return _emptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => OrderCard(
        order: filtered[index],
        onTap: () {
          final orderCtrl = Get.find<OrderController>();
          orderCtrl.selectedOrder.value = filtered[index];
          Get.toNamed(AppRoutes.adminOrderDetail, arguments: filtered[index]);
        },
      ),
    );
  }

  Widget _statusTab(DashboardController controller, String label, int count) {
    bool isSelected = controller.selectedStatus.value == label;
    // Define functional colors
    Color statusColor;
    switch (label) {
      case 'Menunggu':
        statusColor = Colors.amber.shade700;
        break;
      case 'Diproses':
        statusColor = AppColors.primary;
        break;
      case 'Selesai':
        statusColor = const Color.fromARGB(255, 0, 200, 84); // Vibrant Green
        break;
      default:
        statusColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => controller.selectedStatus.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? statusColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? statusColor : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(
    String label,
    String value,
    Color color, {
    bool isCurrency = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCurrency ? Icons.payments_rounded : Icons.analytics_rounded,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: isCurrency ? 14 : 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(DashboardController controller) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Container(
        height: 64, // Normalized height
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: _navItem(controller, 0, Icons.home_rounded, 'Beranda'),
            ),
            Expanded(
              child: _navItem(
                controller,
                1,
                Icons.receipt_long_rounded,
                'Pesanan',
              ),
            ),
            const SizedBox(width: 56), // Proper space for FAB
            Expanded(
              child: _navItem(
                controller,
                2,
                Icons.bar_chart_rounded,
                'Laporan',
              ),
            ),
            Expanded(
              child: _navItem(controller, 3, Icons.settings_rounded, 'Setelan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    DashboardController controller,
    int index,
    IconData icon,
    String label,
  ) {
    bool isSelected = controller.currentIndex.value == index;
    return InkWell(
      onTap: () => controller.changePage(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmation(DashboardController controller) {
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
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 56,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Hapus Semua Pesanan?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tindakan ini akan menghapus seluruh data pesanan secara permanen dari sistem.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.5,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFFF8FAFC),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteAllOrders();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hapus Semua',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada data',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
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
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 56,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Konfirmasi Keluar',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin keluar dari akun Admin?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.5,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFFF8FAFC),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        AuthController.to.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildLaporanView(DashboardController controller) {
    return Column(
      children: [
        _buildMonthFilter(controller),
        Expanded(
          child: Obx(() {
            final orders = controller.filteredReportOrders;

            if (controller.isLoading.value)
              return const LoadingWidget(itemCount: 5);
            if (orders.isEmpty) return _emptyState();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportSummary(controller),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Transaksi',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => ReportHelper.printMonthlyReport(
                            month: controller.selectedReportMonth.value,
                            year: controller.selectedReportYear.value,
                            orders: orders,
                            totalRevenue: controller.monthlyRevenue,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cetak PDF',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...orders
                      .map(
                        (order) => OrderCard(
                          order: order,
                          onTap: () {
                            final orderCtrl = Get.find<OrderController>();
                            orderCtrl.selectedOrder.value = order;
                            Get.toNamed(
                              AppRoutes.adminOrderDetail,
                              arguments: order,
                            );
                          },
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthFilter(DashboardController controller) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Periode',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Month Selector
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: controller.selectedReportMonth.value,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        items: List.generate(
                          12,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(months[index]),
                          ),
                        ),
                        onChanged: (val) =>
                            controller.selectedReportMonth.value = val!,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Year Selector
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: controller.selectedReportYear.value,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [DateTime.now().year, DateTime.now().year - 1]
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            controller.selectedReportYear.value = val!,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummary(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Pendapatan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Helpers.formatRupiah(controller.monthlyRevenue),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Pesanan',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${controller.monthlyOrderCount}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(String title) {
    return Center(
      child: Text(
        '$title Screen (Segera Hadir)',
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingsView(DashboardController controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                'Menu Admin',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Baris 1: Kelola Item & Kelola Pelanggan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAdminShortcut(
                    title: 'Kelola Item',
                    icon: Icons.list_alt_rounded,
                    color: AppColors.secondary,
                    onTap: () => Get.toNamed(AppRoutes.adminAddItem),
                  ),
                  _buildAdminShortcut(
                    title: 'Kelola Pelanggan',
                    icon: Icons.people_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      // TODO: Navigasi ke halaman kelola pelanggan
                      Get.snackbar(
                        'Info',
                        'Fitur Kelola Pelanggan akan segera hadir!',
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Baris 2: Kelola Karyawan & Atur Notifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAdminShortcut(
                    title: 'Kelola Karyawan',
                    icon: Icons.badge_outlined,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      // TODO: Navigasi ke halaman kelola karyawan
                      Get.snackbar(
                        'Info',
                        'Fitur Kelola Karyawan akan segera hadir!',
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      );
                    },
                  ),
                  _buildAdminShortcut(
                    title: 'Atur Notifikasi',
                    icon: Icons.notifications_none_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      // TODO: Navigasi ke halaman notifikasi
                      Get.snackbar(
                        'Info',
                        'Fitur Notifikasi akan segera hadir!',
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        _settingDropdown(
          title: 'Kebijakan Privasi',
          icon: Icons.privacy_tip_outlined,
          color: const Color(0xFF6366F1),
          content:
              'Kami berkomitmen untuk melindungi privasi Anda. Semua data pribadi yang kami kumpulkan hanya digunakan untuk keperluan layanan Laundry.kuy dan tidak akan dibagikan kepada pihak ketiga tanpa izin Anda.',
        ),
        _settingDropdown(
          title: 'Kebijakan Layanan',
          icon: Icons.description_outlined,
          color: const Color(0xFF0EA5E9),
          content:
              'Dengan menggunakan layanan kami, Anda menyetujui syarat dan ketentuan yang berlaku. Kami bertanggung jawab atas kualitas pencucian sesuai standar, namun tidak bertanggung jawab atas kerusakan luntur pada pakaian yang memang rentan.',
        ),
        _settingDropdown(
          title: 'Pusat Bantuan (FAQ)',
          icon: Icons.help_outline_rounded,
          color: const Color(0xFFF59E0B),
          content:
              '• Berapa lama estimasi cuci? Biasanya 1-3 hari tergantung paket.\n• Bagaimana jika pakaian hilang? Kami akan memberikan ganti rugi sesuai ketentuan.\n• Apakah ada layanan antar jemput? Tidak, Anda harus mengambil cucian sendiri.',
        ),
        _settingDropdown(
          title: 'Tentang Aplikasi',
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF10B981),
          contentWidget: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dry_cleaning_rounded,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Laundry.kuy',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Versi 1.0.0 (Stable)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Solusi digital terintegrasi untuk manajemen bisnis laundry yang lebih modern, efisien, dan transparan.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingDropdown({
    required String title,
    required IconData icon,
    required Color color,
    String? content,
    Widget? contentWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          visualDensity: VisualDensity.compact,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 20, 20),
              child:
                  contentWidget ??
                  Text(
                    content ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminShortcut({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
