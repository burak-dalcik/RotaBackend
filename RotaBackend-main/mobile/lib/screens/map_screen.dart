import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/stop_summary.dart';
import '../theme/app_theme.dart';
import 'smart_stop_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key, required this.stopsFuture});

  final Future<List<StopSummary>> stopsFuture;

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _userPosition;
  bool _locationLoading = false;
  String? _locationError;
  List<StopSummary>? _stops;
  StopSummary? _nearestStop;

  // Istanbul default center
  static const _istanbulCenter = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    widget.stopsFuture.then((stops) {
      if (mounted) setState(() => _stops = stops);
    });
  }

  Future<void> _goToMyLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'location_service_disabled';
          _locationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'location_permission_denied';
            _locationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'location_permission_forever';
          _locationLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _userPosition = position;
        _locationLoading = false;
      });

      _findNearestStop();

      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _locationLoading = false;
      });
    }
  }

  void _findNearestStop() {
    if (_userPosition == null || _stops == null) return;

    final stopsWithLocation = _stops!.where((s) => s.hasLocation).toList();
    if (stopsWithLocation.isEmpty) return;

    StopSummary? nearest;
    double minDist = double.infinity;

    for (final stop in stopsWithLocation) {
      final dist = _haversineDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        stop.enlem!,
        stop.boylam!,
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = stop;
      }
    }

    setState(() => _nearestStop = nearest);
  }

  /// Haversine distance in meters
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // Earth radius in meters
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Set<Marker> _buildMarkers(AppLocalizations l10n) {
    final markers = <Marker>{};

    if (_stops != null) {
      for (final stop in _stops!) {
        if (!stop.hasLocation) continue;
        final isNearest = _nearestStop?.durakKodu == stop.durakKodu;
        markers.add(
          Marker(
            markerId: MarkerId(stop.durakKodu),
            position: LatLng(stop.enlem!, stop.boylam!),
            icon: isNearest
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure),
            onTap: () => _openStop(stop),
            infoWindow: InfoWindow(
              title: stop.durakAdi,
              snippet: stop.enYakinSeferDk != null
                  ? '${stop.enYakinSeferDk} ${l10n.minutesShort}'
                  : stop.durakKodu,
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _openStop(StopSummary stop) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SmartStopScreen(durakKodu: stop.durakKodu),
      ),
    );
  }

  LatLng _initialCenter() {
    if (_stops != null && _stops!.any((s) => s.hasLocation)) {
      final withLoc = _stops!.where((s) => s.hasLocation).toList();
      final avgLat =
          withLoc.map((s) => s.enlem!).reduce((a, b) => a + b) / withLoc.length;
      final avgLng =
          withLoc.map((s) => s.boylam!).reduce((a, b) => a + b) /
              withLoc.length;
      return LatLng(avgLat, avgLng);
    }
    return _istanbulCenter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialCenter(),
            zoom: 13,
          ),
          markers: _buildMarkers(l10n),
          myLocationEnabled: _userPosition != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
        ),

        // My Location FAB
        Positioned(
          right: 16,
          bottom: _nearestStop != null ? 130 : 24,
          child: FloatingActionButton(
            heroTag: 'myLocation',
            onPressed: _locationLoading ? null : _goToMyLocation,
            backgroundColor: Colors.white,
            elevation: 4,
            child: _locationLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.my_location,
                    color: AppTheme.deepTransitBlue,
                  ),
          ),
        ),

        // Error banner
        if (_locationError != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFFF3E0),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Color(0xFFE65100)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _localizedError(l10n, _locationError!),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () =>
                          setState(() => _locationError = null),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Nearest stop card
        if (_nearestStop != null && _userPosition != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 80,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openStop(_nearestStop!),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.near_me,
                          color: Color(0xFF2E7D32),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.mapNearestStop,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _nearestStop!.durakAdi,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepTransitBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDistance(_haversineDistance(
                                _userPosition!.latitude,
                                _userPosition!.longitude,
                                _nearestStop!.enlem!,
                                _nearestStop!.boylam!,
                              )),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _localizedError(AppLocalizations l10n, String error) {
    switch (error) {
      case 'location_service_disabled':
        return l10n.mapLocationServiceOff;
      case 'location_permission_denied':
        return l10n.mapLocationDenied;
      case 'location_permission_forever':
        return l10n.mapLocationDeniedForever;
      default:
        return error;
    }
  }
}
