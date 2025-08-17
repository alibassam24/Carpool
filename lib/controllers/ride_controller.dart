import 'package:carpool_connect/services/ride_service.dart';
import 'package:get/get.dart';

class RideController extends GetxController {
  var rides = <Ride>[].obs;

  void addRide(Ride ride) {
    rides.add(ride);
  }
}
