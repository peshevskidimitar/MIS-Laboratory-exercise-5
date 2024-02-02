import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../notifications/local_notifications_manager.dart';
import 'locations.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> sendLocationBasedNotifications() async {
    final locations = await getLaboratories();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position == null) return;

      Position currentLocation = await LocationService.getCurrentLocation();
      for (final laboratory in locations.laboratories) {
        double distanceInMeters = Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          laboratory.lat,
          laboratory.lng,
        );
        if (distanceInMeters < 30) {
          localNotificationsManager.sendNotification(LocalNotification(
            Random().nextInt(1000),
            'Nearby ${laboratory.name}',
            'You are nearby ${laboratory.name}.',
            null,
          ));
        }
      }
    });
  }
}
