import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final String rawPdf;

  const PdfViewerPage({super.key, required this.rawPdf});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preparePdfFile();
  }

  Future<void> _preparePdfFile() async {
    try {
      // 1. Get temporary directory
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp_document.pdf");

      // 2. Decode Base64 and write to file
      final Uint8List bytes = base64Decode(widget.rawPdf);
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error saving PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Viewer")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localPath != null
          ? PDFView(
        filePath: _localPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) => print("PDF Error: $error"),
      )
          : const Center(child: Text("Could not load PDF")),
    );
  }
}