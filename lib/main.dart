import 'package:digilocker_flutter/providers/Setpin_provider.dart';
import 'package:digilocker_flutter/providers/auth_provider.dart';
import 'package:digilocker_flutter/providers/drawer_provider.dart';
import 'package:digilocker_flutter/providers/license_provider.dart';
import 'package:digilocker_flutter/providers/login_provider.dart';
import 'package:digilocker_flutter/providers/onboarding_provider.dart';
import 'package:digilocker_flutter/providers/otp_provider.dart';
import 'package:digilocker_flutter/services/LocalNotificationServices.dart';
import 'package:digilocker_flutter/services/api_service.dart';
import 'package:digilocker_flutter/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/splash_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.init();
  await LocalNotificationService.requestNotificationPermission();
  await ConfigService.loadConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => OTPProvider()),
        ChangeNotifierProvider(create: (_) => SetpinProvider()),
        ChangeNotifierProvider(create: (_) => LicenseProvider()),
        ChangeNotifierProvider(create: (_) => DrawerProvider()),
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) =>
              AuthProvider(apiService: context.read<ApiService>()),
          update: (context, apiService, previous) =>
          previous ?? AuthProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Color(0xff613AF5),
        home: SplashScreen(),
      ),
    );
  }
}
