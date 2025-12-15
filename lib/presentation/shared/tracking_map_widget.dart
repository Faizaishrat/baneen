import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';

class TrackingMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final bool showRoute;
  final Function(LatLng)? onMapTap;

  const TrackingMapWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.showRoute = false,
    this.onMapTap,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    if (widget.showRoute) {
      _updateRoute();
    }
  }

  @override
  void didUpdateWidget(TrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _updateMarkers();
      if (widget.showRoute) {
        _updateRoute();
      }
      _moveCamera();
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (widget.latitude != null && widget.longitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(widget.latitude!, widget.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }

    if (widget.destinationLatitude != null &&
        widget.destinationLongitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            widget.destinationLatitude!,
            widget.destinationLongitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );
    }
  }

  void _updateRoute() {
    if (widget.latitude != null &&
        widget.longitude != null &&
        widget.destinationLatitude != null &&
        widget.destinationLongitude != null) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(widget.latitude!, widget.longitude!),
            LatLng(
              widget.destinationLatitude!,
              widget.destinationLongitude!,
            ),
          ],
          color: AppTheme.primaryColor,
          width: 4,
        ),
      );
    }
  }

  void _moveCamera() {
    if (_mapController != null &&
        widget.latitude != null &&
        widget.longitude != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.latitude!, widget.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.latitude == null || widget.longitude == null) {
      return Container(
        color: AppTheme.backgroundColor,
        child: const Center(
          child: Icon(
            Icons.map,
            size: 80,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.latitude!, widget.longitude!),
        zoom: 14.0,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      onTap: (LatLng position) {
        widget.onMapTap?.call(position);
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

