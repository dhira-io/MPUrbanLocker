import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/common_appbar.dart';
import '../utils/color_utils.dart';

class AboutMpUrbanLockerScreen extends StatefulWidget {
  const AboutMpUrbanLockerScreen({super.key});

  @override
  State<AboutMpUrbanLockerScreen> createState() =>
      _AboutMpUrbanLockerScreenState();
}

class _AboutMpUrbanLockerScreenState extends State<AboutMpUrbanLockerScreen> {

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
                Text("About MP Urban Locker",style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,color: ColorUtils.fromHex("#1F2937")),)
              ],
            ),
            SizedBox(height: 12,),
            /// Section Title
            _SectionTitle("What is MP Urban Locker?"),
            SizedBox(height: 12),

            /// Description
            _BodyText(
              "MP Urban Locker is a secure, government-backed digital document "
                  "repository designed for citizens of Madhya Pradesh. It serves as "
                  "your personal digital vault where you can safely store, access, and "
                  "share important government documents anytime, anywhere. Built with "
                  "cutting-edge security protocols, it ensures your sensitive "
                  "information remains protected while providing seamless access to "
                  "essential services.",
            ),

            SizedBox(height: 20),

            /// Key Features
            _SectionTitle("Key Features"),
            SizedBox(height: 16),

            _FeatureItem(
              icon: Icons.shield,
              text: "Secure document storage with end-to-end encryption",
            ),
            _FeatureItem(
              icon: Icons.file_download,
              text: "Automatic government-issued document fetching",
            ),
            _FeatureItem(
              icon: Icons.share,
              text:
              "Controlled document sharing with consent management",
            ),
          ],
        ),
      ),
      endDrawer: customEndDrawer(context),

    );
  }
}

/// 🔹 Section Title
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
          color: ColorUtils.fromHex("#111827")
      ),
    );
  }
}

/// 🔹 Body Text
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
          color: ColorUtils.fromHex("#374151")
      ),
    );
  }
}

/// 🔹 Feature Item
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 20, color: ColorUtils.fromHex("#613AF5")),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 16, color: ColorUtils.fromHex("#374151"),fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
