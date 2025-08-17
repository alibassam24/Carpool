import 'package:carpool_connect/models/ride_model.dart';
import 'package:get/get.dart';
import 'package:carpool_connect/models/ride_model.dart'; // 👈 make sure path matches your Ride model

class RideController extends GetxController {
  var rides = <Ride>[].obs;

  void addRide(Ride ride) {
    rides.add(ride);
  }

  // 🔹 Add a new request to a ride
  void addRequest(String rideId, RideRequest request) {
    final ride = rides.firstWhereOrNull((r) => r.id == rideId);
    if (ride != null) {
      ride.requests.add(request);
      ride.requests.refresh();
    }
  }

  // 🔹 Accept a request
  void acceptRequest(Ride ride, RideRequest request) {
    final i = ride.requests.indexOf(request);
    if (i != -1) {
      ride.requests[i] = request.copyWith(status: "accepted");
      ride.requests.refresh();
    }
  }

  // 🔹 Reject a request
  void rejectRequest(Ride ride, RideRequest request) {
    final i = ride.requests.indexOf(request);
    if (i != -1) {
      ride.requests[i] = request.copyWith(status: "rejected");
      ride.requests.refresh();
    }
  }
}
