import 'package:digilocker_flutter/components/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_utils.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<FaqItem> faqs = [
    FaqItem(
      question: "What is MP Urban Locker?",
      answer:
      "MP Urban Locker is a digital citizen portal that provides secure access to "
          "government documents and services. It serves as your personal digital wallet "
          "for all official documents, certificates, and licenses issued by various "
          "government departments in Madhya Pradesh.",
    ),
    FaqItem(
      question: "Is my data secure?",
      answer:
      "Yes. MP Urban Locker follows government security standards and ensures "
          "encryption and secure authentication for all user data.",
    ),
    FaqItem(
      question: "How do I fetch government documents?",
      answer:
      "You can fetch documents by linking your DigiLocker account and selecting "
          "the required department and document type.",
    ),
    FaqItem(
      question: "What if a document is not available?",
      answer:
      "If a document is not available, please check with the issuing authority or "
          "contact support for assistance.",
    ),
    FaqItem(
      question: "How can I contact support?",
      answer:
      "You can contact support via the Help & Support section or email us at "
          "support@mpurbanlocker.gov.in",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text("FAQs",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,color: ColorUtils.fromHex("#1F2937"))
                )
              ],
            ),
            SizedBox(height: 12,),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _faqList()),
          ],
        ),
      ),
      endDrawer: customEndDrawer(context),
    );
  }

  /// 🔍 Search Bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        // Changed to white for better contrast with grey[50] background
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.search, color: ColorUtils.fromHex("#212121")),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for FAQ...',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: GoogleFonts.inter(fontSize: 16,fontWeight: FontWeight.w400, color: ColorUtils.fromHex("#2121217A")),
                  ),
                ),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!),
                color: Colors.blue[50],
              ),
              child: Image.asset('assets/s_icon.png'),
            ),
            const SizedBox(width: 8),
            Icon(Icons.mic, color: ColorUtils.fromHex("#212121")),
          ],
        ),
      ),
    );
  }


  /// ❓ FAQ List
  Widget _faqList() {
    final filteredFaqs = faqs
        .where((faq) =>
    faq.question
        .toLowerCase()
        .contains(_searchController.text.toLowerCase()) ||
        faq.answer
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredFaqs.length,
      itemBuilder: (context, index) {
        return _faqTile(filteredFaqs[index]);
      },
    );
  }

  /// 📂 FAQ Accordion Tile
  Widget _faqTile(FaqItem faq) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorUtils.fromHex("#1F2937"),
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              faq.answer,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📦 FAQ Model
class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });
}
