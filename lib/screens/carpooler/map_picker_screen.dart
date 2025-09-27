import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final String title;
  const MapPickerScreen({super.key, required this.title});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  MapboxMap? _map;
  PointAnnotationManager? _pointMgr;
  LatLng? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(73.0551, 33.6844)), // Islamabad default
              zoom: 11,
            ),
            onMapCreated: (map) async {
              _map = map;
              _pointMgr = await _map!.annotations.createPointAnnotationManager();
            },
            // 🔹 Handle user taps
            onTapListener: (tapPos) async {
              final pos = tapPos.point.coordinates;
              final lat = pos.lat.toDouble();
              final lng = pos.lng.toDouble();

              setState(() {
                _selected = LatLng(lat, lng);
              });

              // clear previous marker
              await _pointMgr?.deleteAll();

              // add marker at tapped position (requires valid asset in pubspec.yaml)
              final marker = PointAnnotationOptions(
                geometry: Point(coordinates: Position(lng, lat)),
                iconImage: "assets/marker.png", // <-- must exist in assets
                iconSize: 1.2,
              );
              await _pointMgr?.create(marker);
            },
          ),

          // 🔹 Confirm Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _selected == null
    ? null
    : () {
        if (mounted) {
          Navigator.of(context).pop({
            "lat": _selected!.lat,
            "lng": _selected!.lng,
            "name": "Picked Location"
          });
        }
      },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF255A45),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selected == null
                    ? "Tap on the map to select a location"
                    : "Confirm Location",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple LatLng wrapper
class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}
