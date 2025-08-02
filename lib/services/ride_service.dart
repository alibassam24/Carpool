// lib/services/ride_service.dart

class Ride {
  final String id;
  final String driverName;
  final String time;
  final double price;
  final bool isJoined;

  Ride({
    required this.id,
    required this.driverName,
    required this.time,
    required this.price,
    this.isJoined = false,
  });
}

class RideService {
  static List<Ride> dummyRides = [
    Ride(id: 'r1', driverName: 'Ahmed Driver', time: '10:00 AM', price: 300),
    Ride(id: 'r2', driverName: 'Sara Carpooler', time: '1:00 PM', price: 250),
  ];

  static List<Ride> getAllRides() => dummyRides;

  static bool joinRide(String rideId, String userId) {
    try {
      final index = dummyRides.indexWhere((r) => r.id == rideId);
      if (index != -1) {
        dummyRides[index] = Ride(
          id: dummyRides[index].id,
          driverName: dummyRides[index].driverName,
          time: dummyRides[index].time,
          price: dummyRides[index].price,
          isJoined: true,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
