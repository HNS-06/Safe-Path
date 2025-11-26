import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safepath/widgets/safety_marker.dart';
import 'package:safepath/widgets/pulse_animation.dart';
import 'package:safepath/models/safety_report.dart';
import 'package:safepath/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safepath/theme/colors.dart';
import 'package:safepath/services/routing_service.dart';
import 'package:safepath/services/places_service.dart';
import 'package:safepath/services/weather_service.dart';
import 'package:safepath/services/voice_service.dart';
import 'package:safepath/models/location_model.dart' as LM;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  late AnimationController _pulseController;
  StreamSubscription<Position>? _locationSub;
  final Set<Polyline> _polylines = {};
  final Set<Circle> _heatmapCircles = {};
  LatLng? _destination;
  bool _offlineMode = false;
  WeatherData? _currentWeather;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _getCurrentLocation();
    // subscribe to live location updates so the map follows the user in real-time
    try {
      _locationSub = LocationService.getLocationStream().listen((pos) {
        if (!mounted) return;
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });
      });
    } catch (_) {}
    _loadSafetyMarkers();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationSub?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation(timeout: const Duration(seconds: 15));
      setState(() {
        _currentLocation = LatLng(location.latitude, location.longitude);
      });

      // center map to current location when available
      try {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      } catch (_) {}

      // convert Position to LocationModel for services
      final locModel = LM.LocationModel(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
      );

      // fetch weather and heatmap for the current location
      _fetchWeatherAndHeatmap(locModel);
      return;
    } catch (e) {
      // Handle location errors gracefully: prompt user to enable location
      if (!mounted) return;
      final message = e.toString();
      // Theme-aware dialog with Retry / Open Settings / Use last-known
      showDialog(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            title: Text('Location Unavailable', style: theme.textTheme.titleLarge),
            content: Text('Could not get your location: $message', style: theme.textTheme.bodyMedium),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // Retry getting a current location with a longer timeout
                  try {
                    final loc = await LocationService.getCurrentLocation(timeout: const Duration(seconds: 20));
                    if (!mounted) return;
                    setState(() {
                      _currentLocation = LatLng(loc.latitude, loc.longitude);
                    });
                    // center map
                    try {
                      _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
                    } catch (_) {}
                    // fetch weather / heatmap
                    _fetchWeatherAndHeatmap(LM.LocationModel(latitude: loc.latitude, longitude: loc.longitude, timestamp: DateTime.now()));
                  } catch (err) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Retry failed: ${err.toString()}')));
                  }
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // Open system location settings
                  try {
                    await Geolocator.openLocationSettings();
                  } catch (_) {}
                },
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // Try to use last known position if available
                  try {
                    final last = await LocationService.getLastKnownPosition();
                    if (last != null) {
                      if (!mounted) return;
                      setState(() {
                        _currentLocation = LatLng(last.latitude, last.longitude);
                      });
                      try {
                        _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
                      } catch (_) {}
                      _fetchWeatherAndHeatmap(LM.LocationModel(latitude: last.latitude, longitude: last.longitude, timestamp: DateTime.now()));
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No last known location available.')));
                    }
                  } catch (err) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not use last-known location: ${err.toString()}')));
                  }
                },
                child: const Text('Use last-known'),
              ),
            ],
          );
        },
      );
      return;
    }
    
  }

  Future<void> _fetchWeatherAndHeatmap(LM.LocationModel loc) async {
    try {
      final weather = await WeatherService().getWeather(loc);
      final heat = await WeatherService().getSafetyHeatMap(loc, 2.0);

      setState(() {
        _currentWeather = weather;
        _heatmapCircles.clear();
        final zones = (heat['zones'] as List<dynamic>? ) ?? [];
        for (var i = 0; i < zones.length; i++) {
          final z = zones[i] as Map<String, dynamic>;
          final intensity = (z['intensity'] as num?)?.toDouble() ?? 1.0;
          final lat = (z['lat'] as num).toDouble();
          final lng = (z['lng'] as num).toDouble();

          _heatmapCircles.add(Circle(
            circleId: CircleId('heat_$i'),
            center: LatLng(lat, lng),
            radius: 100 * intensity,
            fillColor: Colors.red.withOpacity((intensity / 10).clamp(0.05, 0.4)),
            strokeColor: Colors.transparent,
          ));
        }
      });
    } catch (e) {
      // ignore weather errors - non-critical
    }
  }

  Future<void> _startNavigation() async {
    if (_currentLocation == null || _destination == null) return;

    setState(() {
      _isNavigating = true;
      _polylines.clear();
    });

    final start = LM.LocationModel(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      timestamp: DateTime.now(),
    );
    final end = LM.LocationModel(
      latitude: _destination!.latitude,
      longitude: _destination!.longitude,
      timestamp: DateTime.now(),
    );

    final route = await RoutingService().calculateRoute(start, end);

    final points = route
        .map((r) => LatLng(r.latitude, r.longitude))
        .toList();

    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route_main'),
        color: AppColors.primary,
        width: 5,
        points: points,
      ));
    });

    // compute route summary (distance and traffic)
    try {
      final startLm = start;
      final endLm = end;
      final km = RoutingService().distanceKm(startLm, endLm);
      final trafficFactor = RoutingService().estimateTrafficFactor(startLm, endLm);
      // assume average speed 40 km/h, adjust for traffic
      final avgSpeed = 40.0 / trafficFactor; // km/h
      final hours = km / avgSpeed;
      final minutes = (hours * 60).round();

      final summary = '${km.toStringAsFixed(1)} km • $minutes min • Traffic x${trafficFactor.toStringAsFixed(1)}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Route: $summary')));
      }
      try {
        await VoiceService().speak('Navigation started. $km kilometers to destination. Estimated $minutes minutes.');
      } catch (_) {}
    } catch (_) {}
    // give a short spoken summary if available
    try {
      await VoiceService().speak('Navigation started. Following the safest route.');
    } catch (_) {}
  }

  Future<void> _toggleOfflineCache() async {
    setState(() {
      _offlineMode = !_offlineMode;
    });

    if (_offlineMode && _currentLocation != null) {
      final center = LM.LocationModel(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        timestamp: DateTime.now(),
      );
      await RoutingService().cacheMapTiles(center, 3.0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cached area for offline use')),
        );
      }
    }
  }

  void _loadSafetyMarkers() {
    // Mock data - in real app, this would come from backend
    final mockReports = [
      SafetyReport(
        id: '1',
        location: const LatLng(28.6139, 77.2090), // Delhi
        type: SafetyType.safe,
        description: 'Well-lit pathway with good visibility',
        rating: 4.8,
        timestamp: DateTime.now(),
      ),
      SafetyReport(
        id: '2',
        location: const LatLng(28.6129, 77.2295),
        type: SafetyType.unsafe,
        description: 'Poor lighting, avoid at night',
        rating: 2.1,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SafetyReport(
        id: '3',
        location: const LatLng(28.6149, 77.2190),
        type: SafetyType.moderate,
        description: 'Moderate crowd during evenings',
        rating: 3.5,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    setState(() {
      _markers.clear();
      for (final report in mockReports) {
        _markers.add(
          Marker(
            markerId: MarkerId(report.id),
            position: report.location,
            icon: SafetyMarker.getIcon(report.type),
            infoWindow: InfoWindow(
              title: SafetyMarker.getTitle(report.type),
              snippet: report.description,
            ),
          ),
        );
      }
    });
  }

  Future<void> _openDestinationPicker() async {
    // If we don't have the user's current position, attempt to get it
    Position? pos;
    try {
      final p = await LocationService.getLastKnownPosition();
      pos = p;
      if (pos == null) {
        final fresh = await LocationService.getCurrentLocation(timeout: const Duration(seconds: 10));
        pos = fresh;
      }
    } catch (_) {}

    final places = <PlaceItem>[];
    if (pos != null) {
      try {
        final list = await PlacesService().getNearbyPlaces(pos);
        places.addAll(list);
      } catch (_) {}
    }

    // Show modal sheet with options
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Pick a nearby place'),
                  subtitle: const Text('Or enter lat,lng manually'),
                ),
                Expanded(
                  child: places.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final p = places[index];
                            return ListTile(
                              leading: const Icon(Icons.place),
                              title: Text(p.name),
                              subtitle: Text('${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}'),
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _destination = LatLng(p.latitude, p.longitude);
                                  _markers.removeWhere((m) => m.markerId.value == 'destination');
                                  _markers.add(Marker(markerId: const MarkerId('destination'), position: _destination!, infoWindow: InfoWindow(title: p.name)));
                                });
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('No nearby places available.'),
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    top: 12.0,
                    bottom: 12.0 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'Enter destination lat,lng'),
                          keyboardType: TextInputType.text,
                          onSubmitted: (val) {
                            try {
                              final parts = val.split(',');
                              final lat = double.parse(parts[0].trim());
                              final lng = double.parse(parts[1].trim());
                              Navigator.pop(ctx);
                              setState(() {
                                _destination = LatLng(lat, lng);
                                _markers.removeWhere((m) => m.markerId.value == 'destination');
                                _markers.add(Marker(markerId: const MarkerId('destination'), position: _destination!, infoWindow: const InfoWindow(title: 'Destination')));
                              });
                            } catch (_) {
                              // ignore parse errors
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: const CameraPosition(
            target: LatLng(28.6139, 77.2090),
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          circles: _heatmapCircles,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          onLongPress: (pos) {
            // set navigation destination on long press
            setState(() {
              _destination = pos;
              _markers.removeWhere((m) => m.markerId.value == 'destination');
              _markers.add(Marker(
                markerId: const MarkerId('destination'),
                position: pos,
                infoWindow: const InfoWindow(title: 'Destination'),
              ));
            });
          },
        ),
        
        // Current Location Pulse
        if (_currentLocation != null)
          Positioned(
            right: 20,
            bottom: 180,
            child: PulseAnimation(
              controller: _pulseController,
              child: FloatingActionButton(
                onPressed: () {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(_currentLocation!),
                  );
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ),

        // Navigation & Controls
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'nav',
                onPressed: _destination == null
                    ? () => _openDestinationPicker()
                    : () => _startNavigation(),
                backgroundColor: _destination == null ? Colors.blueGrey : AppColors.primary,
                child: Icon(_destination == null ? Icons.search : Icons.navigation, color: Colors.white),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'offline',
                onPressed: () => _toggleOfflineCache(),
                backgroundColor: _offlineMode ? Colors.green : Colors.orange,
                child: Icon(_offlineMode ? Icons.cloud_done : Icons.cloud_download, color: Colors.white),
              ),
            ],
          ),
        ),

        // Safety Legend (theme-aware for dark mode)
        Positioned(
          top: 80,
          left: 20,
          child: Builder(builder: (ctx) {
            final theme = Theme.of(ctx);
            final cardColor = theme.cardColor;
            final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('Safe', AppColors.safe, textColor),
                  _buildLegendItem('Moderate', AppColors.moderate, textColor),
                  _buildLegendItem('Unsafe', AppColors.unsafe, textColor),
                ],
              ),
            );
          }),
        ),
        // Weather Card (theme-aware)
        if (_currentWeather != null)
          Positioned(
            top: 80,
            right: 20,
            child: Builder(builder: (ctx) {
              final theme = Theme.of(ctx);
              final cardColor = theme.cardColor;
              final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: theme.iconTheme.color ?? Colors.orange),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_currentWeather!.temperature.toStringAsFixed(0)}°C', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        Text(_currentWeather!.condition, style: TextStyle(fontSize: 12, color: textColor)),
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color, [Color? textColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}