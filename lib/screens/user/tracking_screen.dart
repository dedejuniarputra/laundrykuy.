import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_kuy/controllers/auth_controller.dart';
import 'package:laundry_kuy/controllers/user/tracking_controller.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';
import 'package:laundry_kuy/widgets/custom_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    autoStart: false,
  );
  
  bool isScannerVisible = false;
  bool isScannerStarted = false;
  bool scannerHasError = false;

  Future<void> _startScanner() async {
    setState(() {
      isScannerVisible = true;
      scannerHasError = false;
      isScannerStarted = false;
    });

    try {
      // Small delay for web stability
      await Future.delayed(const Duration(milliseconds: 600));
      await scannerController.start();
      if (mounted) {
        setState(() {
          isScannerStarted = true;
        });
      }
    } catch (e) {
      debugPrint('Scanner error: $e');
      if (mounted) {
        setState(() {
          scannerHasError = true;
        });
      }
    }
  }

  void _stopScanner() {
    scannerController.stop();
    if (mounted) {
      setState(() {
        isScannerVisible = false;
        isScannerStarted = false;
      });
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingController>();
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // MAIN FORM LAYER
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24, 
                vertical: isSmallScreen ? 20 : 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Branding Logo & Title
                      GestureDetector(
                        onDoubleTap: () => Get.toNamed(AppRoutes.login),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icon-laundry.png',
                              width: isSmallScreen ? 100 : 120,
                              height: isSmallScreen ? 100 : 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'LAUNDRY.KUY',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 24 : 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      Text(
                        'Lacak status cuci anda secara real-time dengan nomor order',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Tracking Form Card
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
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
                            Text(
                              'Nomor Order',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: controller.orderIdController,
                              textCapitalization: TextCapitalization.characters,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Contoh: LKY-2026-XXXX',
                                hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
                                prefixIcon: const Icon(Icons.receipt_long_outlined),
                                suffixIcon: kIsWeb 
                                  ? null 
                                  : IconButton(
                                      icon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                                      onPressed: _startScanner,
                                      tooltip: 'Scan QR Struk',
                                    ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Obx(() => CustomButton(
                              text: 'Lihat Status',
                              onPressed: () => controller.trackOrder(),
                              isLoading: controller.isLoading.value,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SCANNER OVERLAY LAYER
          if (isScannerVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scanAreaSize = min(constraints.maxWidth * 0.75, 280.0);
                      
                      return Stack(
                        children: [
                          // Scanner View
                          if (!scannerHasError && constraints.maxWidth > 0)
                            MobileScanner(
                              controller: scannerController,
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                if (barcodes.isNotEmpty) {
                                  final String? code = barcodes.first.rawValue;
                                  if (code != null) {
                                    if (code.toUpperCase().startsWith('LKY-')) {
                                      controller.orderIdController.text = code;
                                      _stopScanner();
                                      controller.trackOrder();
                                    } else {
                                      Get.snackbar(
                                        'QR Tidak Valid',
                                        'QR Code ini bukan dari struk Laundry.kuy',
                                        backgroundColor: AppColors.error,
                                        colorText: Colors.white,
                                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                                        snackPosition: SnackPosition.TOP,
                                        duration: const Duration(seconds: 3),
                                        boxShadows: [
                                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
                                        ],
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          
                          // Backdrop Overlay (Dimmed outside scan area)
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.srcOut,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    backgroundBlendMode: BlendMode.dstOut,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: scanAreaSize,
                                    height: scanAreaSize,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Scan Area Borders
                          Center(
                            child: Container(
                              width: scanAreaSize,
                              height: scanAreaSize,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Stack(
                                children: [
                                  _buildCorner(Alignment.topLeft),
                                  _buildCorner(Alignment.topRight),
                                  _buildCorner(Alignment.bottomLeft),
                                  _buildCorner(Alignment.bottomRight),
                                ],
                              ),
                            ),
                          ),

                          // Header Info
                          Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Text(
                                  'Pindai QR Struk',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Arahkan kamera ke kode QR',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Back Button
                          Positioned(
                            top: 15,
                            left: 15,
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white),
                                onPressed: _stopScanner,
                              ),
                            ),
                          ),

                          // Loading/Error State
                          if (!isScannerStarted || scannerHasError)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (scannerHasError)
                                      const Icon(Icons.videocam_off_rounded, color: AppColors.error, size: 48)
                                    else
                                      const CircularProgressIndicator(color: AppColors.primary),
                                    const SizedBox(height: 16),
                                    Text(
                                      scannerHasError ? 'Kamera Gagal Dimuat' : 'Menyiapkan Kamera...',
                                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                    if (scannerHasError) ...[
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: _startScanner,
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Coba Lagi'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(12) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(12) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(12) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(12) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
