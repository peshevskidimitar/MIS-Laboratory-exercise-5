import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:exam_schedule/services/locations/locations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/timetable_item.dart';
import '../services/locations/location_service.dart';

class MapScreen extends StatefulWidget {
  final List<TimetableItem> timetableItems;

  const MapScreen({super.key, required this.timetableItems});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};

  Future<void> _showAlertDialog(Laboratory laboratory,
      List<TimetableItem> timetableItems, Uri uri) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(laboratory.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final TimetableItem item in timetableItems)
                  Text(
                    '${item.subject} at ${DateFormat("yyyy-MM-dd – kk:mm").format(item.time)}',
                  ),
              ],
            ),
            actions: [
              IconButton(onPressed: () {
                Navigator.of(context).pop();
              }, icon: const Icon(Icons.close)),
              IconButton(onPressed: () async {
                Navigator.of(context).pop();
                await launchUrl(uri);
              }, icon: const Icon(Icons.directions))
            ],
          );
        });
  }

  Future<void> _onMapCreated(GoogleMapController mapController) async {
    final locations = await getLaboratories();

    Map<String, List<TimetableItem>> timetableItemsByLocation = groupBy(
      widget.timetableItems,
      (timetableItem) => timetableItem.location,
    );

    setState(() {
      _markers.clear();
      for (final laboratory in locations.laboratories) {
        final marker = Marker(
            markerId: MarkerId(laboratory.id.toString()),
            position: LatLng(laboratory.lat, laboratory.lng),
            onTap: () async {
              Position currentLocation =
                  await LocationService.getCurrentLocation();
              String url = 'https://www.google.com/maps/dir/?api=1'
                  '&origin=${currentLocation.latitude},${currentLocation.longitude}'
                  '&destination=${laboratory.lat},${laboratory.lng}';
              if (kDebugMode) {
                print(url);
              }
              Uri uri = Uri.parse(url);
              _showAlertDialog(laboratory, timetableItemsByLocation[laboratory.name]!, uri);
            });
        _markers[laboratory.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GoogleMap(
        mapType: MapType.terrain,
        myLocationEnabled: true,
        trafficEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(42.00488618838531, 21.409228650161914),
          zoom: 17.5,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }
}
