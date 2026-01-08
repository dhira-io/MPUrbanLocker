import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common_appbar.dart';
import '../models/doc_service_config.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import 'DocumentPreview.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ComingSoonScreen extends StatefulWidget {
  final String docType;

  const ComingSoonScreen({super.key, required this.docType});

  @override
  _ComingSoonScreenState createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Flexible(
                    child: Text(
                      widget.docType,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorUtils.fromHex("#1F2937"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ColorUtils.fromHex("#EFF6FF"),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.file_copy_outlined,
                          color: ColorUtils.fromHex("#613AF5"),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Coming Soon!',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ColorUtils.fromHex("#6D28D9"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This feature is currently under\n'
                            'development and will be shortly in\n'
                            'MP Urban Locker.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorUtils.fromHex("#4B5563"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We're working to bring you a more secure "
                            'and seamless experience.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorUtils.fromHex("#6B7280"),
                          fontStyle: FontStyle.italic
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: customEndDrawer(context),
    );
  }
}

