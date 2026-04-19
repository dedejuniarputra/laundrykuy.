import 'package:get/get.dart';
import 'package:laundry_kuy/controllers/admin/dashboard_controller.dart';
import 'package:laundry_kuy/controllers/admin/order_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
  }
}
