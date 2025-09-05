// lib/button2.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// A simple data class for a school
class School {
  final String name;
  final LatLng location;

  School({required this.name, required this.location});
}

class Button2Screen extends StatefulWidget {
  const Button2Screen({super.key});

  @override
  State<Button2Screen> createState() => _Button2ScreenState();
}

class _Button2ScreenState extends State<Button2Screen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _message = "Finding your location...";
  List<School> _schools = [];
  final double _searchRadiusMeters = 10000.0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  

Future<void> _determinePosition() async {
  
  print("Starting location check...");
  setState(() {
    _isLoading = true;
    _message = "Finding your location...";
  });

  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled."); 
    setState(() {
      _message = 'Location services are disabled.';
      _isLoading = false;
    });
    return;
  }
  print("Location services are enabled."); 

  permission = await Geolocator.checkPermission();
  print("Current location permission is: $permission");
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    print("Permission requested. New status: $permission"); 
    if (permission == LocationPermission.denied) {
      print("Location permission was denied by user.");
      setState(() {
        _message = 'Location permissions are denied.';
        _isLoading = false;
      });
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permission was permanently denied.");
    setState(() {
      _message = 'Location permissions are permanently denied.';
      _isLoading = false;
    });
    return;
  }

  print("Permissions are OK. Trying to get current position...");
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print("SUCCESS! Position found: $position");
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _message = "Finding schools within 10 meters...";
      _mapController.move(_currentPosition!, 18.0);
    });
    await _findSchoolsNearby();
  } catch (e) {
    print("ERROR getting location: $e");
    setState(() {
      _message = "Could not get your location. Make sure GPS is on.";
      _isLoading = false;
    });
  }
}

  Future<void> _findSchoolsNearby() async {
    
    if (_currentPosition == null) return;

    final lat = _currentPosition!.latitude;
    final lon = _currentPosition!.longitude;
    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    
    final query = """
      [out:json];
      (
        node["amenity"="school"](around:$_searchRadiusMeters,$lat,$lon);
        way["amenity"="school"](around:$_searchRadiusMeters,$lat,$lon);
        relation["amenity"="school"](around:$_searchRadiusMeters,$lat,$lon);
      );
      out center;
    """;

    try {
      final response = await http.post(url, body: query);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<School> foundSchools = [];
        for (final element in data['elements']) {
          final name = element['tags']?['name'] ?? 'School (No Name)';
          final lat = element['center']?['lat'] ?? element['lat'];
          final lon = element['center']?['lon'] ?? element['lon'];
          if (lat != null && lon != null) {
            foundSchools.add(School(name: name, location: LatLng(lat, lon)));
          }
        }
        setState(() {
          _schools = foundSchools;
          _isLoading = false;
          _message = _schools.isEmpty
              ? "No schools found within 10 meters."
              : "Found ${_schools.length} school(s)!";
        });
      } else {
        throw Exception('Failed to load data from Overpass API');
      }
    } catch (e) {
      setState(() {
        _message = "Error finding schools: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schools Near Me (10m)"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(30.3752, 76.7821), // Default: Patiala
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                
                userAgentPackageName: 'com.example.school_go', 
                
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_currentPosition != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentPosition!,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: _searchRadiusMeters,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  ..._schools.map((school) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: school.location,
                      child: Tooltip(
                        message: school.name,
                        child: const Icon(Icons.school, color: Colors.red, size: 40),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
          if (_isLoading || _message.isNotEmpty)
            Positioned(
              
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}