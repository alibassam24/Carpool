import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/ride_map.dart';
import '../../services/ride_action_service.dart';

class ActiveRideScreen extends StatefulWidget {
  final int rideId;       // rides.id
  final String driverId;  // users.id (uuid)

  const ActiveRideScreen({
    super.key,
    required this.rideId,
    required this.driverId,
  });

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  final _sb = Supabase.instance.client;
  final _rideService = RideActionsService();

  StreamSubscription<List<Map<String, dynamic>>>? _rideSub;
  String _status = "active"; // active | started | cancelled | completed
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _subscribeRide();
  }

  @override
  void dispose() {
    _rideSub?.cancel();
    super.dispose();
  }

  void _subscribeRide() {
    _rideSub = _sb
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', widget.rideId)
        .listen((rows) {
      if (rows.isEmpty) return;
      final row = rows.first;
      final newStatus = row['status']?.toString() ?? 'active';

      if (!mounted) return;
      if (newStatus != _status) {
        setState(() => _status = newStatus);

        if (newStatus == 'cancelled') {
          _snack("❌ Ride was cancelled", err: true);
          Navigator.of(context).maybePop();
        } else if (newStatus == 'completed') {
          _snack("✅ Ride completed");
          Navigator.of(context).maybePop();
        }
      }
    });
  }

  Future<void> _cancelRide() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await _rideService.cancelRide(rideId : widget.rideId);
      _snack("✅ Ride cancelled");
      Navigator.of(context).maybePop();
    } catch (e) {
      _snack("❌ Cancel failed: $e", err: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendSOS() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await _rideService.sendSOS(rideId: widget.rideId);
      _snack("🚨 SOS alert sent");
    } catch (e) {
      _snack("❌ SOS failed: $e", err: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: err ? Colors.red.shade600 : const Color(0xFF255A45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandPrimary = Color(0xFF255A45);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Active Ride"),
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Live map tracking
          Positioned.fill(
            child: RideMapLive(
              rideId: widget.rideId,
              driverId: widget.driverId,
            ),
          ),

          // Status card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status == 'started'
                        ? "Ride in progress 🚖"
                        : "Driver is on the way 🚗",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _status == 'started'
                        ? "Enjoy your ride."
                        : "We’ll notify you on arrival.",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // Driver info + action buttons
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.20,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
                ),
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ali Khan",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Honda Civic • ABC-123",
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const Text("4.9", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_status == 'started' || _status == 'completed' || _busy)
                                ? null
                                : _cancelRide,
                            icon: const Icon(Icons.close),
                            label: const Text("Cancel Ride"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _sendSOS,
                            icon: const Icon(Icons.sos, color: Colors.white),
                            label: const Text("SOS"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
