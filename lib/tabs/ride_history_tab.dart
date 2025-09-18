import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rides = [
      {
        "from": "DHA Phase 5",
        "to": "Gulberg",
        "date": "12 Sep 2025",
        "passengers": 3,
        "status": "Completed",
      },
      {
        "from": "Model Town",
        "to": "Johar Town",
        "date": "10 Sep 2025",
        "passengers": 2,
        "status": "Completed",
      },
      {
        "from": "Bahria Town",
        "to": "Mall Road",
        "date": "8 Sep 2025",
        "passengers": 4,
        "status": "Cancelled",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Ride History"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFFE6F2EF),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF255A45),
                child: const Icon(Icons.directions_car, color: Colors.white),
              ),
              title: Text(
                "${ride['from']} → ${ride['to']}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF255A45)),
              ),
              subtitle: Text(
                "${ride['date']} • ${ride['passengers']} passengers",
                style: const TextStyle(color: Colors.black87),
              ),
              trailing: Text(
                ride['status'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ride['status'] == "Completed"
                      ? Colors.green
                      : ride['status'] == "Cancelled"
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
