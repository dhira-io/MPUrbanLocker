import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/common_appbar.dart';
import '../utils/color_utils.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Flexible(child: Text("Terms & Conditions",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,color: ColorUtils.fromHex("#1F2937"))
                ))
              ],
            ),
            SizedBox(height: 12,),
            _BodyText(
              "Welcome to MP Urban Locker, the official digital citizen portal of "
                  "the Government of Madhya Pradesh. By accessing or using this "
                  "application, you agree to comply with and be bound by the following "
                  "terms and conditions. Please read these terms carefully before using "
                  "our services.",
            ),
            SizedBox(height: 12),
            _BodyText(
              "These terms constitute a legally binding agreement between you and "
                  "the Government of Madhya Pradesh. If you do not agree to these terms, "
                  "please do not use this application.",
            ),
            SizedBox(height: 20),

            /// Section 1
            _SectionTitle("1. User Eligibility"),
            SizedBox(height: 8),
            _BodyText(
              "To use MP Urban Locker, you must be a legal resident or citizen of "
                  "India and at least 18 years of age. By using this application, you "
                  "represent and warrant that you meet these eligibility requirements.",
            ),
            SizedBox(height: 12),
            _BodyText(
              "You are responsible for ensuring that all information provided during "
                  "registration is accurate, complete, and up-to-date. Any false or "
                  "misleading information may result in suspension or termination of "
                  "your account.",
            ),
          ],
        ),
      ),
      endDrawer: customEndDrawer(context),

    );
  }
}

/// 🔹 Section Title Widget
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorUtils.fromHex("#1F2937"),
      ),
    );
  }
}

/// 🔹 Body Text Widget
class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: ColorUtils.fromHex("#4B5563"),
      ),
    );
  }
}
