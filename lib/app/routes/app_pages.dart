import 'package:get/get.dart';
import 'package:laundry_kuy/app/routes/app_routes.dart';
import 'package:laundry_kuy/app/bindings/auth_binding.dart';
import 'package:laundry_kuy/app/bindings/admin_binding.dart';
import 'package:laundry_kuy/app/bindings/user_binding.dart';
import 'package:laundry_kuy/screens/splash_screen.dart';
import 'package:laundry_kuy/screens/auth/login_screen.dart';
import 'package:laundry_kuy/screens/admin/admin_dashboard_screen.dart';
import 'package:laundry_kuy/screens/admin/input_order_screen.dart';
import 'package:laundry_kuy/screens/admin/order_list_screen.dart';
import 'package:laundry_kuy/screens/admin/order_detail_screen.dart';
import 'package:laundry_kuy/screens/user/tracking_screen.dart';
import 'package:laundry_kuy/screens/user/tracking_result_screen.dart';
import 'package:laundry_kuy/app/middlewares/auth_middleware.dart';

class AppPages {
  static final pages = [
    // Root route for Web support and session auto-check
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()], // Protected Login
    ),

    // Admin Pages
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminInputOrder,
      page: () => const InputOrderScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminOrderList,
      page: () => const OrderListScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminOrderDetail,
      page: () => const OrderDetailScreen(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // User Pages
    GetPage(
      name: AppRoutes.userTracking,
      page: () => const TrackingScreen(),
      binding: UserBinding(),
      middlewares: [AuthMiddleware()], // Public but monitored
    ),
    GetPage(
      name: AppRoutes.userTrackingResult,
      page: () => const TrackingResultScreen(),
      binding: UserBinding(),
      middlewares: [AuthMiddleware()], // Public but monitored
    ),
  ];
}
