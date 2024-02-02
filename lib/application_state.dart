import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_schedule/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;
import 'models/timetable_item.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

class ApplicationState extends ChangeNotifier {
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _timetableItemsSubscription;
  List<TimetableItem> _timetableItems = [];

  List<TimetableItem> get timetableItems => _timetableItems;

  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }

    String? token = await FirebaseMessaging.instance.getToken();

    if (kDebugMode) {
      print('Registration Token=$token');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _timetableItemsSubscription = FirebaseFirestore.instance
            .collection('timetable-items')
            .orderBy('time', descending: false)
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots()
            .listen((snapshot) {
          _timetableItems = [];
          for (final document in snapshot.docs) {
            _timetableItems.add(TimetableItem(
              document.id,
              document.data()['subject'] as String,
              document.data()['time'].toDate(),
              document.data()['userId'] as String,
              document.data()['location'] as String,
            ));
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;

        _timetableItems = [];
        _timetableItemsSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<DocumentReference> addTimetableItemToTimetable(
      String subject, DateTime time, String location) {
    if (!loggedIn) {
      throw Exception('Must be logged in.');
    }

    return FirebaseFirestore.instance.collection('timetable-items').add({
      'subject': subject,
      'time': time,
      'location': location,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  void removeTimetableItemFromTimetable(String id) {
    FirebaseFirestore.instance.collection('timetable-items').doc(id).delete();
  }
}
