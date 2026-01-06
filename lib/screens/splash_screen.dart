import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/splash_provider.dart';
import '../utils/color_utils.dart';
import 'combine_dashboard.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the status check/timer
    Provider.of<SplashProvider>(context, listen: false).startSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(
      builder: (ctx, splash, child) {
        if (splash.isReady) {
          final bool isLoggedIn = splash.isLoggedIn;
          // Navigation logic executes only after the frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isLoggedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CombinedDashboard(isLoggedIn: true),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LanguageScreen()),
              );
            }
          });
        }

        // --- Existing UI code for the splash screen ---
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 150,),
                  Image.asset('assets/logo.png'),
                  SizedBox(height: 32),
                  Text(
                    "MP Urban Locker",
                    style: TextStyle(
                      color: ColorUtils.fromHex("#613AF5"),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Secure Digital Document Vault",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/svg.png'),
                        SizedBox(width: 8),
                        Text(
                          "Government of Madhya Pradesh",
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}