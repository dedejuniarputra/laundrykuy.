import 'package:get/get.dart';
import 'package:laundry_kuy/controllers/user/tracking_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingController>(() => TrackingController());
  }
}
