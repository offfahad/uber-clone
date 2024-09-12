import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/authentication/login_screen.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/pages/driver_registration/driver_registration.dart';
import 'package:uber_drivers_app/pages/home_page.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  await Permission.notification.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.notification.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationProvider(),
        )
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Uber Drivers App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        // ThemeData.dark().copyWith(
        //   scaffoldBackgroundColor: Colors.white,
        // ),
        home: RegisterScreen(),
        //FirebaseAuth.instance.currentUser == null ? LoginScreen() : Dashboard(),
      ),
    );
  }
}
