import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/providers/dashboard_provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';
import 'package:uber_drivers_app/providers/trips_provider.dart';
import 'package:uber_drivers_app/widgets/blocked_screen.dart';

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
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TripProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Uber Drivers App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AuthenticationProvider via Provider
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return FutureBuilder<User?>(
      future: FirebaseAuth.instance
          .authStateChanges()
          .first, // Check if Firebase user exists
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          ); // Show loading indicator
        }

        // If user is not logged in, navigate to RegisterScreen
        if (!snapshot.hasData || snapshot.data == null) {
          return const RegisterScreen();
        }

        // If user is logged in, first check if the driver is blocked
        return FutureBuilder<bool>(
          future: authProvider
              .checkIfDriverIsBlocked(), // Check if the driver is blocked
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              // If the driver is blocked, show an appropriate message
              return const BlockedScreen();
            }
            // If the driver is not blocked, check for profile completeness
            return FutureBuilder<bool>(
              future: authProvider
                  .checkDriverFieldsFilled(), // Check if the profile fields are filled
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(
                          child: CircularProgressIndicator(
                    color: Colors.black,
                  )));
                }

                if (snapshot.hasData && snapshot.data == true) {
                  // If profile is complete, navigate to the dashboard
                  return const Dashboard();
                } else {
                  // If profile is incomplete, navigate to the registration screen
                  return const RegisterScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
