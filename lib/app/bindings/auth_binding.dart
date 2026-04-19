import 'package:get/get.dart';
import 'package:laundry_kuy/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // We use Get.put with permanent: true to ensure the AuthController
    // is never disposed during 'offAll' navigation transitions.
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
