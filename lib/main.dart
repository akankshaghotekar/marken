import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marken/screens/login/splash_screen.dart';
import 'package:marken/utils/background_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Request notification permission (needed for foreground service on Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Request location when in use first, then always (background)
  PermissionStatus statusWhenInUse = await Permission.locationWhenInUse
      .request();

  if (statusWhenInUse.isGranted) {
    PermissionStatus statusAlways = await Permission.locationAlways.request();

    if (statusAlways.isDenied) {
      debugPrint(
        "Background location denied. Tracking will stop when app is closed.",
      );
    }
  } else if (statusWhenInUse.isDenied) {
    debugPrint("Location permission denied. Cannot track location.");
  }

  // Check if location service (GPS) is enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint("Location services are disabled. Prompting user to enable.");
  }

  // Initialize background service (required before runApp)
  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 923),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/': (context) => SplashScreen()},
      ),
    );
  }
}
