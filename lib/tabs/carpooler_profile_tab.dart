import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final box = GetStorage();

class CarpoolerProfileTab extends StatefulWidget {
  const CarpoolerProfileTab({super.key});

  @override
  State<CarpoolerProfileTab> createState() => _CarpoolerProfileTabState();
}

class _CarpoolerProfileTabState extends State<CarpoolerProfileTab> {
  final supabase = Supabase.instance.client;

  String? userName;
  int loyaltyPoints = 0;
  int totalRides = 0;
  int passengers = 0;
  double earnings = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileAndStats();
  }

  Future<void> _loadProfileAndStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        setState(() {
          errorMessage = "Not logged in";
          isLoading = false;
        });
        return;
      }

      final uid = authUser.id;

      // ---- Get user row (loyalty points)
      final userRes = await supabase
          .from('users')
          .select('email, loyalty_points')
          .eq('id', uid)
          .maybeSingle();

      // ---- Get profile row (optional extras)
      final profileRes = await supabase
          .from('profiles')
          .select('phone, gender')
          .eq('id', uid)
          .maybeSingle();

      // ---- Total rides posted
      final ridesRes = await supabase
          .from('rides')
          .select('id')
          .eq('carpooler_id', uid);

      final rideIds = (ridesRes as List)
          .map<int>((r) => int.tryParse("${r['id']}") ?? 0)
          .where((id) => id > 0)
          .toList();

      // ---- Passengers = accepted ride_requests on these rides
      int pax = 0;
      if (rideIds.isNotEmpty) {
        final rr = await supabase
            .from('ride_requests')
            .select('status')
            .inFilter('ride_id', rideIds);

        pax = (rr as List)
            .where((r) => r['status'] == 'accepted')
            .length;
      }

      // ---- Earnings = sum of payments on these rides
      double sumEarnings = 0;
      if (rideIds.isNotEmpty) {
        final payRes = await supabase
            .from('payments')
            .select('amount, ride_id')
            .inFilter('ride_id', rideIds);

        for (final p in payRes as List) {
          if (p['amount'] != null) {
            sumEarnings += (p['amount'] as num).toDouble();
          }
        }
      }

      setState(() {
        userName = userRes?['email'] ?? authUser.email ?? 'User';
        loyaltyPoints = userRes?['loyalty_points'] ?? 0;
        totalRides = rideIds.length;
        passengers = pax;
        earnings = sumEarnings;
        isLoading = false;
      });

      // cache for offline fallback
      box.write('userName', userName);
      box.write('loyaltyPoints', loyaltyPoints);
      box.write('totalRides', totalRides);
      box.write('earnings', earnings);
    } on PostgrestException catch (e) {
      _useLocalFallback('Postgres error: ${e.message}');
    } catch (e) {
      _useLocalFallback('Error: $e');
    }
  }

  void _useLocalFallback(String msg) {
    setState(() {
      userName = box.read('userName') ?? 'User';
      loyaltyPoints = box.read('loyaltyPoints') ?? 0;
      totalRides = box.read('totalRides') ?? 0;
      earnings = (box.read('earnings') as num?)?.toDouble() ?? 0.0;
      passengers = 0;
      errorMessage = msg;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: RefreshIndicator(
        onRefresh: _loadProfileAndStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFFE6F2EF),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF255A45),
                        child: const Icon(Icons.person,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF255A45),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Loyalty Points: $loyaltyPoints"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard("Total Rides", "$totalRides"),
                  _statCard("Passengers", "$passengers"),
                  _statCard("Earnings", "PKR ${earnings.toStringAsFixed(0)}"),
                ],
              ),
              const SizedBox(height: 20),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFE6F2EF),
                leading: const Icon(Icons.history, color: Color(0xFF255A45)),
                title: const Text("Ride History"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/ride_history'),
              ),
              const SizedBox(height: 12),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFE6F2EF),
                leading: const Icon(Icons.swap_horiz, color: Color(0xFF255A45)),
                title: const Text("Switch to Rider"),
                onTap: () => Get.offAllNamed('/rider_home'),
              ),
              const SizedBox(height: 12),

              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.red.shade50,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: () async {
                  await supabase.auth.signOut();
                  box.erase();
                  Get.offAllNamed('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFE6F2EF),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF255A45),
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
