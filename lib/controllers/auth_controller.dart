import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_kuy/models/user_model.dart';
import 'package:laundry_kuy/utils/constants.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  // Fixed Admin Account (as requested)
  static const String adminUsernameInput = 'laundrykuy100315.';
  static const String adminEmailInternal = 'laundrykuy100315@laundrykuy.com';

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // UI State
  final RxBool obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Removed onClose to prevent TextEditingController used-after-disposed errors

  /// Login with Email/Username
  Future<void> login() async {
    String input = emailController.text.trim();
    String password = passwordController.text;

    if (input.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Username dan password harus diisi',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
      return;
    }

    try {
      isLoading.value = true;
      
      // Map fixed username if necessary
      String emailToAuth = input;
      if (input == adminUsernameInput) {
        emailToAuth = adminEmailInternal;
      } else if (!input.contains('@')) {
        emailToAuth = '$input@laundrykuy.com';
      }

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: emailToAuth,
        password: password,
      );

      // Special handling for the fixed admin account to ensure it's ALWAYS an admin in Firestore
      if (input == adminUsernameInput || emailToAuth == adminEmailInternal) {
        await _ensureAdminProvisioned(credential.user!.uid, emailToAuth);
      }

      await _fetchUserDataAndNavigate(credential.user!.uid);
    } catch (e) {
      Get.snackbar('Error', 'Username atau password salah',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
    } finally {
      isLoading.value = false;
    }
  }

  /// Ensures the specific admin account has an 'admin' role in Firestore
  Future<void> _ensureAdminProvisioned(String uid, String email) async {
    // We force the role to 'admin' for this specific account
    final adminUser = UserModel(
      uid: uid,
      email: email,
      name: 'Super Admin',
      role: AppStrings.roleAdmin, // Hardcoded to Admin
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection(AppStrings.usersCollection)
        .doc(uid)
        .set(adminUser.toJson(), SetOptions(merge: true));
  }

  Future<void> _fetchUserDataAndNavigate(String uid) async {
    final doc = await _firestore
        .collection(AppStrings.usersCollection)
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = UserModel.fromJson(doc.data()!, uid);
      userModel.value = data;
      _clearForm();
      
      if (data.role == AppStrings.roleAdmin) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.userTracking);
      }
    } else {
      Get.offAllNamed(AppRoutes.userTracking);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      userModel.value = null;
      Get.offAllNamed(AppRoutes.userTracking);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e',
          backgroundColor: AppColors.error, colorText: AppColors.textWhite);
    }
  }

  /// Check navigation
  Future<void> checkUserAndNavigate() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.userTracking);
      return;
    }

    await _fetchUserDataAndNavigate(user.uid);
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
  }
}
