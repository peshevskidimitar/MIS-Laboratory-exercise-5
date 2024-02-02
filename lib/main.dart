import 'package:exam_schedule/screens/auth_screen.dart';
import 'package:exam_schedule/screens/timetable_screen.dart';
import 'package:exam_schedule/services/locations/location_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'application_state.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LocationService().sendLocationBasedNotifications();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, child) => const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body:
            Consumer<ApplicationState>(builder: (context, applicationState, _) {
          if (applicationState.loggedIn) {
            return TimetableScreen(
              timetableItems: applicationState.timetableItems,
            );
          } else {
            return const AuthScreen();
          }
        }),
      ),
    );
  }
}
