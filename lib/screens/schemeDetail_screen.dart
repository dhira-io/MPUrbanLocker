import 'package:digilocker_flutter/components/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scheme_model.dart';

class SchemeDetailScreen extends StatelessWidget {
  final SchemeMatch scheme;
  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns arrow to the top
                children: [
                  IconButton(
                    // Using arrow_back instead of arrow_back_ios for a cleaner Material look
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded( // <--- Crucial: Prevents overflow and allows text wrapping
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          scheme.schemeName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2, // Improves spacing between lines
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scheme.issuingAuthority,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildSection('Details', scheme.summary, true),

            if (scheme.benefits.isNotEmpty)
              _buildSection('Benefits',
                  scheme.benefits.map((b) => "• ${b['description']}").join("\n\n"), false),

            if (scheme.eligibilityRules.isNotEmpty)
              _buildSection('Eligibility',
                  scheme.eligibilityRules.map((r) => "• ${r['original_text']}").join("\n\n"), false),

          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isFirst) {
    return ExpansionTile(
      initiallyExpanded: isFirst,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      expandedAlignment: Alignment.topLeft,
      children: [
        Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 10),
      ],
    );
  }
}