// lib/screens/rider/ride_details_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

import '../../services/ride_request_service.dart'; // repo layer
import '../../core/theme/app_theme.dart';          // ✅ added missing semicolon
import '../../core/constants.dart';               // where kMapboxToken lives

// DTO summary passed from Rides list → details
class RideSummary {
  final int rideId;
  final String driverName;
  final String driverPhotoUrl;
  final double driverRating;
  final String carModel;
  final String carPlate;
  final int seatsLeft;       // rides.passenger_count
  final DateTime dateTime;
  final double originLat, originLng, destLat, destLng;
  final double price;        // total ride price
  final String carpoolerId;  // driver id

  const RideSummary({
    required this.rideId,
    required this.driverName,
    required this.driverPhotoUrl,
    required this.driverRating,
    required this.carModel,
    required this.carPlate,
    required this.seatsLeft,
    required this.dateTime,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.price,
    required this.carpoolerId,
  });
}

class RideDetailsScreen extends StatefulWidget {
  final RideSummary ride;
  final String myUserId;
  const RideDetailsScreen({
    super.key,
    required this.ride,
    required this.myUserId,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  MapboxMapController? _mapController;
  Line? _routeLine;
  bool _sending = false;
  String? _requestId; // bigint id from ride_requests
  String _status = 'idle'; // idle | pending | accepted | rejected | cancelled | error
  late final RideRequestService _svc;

  @override
  void initState() {
    super.initState();
    _svc = RideRequestService();
  }

  @override
  void dispose() {
    _svc.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMapController c) async {
    _mapController = c;
    await _drawRoute();
  }

  Future<void> _drawRoute() async {
  final o = LatLng(widget.ride.originLat, widget.ride.originLng);
  final d = LatLng(widget.ride.destLat, widget.ride.destLng);

  final url = Uri.parse(
    'https://router.project-osrm.org/route/v1/driving/${o.longitude},${o.latitude};${d.longitude},${d.latitude}?overview=full&geometries=geojson',
  );
  final res = await http.get(url);
  if (res.statusCode != 200) return;
  final data = jsonDecode(res.body);
  final coords = (data['routes'][0]['geometry']['coordinates'] as List)
      .map<LatLng>((c) =>
          LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
      .toList();

  final lineOptions = LineOptions(
    geometry: coords,
    lineWidth: 5.0,
    lineColor: "#255A45",
  );

  // store the Line reference
  _routeLine = await _mapController?.addLine(lineOptions);

  // Fit camera to route
  final bounds = _boundsFromLatLngList(coords);
  await _mapController?.animateCamera(
    CameraUpdate.newLatLngBounds(
      bounds,
      left: 32,
      right: 32,
      top: 32,
      bottom: 220,
    ),
  );
}


  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    for (final p in list) {
      minLat = (minLat == null || p.latitude < minLat) ? p.latitude : minLat;
      maxLat = (maxLat == null || p.latitude > maxLat) ? p.latitude : maxLat;
      minLng = (minLng == null || p.longitude < minLng) ? p.longitude : minLng;
      maxLng = (maxLng == null || p.longitude > maxLng) ? p.longitude : maxLng;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  Future<void> _requestSeat() async {
    if (widget.ride.seatsLeft <= 0) {
      _snack("Ride is full", isErr: true);
      return;
    }

    setState(() => _sending = true);
    final res = await _svc.sendRequest(
      rideId: widget.ride.rideId,
      riderId: widget.myUserId,
    );
    res.when(
      ok: (id) async {
        _requestId = id;
        _status = 'pending';
        _snack("Request sent");
        _svc.listenForStatus(
          requestId: id,
          onChange: (s) {
            if (!mounted) return;
            setState(() => _status = s);
            if (s == 'accepted') {
              _snack("Accepted! Booking created");
              Get.offNamed('/active-ride', arguments: {
                'rideId': widget.ride.rideId,
                'requestId': _requestId,
              });
            } else if (s == 'rejected') {
              _dialog("Request Rejected", "The driver rejected your request.",
                  retry: true);
            } else if (s == 'cancelled') {
              _dialog("Request Cancelled", "This request was cancelled.",
                  retry: true);
            }
          },
        );
      },
      err: (e) => _snack(e.message, isErr: true),
    );
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _cancelRequest() async {
    if (_requestId == null) return;
    final res = await _svc.cancelRequest(requestId: _requestId!);
    res.when(
      ok: (_) {
        setState(() => _status = 'cancelled');
        _snack("Request cancelled");
      },
      err: (e) => _snack(e.message, isErr: true),
    );
  }

  void _snack(String msg, {bool isErr = false}) {
    Get.snackbar(
      isErr ? 'Error' : 'Success',
      msg,
      backgroundColor:
          isErr ? Colors.red.shade600 : const Color(0xFF255A45),
      colorText: Colors.white,
    );
  }

  Future<void> _dialog(String title, String msg, {bool retry = false}) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          if (retry)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _requestSeat();
              },
              child: const Text("Retry"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final splitPrice =
        (widget.ride.price / 2).toStringAsFixed(0); // 50/50 split

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Ride Details"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Driver card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2EF),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(widget.ride.driverPhotoUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.ride.driverName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(widget.ride.driverRating.toStringAsFixed(1)),
                          const SizedBox(width: 12),
                          Text("${widget.ride.seatsLeft} seats left",
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("${widget.ride.carModel} • ${widget.ride.carPlate}",
                          style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Map
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MapboxMap(
                accessToken: kMapboxToken,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(widget.ride.originLat, widget.ride.originLng),
                  zoom: 12.5,
                ),
                myLocationEnabled: false,
                compassEnabled: false,
                styleString: MapboxStyles.MAPBOX_STREETS,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cost & CTA
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6F2EF)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Estimated Cost (your split)",
                          style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text("Rs $splitPrice",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18)),
                    ],
                  ),
                ),
                if (_status == 'pending')
                  OutlinedButton(
                    onPressed: _cancelRequest,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF255A45)),
                      foregroundColor: const Color(0xFF255A45),
                    ),
                    child: const Text("Cancel"),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _sending ? null : _requestSeat,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _status == 'idle'
                          ? "Request Seat"
                          : _status == 'accepted'
                              ? "Accepted"
                              : _status == 'rejected'
                                  ? "Rejected"
                                  : _status == 'cancelled'
                                      ? "Cancelled"
                                      : "Pending",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF255A45),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(160, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
