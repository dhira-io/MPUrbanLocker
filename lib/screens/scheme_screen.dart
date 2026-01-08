import 'package:digilocker_flutter/models/documentExpiry_model.dart';
import 'package:digilocker_flutter/screens/schemeDetail_screen.dart';
import 'package:digilocker_flutter/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scheme_model.dart';
import '../providers/scheme_provider.dart';

class SchemeScreen extends StatefulWidget {
  const SchemeScreen({super.key});

  @override
  State<SchemeScreen> createState() => _SchemeScreenState();
}

class _SchemeScreenState extends State<SchemeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Access the provider
      final provider = Provider.of<SchemeProvider>(context, listen: false);

      // 2. Await the first call (Schemes)
      await provider.fetchSchemes(context);

      // 3. Await the second call (Documents)
      // This ensures provider.documents is now full of data
      await provider.fetchDocumentsExpiry(context);

      // 4. Check if the widget is still in the tree before showing dialog
      if (mounted) {
        _checkAndShowExpiryPopup(provider.documents);
      }
    });
  }

  // Inside _SchemeScreenState

  void _checkAndShowExpiryPopup(List<DocumentExpiry> documents) {
    // 1. Filter the list to get ALL documents with expiry enabled
    final expiredDocs = documents.where((doc) => doc.hasExpiry == true).toList();

    // 2. Only show the dialog if the list is not empty
    if (expiredDocs.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1E4B), Color(0xFF1A3B8B)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Dialog shrinks to fit content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Document Validity Expired!',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. The List of Expired Documents
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: expiredDocs.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.docType.replaceAll('_', ' '),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFDBEAFE),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doc.expiryDate != null && doc.expiryDate!.isNotEmpty
                                    ? 'Expires: ${doc.expiryDate}'
                                    : 'Expiry tracking active',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                              const Divider(color: Colors.white10, height: 20),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // White Action Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Got it',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF613AF5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF613AF5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Consumer<SchemeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF613AF5)));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Text('Recommended Schemes',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Based on your fetched documents, MP Locker identified these schemes:',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 20),

              ...provider.schemes.map((scheme) => _buildSchemeCard(context, scheme)),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, SchemeMatch scheme) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(scheme.schemeName,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SchemeDetailScreen(scheme: scheme))),
                  child: const Text('View More', style: TextStyle(color: Color(0xFF613AF5))),
                )
              ],
            ),
            Text(scheme.issuingAuthority,
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            Text(scheme.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

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
                  onChanged: (value) {
                    context.read<SchemeProvider>().searchSchemes(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search schemes...',
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
}