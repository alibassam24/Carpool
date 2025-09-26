// lib/screens/rider/rides_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/ride_service.dart';
import '../../services/user_service.dart';
import '../../widgets/ride_details.dart';
import '../../core/result.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final RideService _rideService = RideService();
  late final Stream<List<Map<String, dynamic>>> _rideStream;

  @override
  void initState() {
    super.initState();
    _rideStream = _rideService.streamRides();
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Search Rides",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSearchField("From", Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildSearchField("To", Icons.location_on),
              const SizedBox(height: 12),
              _buildSearchField("Time (optional)", Icons.access_time),
              const SizedBox(height: 12),
              _buildSearchField("Max Price (optional)", Icons.attach_money),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: implement search with RPC params
                },
                icon: const Icon(Icons.search),
                label: const Text("Find Rides"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(String label, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Available Rides"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _rideStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = snapshot.data!;
          if (rides.isEmpty) {
            return const Center(child: Text("No active rides available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];

              return Card(
                color: const Color(0xFFE6F2EF),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.directions_car,
                      color: Color(0xFF255A45)),
                  title: Text(
                    ride['origin_text'] ?? 'Unknown Origin',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${ride['destination_text'] ?? 'Unknown Destination'} • Rs ${ride['price']} • ${ride['date_time']}",
                  ),
                  onTap: () {
                    final summary = RideSummary(
                      rideId: ride['id'],
                      driverName: "Driver", // TODO: join with users
                      driverPhotoUrl: "",
                      driverRating: 4.5,
                      carModel: "Car Model",
                      carPlate: "ABC-123",
                      seatsLeft: ride['passenger_count'] ?? 0,
                      dateTime: DateTime.parse(ride['date_time']),
                      originLat: ride['origin_lat'],
                      originLng: ride['origin_lng'],
                      destLat: ride['destination_lat'],
                      destLng: ride['destination_lng'],
                      price: double.parse(ride['price'].toString()),
                      carpoolerId: ride['carpooler_id'],
                    );

                    Get.to(() => RideDetailsScreen(
                        ride: summary, myUserId: UserService.currentUser.id));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSearchBottomSheet(context),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search),
        label: const Text("Search"),
      ),
    );
  }
}
