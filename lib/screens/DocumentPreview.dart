import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../components/common_appbar.dart';
import '../services/LocalNotificationServices.dart';
import '../utils/constants.dart';

class DocumentPreview extends StatefulWidget {
  final String title;
  final String? uri;
  final String date;
  final String pdfString;

  const DocumentPreview({
    super.key,
    required this.title,
    this.uri,
    required this.date,
    required this.pdfString,
  });

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  static const _storage = FlutterSecureStorage();

  String? localPdfPath;
  Uint8List? bytesOfDoc;

  @override
  void initState() {
    super.initState();
    widget.pdfString.isNotEmpty
        ? _convertBase64ToFile(widget.pdfString)
        : _viewDocument();
  }

  /// 📄 Fetch PDF from API
  Future<void> _viewDocument() async {
    final accessToken =
        await _storage.read(key: AppConstants.tokenKey) ?? '';
    final userId =
        await _storage.read(key: AppConstants.userIdKey) ?? '';

    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.documentFileEndpoint(userId, widget.uri ?? "")}',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/${widget.title.replaceAll(' ', '_')}.pdf',
      );

      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        localPdfPath = file.path;
        bytesOfDoc = response.bodyBytes;
      });
    }
  }

  /// 🔐 Convert Base64 to PDF
  Future<void> _convertBase64ToFile(String base64Pdf) async {
    final bytes = base64Decode(base64Pdf);
    final dir = await getTemporaryDirectory();
    final file =
    File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.pdf');

    await file.writeAsBytes(bytes);

    setState(() {
      localPdfPath = file.path;
      bytesOfDoc = bytes;
    });
  }

  /// ⬇ Save / Share PDF
  Future<void> _saveToDownloads(Uint8List bytes, String name) async {
    if (Platform.isAndroid) {
      final file =
      await File('/storage/emulated/0/Download/$name.pdf').writeAsBytes(bytes);

      if ((await file).path.isNotEmpty) {
        _showSnackBar('Document Successfully Downloaded', Colors.green);
        // Show notification
        await LocalNotificationService.showNotification(
            title: 'Download Complete', body: '$name.pdf downloaded',
            filePath: file.path);
      } else {
        _showSnackBar('Download failed', Colors.red);
      }
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name.pdf');
      await file.writeAsBytes(bytes ,flush: true);
      if ((await file).path.isNotEmpty) {
        _showSnackBar('Document Successfully Downloaded', Colors.green);
        // Show notification
        await LocalNotificationService.showNotification(
            title: 'Download Complete', body: '$name.pdf downloaded',
            filePath: file.path);
      } else {
        _showSnackBar('Download failed', Colors.red);
      }
      // await Share.shareXFiles([XFile(file.path)]);
    }
  }

  void _downloadPdf() async {
    try {
      final userId =
          await _storage.read(key: AppConstants.userIdKey) ?? '';
      final fileName =
      '${widget.title}_$userId'.replaceAll('/', '');

      await _saveToDownloads(bytesOfDoc!, fileName);
    } catch (e) {
      debugPrint('Download error: $e');
      _showSnackBar('Download failed', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _formatDate(String inputDate) {
    if (inputDate.isEmpty) return '-';

    final input = DateFormat('dd-MM-yyyy').parse(inputDate);
    return DateFormat('MMM d, yyyy').format(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _verifiedCard(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _pdfViewer(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _downloadButton(),
                const SizedBox(height: 12),
                _actionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          Text(widget.title),
        ],
      ),
    );
  }

  Widget _verifiedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF7EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1DBF73),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check,
                color: Color(0xFFDFF7EA), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document Verified',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DBF73),
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This document has been validated and is authentic.',
                  style:
                  TextStyle(fontSize: 12, color: Color(0xFF55DA91)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Verified on ${_formatDate(widget.date)}',
                  style:
                  const TextStyle(fontSize: 11, color: Color(0xFF55DA91)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pdfViewer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: localPdfPath == null
          ? const Center(child: CircularProgressIndicator())
          : ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PDFView(
          filePath: localPdfPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
        ),
      ),
    );
  }

  Widget _downloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _downloadPdf();
        },
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('Download Document',
            style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A48F5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Share Document'),
          ),
        ),
        const SizedBox(width: 12),
/*
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text('E-Sign Document'),
          ),
        ),
*/
      ],
    );
  }
}
