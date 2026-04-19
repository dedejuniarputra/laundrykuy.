import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laundry_kuy/controllers/auth_controller.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';
import 'package:laundry_kuy/utils/constants.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;
    final authController = Get.isRegistered<AuthController>() 
        ? Get.find<AuthController>() 
        : Get.put(AuthController(), permanent: true);
    final userRole = authController.userModel.value?.role;

    // 1. Admin Route Protection
    if (route != null && route.startsWith('/aX9vP2/')) {
      if (user == null) {
        return const RouteSettings(name: AppRoutes.login);
      }
      
      if (userRole != null && userRole != AppStrings.roleAdmin) {
        return const RouteSettings(name: AppRoutes.userTracking);
      }
    }

    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;
    final authController = Get.isRegistered<AuthController>() 
        ? Get.find<AuthController>() 
        : Get.put(AuthController(), permanent: true);
    final userRole = authController.userModel.value?.role;

    // If already logged in
    if (user != null) {
      // If we don't know the role yet, don't redirect (let the page handle initialization)
      if (userRole == null) return null;
      
      if (userRole == AppStrings.roleAdmin) {
        return const RouteSettings(name: AppRoutes.adminDashboard);
      } else {
        return const RouteSettings(name: AppRoutes.userTracking);
      }
    }

    return null;
  }
}
