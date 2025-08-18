// mock_data.dart
import 'package:carpool_connect/models/ride_model.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:get/get.dart';

class MockData {
  static List<Ride> generateMockRides() {
    final currentUser = UserService.currentUser;

    return [
      Ride(
        id: "ride1",
        origin: "Islamabad",
        destination: "Rawalpindi",
        seats: 3,
        //driverId: currentUser?.id ?? "driver1",
        driverId: "1",
        when: DateTime.now().add(const Duration(hours: 2)),
        requests: [
          RideRequest(
            passengerId: "passenger1",
            passengerName: "Alice",
            seatsRequested: 1,
            status: "pending",
          ),
          RideRequest(
            passengerId: "passenger2",
            passengerName: "Bob",
            seatsRequested: 2,
            status: "accepted",
          ),
        ],
      ),
      Ride(
        id: "ride2",
        origin: "F-6",
        destination: "Blue Area",
        seats: 2,
        driverId: "2",
        //driverId: currentUser?.id ?? "driver2",
        when: DateTime.now().add(const Duration(days: 1)),
        requests: [
          RideRequest(
            passengerId: "passenger3",
            passengerName: "Charlie",
            seatsRequested: 1,
            status: "rejected",
          ),
        ],
      ),
      Ride(
        id: "ride3",
        origin: "G-10",
        destination: "F-8",
        seats: 1,
        driverId: "3",
       //driverId: currentUser?.id ?? "driver3",
        when: DateTime.now().add(const Duration(hours: 5)),
        requests: [],
      ),
    ].obs;
  }
}
