import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/common_appbar.dart';
import '../utils/color_utils.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text("Privacy Policy",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,color: ColorUtils.fromHex("#1F2937"))
                ),
              ],
            ),
            SizedBox(height: 12),

            /// Last Updated Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_filled, size: 20, color: ColorUtils.fromHex("#6C47FF")),
                  SizedBox(width: 8),
                  Text(
                    "Last updated: December 15, 2024",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorUtils.fromHex("#4B5563"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Intro Text
            const _BodyText(
              "MP Urban Locker is committed to protecting your privacy and ensuring "
              "the security of your personal information. This Privacy Policy explains "
              "how we collect, use, store, and protect your data when you use our "
              "Digital Citizen Portal.",
            ),
            const SizedBox(height: 12),
            const _BodyText(
              "By using MP Urban Locker, you consent to the practices described in "
              "this policy.",
            ),

            const SizedBox(height: 24),

            /// Information We Collect
            _SectionHeader(icon: Icons.shield, title: "Information We Collect"),
            const SizedBox(height: 12),

            /// Personal Information
            const _SubTitle("Personal Information"),
            const SizedBox(height: 6),
            const _BulletText("Name, date of birth, and contact details"),
            const _BulletText("Government-issued identification numbers"),
            const _BulletText("Address and residential information"),
            const _BulletText(
              "Biometric data (when required for verification)",
            ),

            const SizedBox(height: 16),

            /// Technical Information
            const _SubTitle("Technical Information"),
            const SizedBox(height: 6),
            const _BulletText("Device information and operating system"),
            const _BulletText("IP address and location data"),
            const _BulletText("App usage patterns and preferences"),
          ],
        ),
      ),
      endDrawer: customEndDrawer(context),
    );
  }
}

/// 🔹 Section Header
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: ColorUtils.fromHex("#6C47FF"),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// 🔹 Sub Title
class _SubTitle extends StatelessWidget {
  final String text;

  const _SubTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}

/// 🔹 Bullet Text
class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
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
      style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
    );
  }
}
