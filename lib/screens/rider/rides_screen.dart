import 'package:flutter/material.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Brand background
      appBar: AppBar(
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        title: const Text("Available Rides"),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // mock 3 rides
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.directions_car, color: Color(0xFF255A45)),
              title: const Text("Islamabad → Rawalpindi"),
              subtitle: Text("10:30 AM • Rs 300"),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                ),
                child: const Text("Book", style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        onPressed: () => _showSearchBottomSheet(context),
        backgroundColor: const Color(0xFF255A45),
        icon: const Icon(Icons.search),
        label: const Text("Search"),
      ),
    );
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
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Search Rides",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // From
              TextField(
                decoration: InputDecoration(
                  labelText: "From",
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // To
              TextField(
                decoration: InputDecoration(
                  labelText: "To",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // Date & Time
              TextField(
                decoration: InputDecoration(
                  labelText: "Time (optional)",
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // Price filter (optional)
              TextField(
                decoration: InputDecoration(
                  labelText: "Max Price (optional)",
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Apply filter logic
                },
                icon: const Icon(Icons.search),
                label: const Text("Find Rides"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
