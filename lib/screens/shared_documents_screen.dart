import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/common_appbar.dart';
import '../utils/color_utils.dart';

class SharedDocument {
  final String title;
  final String sharedWith;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  SharedDocument({
    required this.title,
    required this.sharedWith,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class SharedDocumentsScreen extends StatefulWidget {
  const SharedDocumentsScreen({Key? key}) : super(key: key);

  @override
  _SharedDocumentsScreenState createState() => _SharedDocumentsScreenState();
}

class _SharedDocumentsScreenState extends State<SharedDocumentsScreen> {
  // Dummy data based on the image provided
  final List<SharedDocument> _sharedDocuments = [
    SharedDocument(title: 'PAN Verification Record', sharedWith: 'Amit K.', icon: Icons.badge_outlined, iconBgColor: ColorUtils.fromHex("#FEF2F2"), iconColor: ColorUtils.fromHex("#EF4444")),
    SharedDocument(title: 'Driving License', sharedWith: 'S. Singh', icon: Icons.credit_card_outlined, iconBgColor: ColorUtils.fromHex("#EEF2FF"), iconColor: ColorUtils.fromHex("#5A48F5")),
    SharedDocument(title: 'Driving License', sharedWith: 'R. Kumar', icon: Icons.credit_card_outlined, iconBgColor: ColorUtils.fromHex("#EEF2FF"), iconColor: ColorUtils.fromHex("#5A48F5")),
    SharedDocument(title: 'Vehicle Registration\nCertificate', sharedWith: 'Tarun J.', icon: Icons.directions_car_outlined, iconBgColor: ColorUtils.fromHex("#FFFBEB"), iconColor: ColorUtils.fromHex("#F59E0B")),
    SharedDocument(title: 'Marksheet / Certificates', sharedWith: 'R. Kumar', icon: Icons.school_outlined, iconBgColor: ColorUtils.fromHex("#EFF6FF"), iconColor: ColorUtils.fromHex("#3B82F6")),
    SharedDocument(title: 'Aadhaar-based Services', sharedWith: 'R. Kumar', icon: Icons.fingerprint, iconBgColor: ColorUtils.fromHex("#F0FDF4"), iconColor: ColorUtils.fromHex("#1DBF73")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.fromHex("#F9FAFB"),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _buildSharedDocumentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Shared Documents',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for Documents',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            Image.asset('assets/s_icon.png', height: 24, width: 24), // Assuming s_icon is in assets
            const SizedBox(width: 8),
            const Icon(Icons.mic, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedDocumentsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _sharedDocuments.length,
      itemBuilder: (context, index) {
        final doc = _sharedDocuments[index];
        return _buildSharedDocumentCard(doc);
      },
    );
  }

  Widget _buildSharedDocumentCard(SharedDocument doc) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: doc.iconBgColor,
              child: Icon(
                doc.icon,
                color: doc.iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shared with ${doc.sharedWith}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
