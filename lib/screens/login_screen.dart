import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../utils/color_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for state changes (e.g., loading state)
    final loginProvider = context.watch<LoginProvider>();
    final double screenHeight = MediaQuery.of(context).size.height;

    // The primary color from the image
    const Color primaryPurple = Color.fromRGBO(96, 75, 204, 1.0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon:  Icon(Icons.arrow_back_ios, color: ColorUtils.fromHex("#212121")),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 30, height: 30, child: Image.asset("assets/lion.png")),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset("assets/logo.png", color: const Color(0xff613AF5)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child:  Text(
                  'MP Urban Locker',
                  style:GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.fromHex("#613AF5")
                  )
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1), // Vertical spacing

              // The main login card
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Register / Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Begin your secure session with a one-time password.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // Input Field Label
                      const Text(
                        'Mobile Number / Aadhaar Number / Samagra ID',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Input Field
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter your number or ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        // 2. Update state on change
                        onChanged: (value) {
                          context.read<LoginProvider>().setInputID(value);
                        },
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Enter a valid mobile number or ID.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 25),

                      // Send OTP Button
                      ElevatedButton(
                        // 3. Button logic depends on state
                        onPressed: loginProvider.isInputValid && !loginProvider.isLoading
                            ? () {
                          context.read<LoginProvider>().sendOTP(context);
                        }
                            : null, // Button is disabled if input is invalid or loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                        child: loginProvider.isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ) // Show loading spinner
                            : const Text(
                          'Send OTP',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Need Help Link
                      TextButton(
                        onPressed: () {
                          // Handle navigation to help/support
                        },
                        child: const Text(
                          'Need help?',
                          style: TextStyle(color: primaryPurple),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom links
              SizedBox(height: screenHeight * 0.1),
              const Text('Terms of Service', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 5),
              const Text('Privacy Policy', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}