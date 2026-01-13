// lib/screens/set_pin_screen.dart
import 'package:digilocker_flutter/providers/Setpin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

class SetPinScreen extends StatelessWidget {
  const SetPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color.fromRGBO(96, 75, 204, 1.0);

    // Define the style for the 4-digit input boxes
    final pinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, color: primaryPurple, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    // Define the style for the active/focused pin (used for the confirmation box outline)
    final focusedPinTheme = pinTheme.copyDecorationWith(
      border: Border.all(color: primaryPurple, width: 2),
    );

    return ChangeNotifierProvider(
      create: (context) => SetpinProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'MP Urban Locker',
            style: TextStyle(
              color: const Color(0xff613AF5),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<SetpinProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  // Main Content Card
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
                            'Create MP Locker PIN',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This will be required for future logins.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // --- 1. Enter 4-Digit PIN ---
                          const Text('Enter 4-Digit PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Pinput(
                            length: 4,
                            defaultPinTheme: pinTheme,
                            focusedPinTheme: pinTheme, // No special focus color needed here
                            obscureText: true, // Hide the digits
                            keyboardType: TextInputType.number,
                            onChanged: (pin) => provider.setNewPin(pin),
                          ),
                          const SizedBox(height: 30),

                          // --- 2. Confirm PIN ---
                          const Text('Confirm PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Pinput(
                            length: 4,
                            defaultPinTheme: pinTheme,
                            focusedPinTheme: focusedPinTheme, // Use the purple focus border for the second input
                            obscureText: true, // Hide the digits
                            keyboardType: TextInputType.number,
                            onChanged: (pin) => provider.setConfirmPin(pin),
                          ),
                          const SizedBox(height: 40),

                          // --- 3. Save PIN Button ---
                          ElevatedButton(
                            onPressed: provider.isReadyToSave && !provider.pinSaved
                                ? () => provider.savePin()
                                : null, // Disabled if not ready or already saving
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 0,
                            ),
                            child: provider.pinSaved
                                ? const Text('PIN Saved!')
                                : const Text('Save PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 20),

                          // --- 4. Error/Success Message ---
                          if (provider.errorMessage != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.rotate_right, color: Colors.red),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          if (provider.pinSaved && provider.errorMessage == null)
                            const Text(
                              'PIN created successfully!',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Links
                  const SizedBox(height: 80),
                  const Text('Terms of Service', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 5),
                  const Text('Privacy Policy', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}