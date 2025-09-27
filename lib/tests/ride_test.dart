// lib/test_active.dart
import 'package:flutter/material.dart';
import '../screens/rider/active_ride_screen.dart';

class TestActiveApp extends StatelessWidget {
  const TestActiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ActiveRideScreen(
        rideId: 123, // dummy rideId (int)
        driverId: "11111111-1111-1111-1111-111111111111", // dummy Supabase user uuid
      ),
    );
  }
}
