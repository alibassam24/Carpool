// lib/widgets/ride_map_live.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideMapLive extends StatefulWidget {
  final int rideId;       // rides.id (bigint)
  final String driverId;  // users.id (uuid)
  final String styleUri;  // allow styling from outside if you like

  const RideMapLive({
    super.key,
    required this.rideId,
    required this.driverId,
    this.styleUri = MapboxStyles.MAPBOX_STREETS,
  });

  @override
  State<RideMapLive> createState() => _RideMapLiveState();
}

class _RideMapLiveState extends State<RideMapLive> {
  final SupabaseClient _sb = Supabase.instance.client;

  MapboxMap? _map;
  CircleAnnotationManager? _circleMgr;
  CircleAnnotation? _driverCircle;

  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  bool _mapReady = false;
  bool _hasFirstFix = false;

  // Karachi as a neutral default center
  static final _defaultCenter = Point(coordinates: Position(67.0011, 24.8607));

  @override
  void initState() {
    super.initState();
    _subscribeToDriver();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _subscribeToDriver() {
    _sub = _sb
        .from('live_locations')
        .stream(primaryKey: ['user_id'])
        .eq('ride_id', widget.rideId)
        .listen((rows) async {
      if (!_mapReady || rows.isEmpty) return;

      final driverRow = rows.firstWhere(
        (r) => r['user_id']?.toString() == widget.driverId,
        orElse: () => <String, dynamic>{},
      );
      if (driverRow.isEmpty) return;

      final lat = (driverRow['latitude'] as num?)?.toDouble();
      final lng = (driverRow['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      await _updateDriverCircle(lat, lng);
    });
  }

  Future<void> _ensureCircleManager() async {
    if (_map != null && _circleMgr == null) {
      _circleMgr = await _map!.annotations.createCircleAnnotationManager();
    }
  }

  Future<void> _updateDriverCircle(double lat, double lng) async {
    if (_map == null) return;
    await _ensureCircleManager();
    if (_circleMgr == null) return;

    final geom = Point(coordinates: Position(lng, lat)); // NOTE: Position(lng, lat)

    if (_driverCircle == null) {
      // Create the driver dot once
      final created = await _circleMgr!.create(
        CircleAnnotationOptions(
          geometry: geom,
          circleRadius: 8.0,
          circleColor: const Color(0xFF255A45).value, // brand
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2.0,
        ),
      );
      _driverCircle = created;
    } else {
      // Mutate then update (v2 API)
      _driverCircle!.geometry = geom;
      await _circleMgr!.update(_driverCircle!);
    }

    // Center the camera once at the first fix
    if (!_hasFirstFix) {
      _hasFirstFix = true;
      await _map!.flyTo(
        CameraOptions(center: geom, zoom: 14.0),
        MapAnimationOptions(duration: 1500, startDelay: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapWidget(
          styleUri: widget.styleUri,
          cameraOptions: CameraOptions(center: Point(coordinates: Position(73.0551, 33.6844)), // 📍 Islamabad default
          zoom: 12.0,
          ),
          onMapCreated: (map) async {
            _map = map;
            _mapReady = true;
            // Prepare manager up-front so the first live ping can render immediately
            _circleMgr = await _map!.annotations.createCircleAnnotationManager();
          },
        ),

        if (!_hasFirstFix)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text("Waiting for driver’s location…")),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
