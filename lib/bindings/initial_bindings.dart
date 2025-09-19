import 'package:carpool_connect/controllers/payment_controller';
import 'package:carpool_connect/controllers/ride_tracking_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ride_controller.dart';
import '../controllers/ride_request_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/sos_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(RideController(), permanent: true);
    Get.put(RideRequestController(), permanent: true);
    Get.put(RideTrackingController(), permanent: true);
    Get.put(PaymentController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(SosController(), permanent: true);
  }
}
