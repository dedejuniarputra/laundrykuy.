import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_kuy/controllers/auth_controller.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';
import 'package:laundry_kuy/widgets/custom_button.dart';
import 'package:laundry_kuy/widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.userTracking);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Take only needed space
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/icon-laundry.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
  
                const SizedBox(height: 2),
  
                Text(
                  'AKSES ADMIN',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Masuk untuk mengelola pesanan laundry',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
  
                const SizedBox(height: 30),
  
                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: controller.emailController,
                          label: 'Username / Email',
                          hint: 'Masukkan email',
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                        ),
                        const SizedBox(height: 20),
                        Obx(() => CustomTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hint: 'Masukkan password',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: controller.obscurePassword.value,
                          autofillHints: const [AutofillHints.password],
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => controller.obscurePassword.toggle(),
                          ),
                        )),
                        const SizedBox(height: 32),
                        Obx(() => CustomButton(
                          text: 'Masuk Ke Dashboard',
                          onPressed: () => controller.login(),
                          isLoading: controller.isLoading.value,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
