// lib/screens/otp_screen.dart (Full Code)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../providers/otp_provider.dart';
import '../utils/color_utils.dart';

class OTPScreen extends StatelessWidget {
  // Pass the phone number for display/API reference
  final String verificationTarget;

  const OTPScreen({required this.verificationTarget, super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color.fromRGBO(96, 75, 204, 1.0);

    // Default theme for the OTP fields
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: primaryPurple, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    // Provide the OTPProvider here, assuming we navigate from the LoginScreen
    return ChangeNotifierProvider(
      create: (context) => OTPProvider(),
      child: Scaffold(
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
              SizedBox(width: 23.64, height: 40, child: Image.asset("assets/lion.png")),
              const SizedBox(width: 10),
              SizedBox(
                width: 33,
                height: 40,
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
        body: Consumer<OTPProvider>(
          builder: (context, otpProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Verify your Identity',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'An OTP has been sent to your mobile number $verificationTarget',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Text('Enter 6-digit OTP'),

                  // 1. The Pinput Widget (OTP Input)
                  Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyDecorationWith(
                      border: Border.all(color: primaryPurple, width: 2),
                    ),
                    // Update the state in the Provider when code changes
                    onChanged: (value) => otpProvider.setOTPCode(value),
                    // Automatically submit when complete (optional)
                    //onCompleted: (value) => otpProvider.verifyOTP(context,verificationTarget),
                    keyboardType: TextInputType.number,
                    animationDuration: const Duration(milliseconds: 300),
                  ),

                  const SizedBox(height: 40),

                  // 2. The Verification Button
                  ElevatedButton(
                    onPressed: otpProvider.isCodeComplete && !otpProvider.isVerificationLoading
                        ? () => otpProvider.verifyOTP(context,verificationTarget)
                        : null, // Disabled if code is incomplete or loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 0,
                    ),
                    child: otpProvider.isVerificationLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      'Verify & Continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. Resend OTP Button & Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        otpProvider.isResendEnabled
                            ? "Didn't receive code?"
                            : "Resend code in:",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 8),

                      if (!otpProvider.isResendEnabled)
                        Text(
                          '${otpProvider.remainingTime}s',
                          style: const TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                      if (otpProvider.isResendEnabled)
                        TextButton(
                          onPressed: () => otpProvider.resendOTP(context),
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
