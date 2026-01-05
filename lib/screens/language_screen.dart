import 'package:digilocker_flutter/screens/PrivacyPolicyScreen.dart';
import 'package:digilocker_flutter/screens/TermsConditionScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/color_utils.dart';
import 'onboarding_screen.dart';
import 'package:flutter/gestures.dart';

class LanguageScreen extends StatelessWidget {

  final List<Map<String, String>> languages = [
    {"code": "English", "label": "English (Default)"},
    {"code": "Hindi", "label": "हिंदी (Hindi)"},
    {"code": "Marathi", "label": "मराठी (Marathi)"},
    {"code": "Gujarati", "label": "ગુજરાતી (Gujarati)"},
    {"code": "Tamil", "label": "தமிழ் (Tamil)"},
    {"code": "Bengali", "label": "বাংলা (Bengali)"},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final String logoImage = 'assets/logo.png';
    final String lionImage = 'assets/lion.png';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 30, height: 30, child: Image.asset(lionImage)),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(logoImage, color: const Color(0xff613AF5)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child:  Text(
                'MP Urban Locker',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorUtils.fromHex("#613AF5")
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [

              // Header Icon
              //Icon(Icons.language, size: 56, color: Color(0xFF5C3AFF)),
              Image.asset('assets/lang.png'),
              SizedBox(height: 10),

              Text(
                "Choose Your Preferred Language",
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ColorUtils.fromHex("#1F2937")
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8),

              Text(
                "You can change this anytime in Settings.",
                style:GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorUtils.fromHex("#4B5563")
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24),

              // Language Options
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    bool isSelected = provider.selectedLanguage == lang["code"];

                    return GestureDetector(
                      onTap: () {
                        provider.changeLanguage(lang["code"]!);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Color(0xFF5C3AFF) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang["label"]!,
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ColorUtils.fromHex("#1F2937")
                                  ),
                                ),
                                Text(
                                  getScriptName(lang["code"]!),
                                  style:GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorUtils.fromHex("#6B7280")
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected ? Color(0xFF5C3AFF) : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10,),

              // Continue Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Color(0xFF5C3AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OnboardingScreen()),
                  );
                },
                child: Text("Continue", style: TextStyle(fontSize: 18,color: Colors.white)
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "By continuing, you agree to the ",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: "Terms",
                        style: TextStyle(
                          color: Color(0xff613AF5), // link color
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            // const url = "https://example.com/terms";
                            // if (await canLaunch(url)) {
                            //   await launch(url);
                            // }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TermsAndConditionsScreen()),
                            );
                          },
                      ),
                      TextSpan(
                        text: " & ",
                      ),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: Color(0xff613AF5), // link color
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            // const url = "https://example.com/privacy";
                            // if (await canLaunch(url)) {
                            //   await launch(url);
                            // }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  /// Script descriptions based on language
  String getScriptName(String code) {
    switch (code) {
      case "Hindi": return "Devanagari Script";
      case "Marathi": return "Devanagari Script";
      case "Gujarati": return "Gujarati Script";
      case "Tamil": return "Tamil Script";
      case "Bengali": return "Bengali Script";
      default: return "Default";
    }
  }
}
