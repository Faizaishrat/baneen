import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';

class BaneenMapWidget extends StatefulWidget {
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? driverLat;
  final double? driverLng;
  final bool showMyLocation;
  final bool showRoute;
  final double height;
  final Function(LatLng)? onMapTap;

  const BaneenMapWidget({
    super.key,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.driverLat,
    this.driverLng,
    this.showMyLocation = true,
    this.showRoute = false,
    this.height = 300,
    this.onMapTap,
  });

  @override
  State<BaneenMapWidget> createState() => _BaneenMapWidgetState();
}

class _BaneenMapWidgetState extends State<BaneenMapWidget> {
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    if (widget.showMyLocation) {
      _getMyLocation();
    } else {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _getMyLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _myLocation = LatLng(pos.latitude, pos.longitude);
          _loadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  LatLng get _centerPoint {
    if (widget.pickupLat != null && widget.pickupLng != null) {
      return LatLng(widget.pickupLat!, widget.pickupLng!);
    }
    if (_myLocation != null) return _myLocation!;
    return const LatLng(33.6844, 73.0479); // Default: Islamabad
  }

  double get _zoomLevel {
    if (widget.pickupLat != null && widget.dropoffLat != null) return 11.0;
    return 14.0;
  }

  List<Marker> get _markers {
    final markers = <Marker>[];

    // My location (blue dot)
    if (_myLocation != null) {
      markers.add(Marker(
        point: _myLocation!,
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
          ),
        ),
      ));
    }

    // Pickup marker (green)
    if (widget.pickupLat != null && widget.pickupLng != null) {
      markers.add(Marker(
        point: LatLng(widget.pickupLat!, widget.pickupLng!),
        width: 40,
        height: 50,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.my_location, color: Colors.white, size: 16),
            ),
            Container(width: 2, height: 8, color: AppTheme.successColor),
          ],
        ),
      ));
    }

    // Dropoff marker (red)
    if (widget.dropoffLat != null && widget.dropoffLng != null) {
      markers.add(Marker(
        point: LatLng(widget.dropoffLat!, widget.dropoffLng!),
        width: 40,
        height: 50,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 16),
            ),
            Container(width: 2, height: 8, color: AppTheme.primaryColor),
          ],
        ),
      ));
    }

    // Driver marker (car icon)
    if (widget.driverLat != null && widget.driverLng != null) {
      markers.add(Marker(
        point: LatLng(widget.driverLat!, widget.driverLng!),
        width: 44,
        height: 44,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Icon(Icons.directions_car, color: AppTheme.primaryColor, size: 22),
        ),
      ));
    }

    return markers;
  }

  List<Polyline> get _polylines {
    if (!widget.showRoute ||
        widget.pickupLat == null ||
        widget.dropoffLat == null) return [];

    return [
      Polyline(
        points: [
          LatLng(widget.pickupLat!, widget.pickupLng!),
          LatLng(widget.dropoffLat!, widget.dropoffLng!),
        ],
        strokeWidth: 4,
        color: AppTheme.primaryColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Getting your location...'),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centerPoint,
            initialZoom: _zoomLevel,
            onTap: widget.onMapTap != null
                ? (tapPosition, latLng) => widget.onMapTap!(latLng)
                : null,
          ),
          children: [
            // OpenStreetMap tiles — FREE, no API key needed!
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.baneen',
              maxZoom: 19,
            ),
            // Route line
            if (_polylines.isNotEmpty)
              PolylineLayer(polylines: _polylines),
            // Markers
            MarkerLayer(markers: _markers),
            // Attribution (required by OSM)
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}