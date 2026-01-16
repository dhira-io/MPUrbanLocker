import 'dart:io';

import 'package:digilocker_flutter/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../components/common_appbar.dart';
import '../providers/edit_share_provider.dart';
import '../providers/shared_doc_list_provider.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';


class EditShareDetailsScreen extends StatelessWidget {
  final SharedDocModel document;

  const EditShareDetailsScreen({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditShareDetailsProvider(context, document),
      child: const _EditShareDetailsView(),
    );
  }
}

class _EditShareDetailsView extends StatelessWidget {
  const _EditShareDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditShareDetailsProvider>();
    final document = provider.document;

    return Scaffold(
      backgroundColor: ColorUtils.fromHex("#F9FAFB"),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, document),
                const SizedBox(height: 24),
                _buildSharingSummaryCard(context, provider, document),
                const SizedBox(height: 24),
                _buildActionButtons(context, provider),
                const SizedBox(height: 16),
                _buildShareDocumentButton(context, provider),
              ],
            ),
          ),
          if (provider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SharedDocModel document) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Flexible(
          child: Text(
            document.documentName,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSummaryCard(BuildContext context, EditShareDetailsProvider provider, SharedDocModel document) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sharing Summary',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextFieldRow('Document', '${document.documentName}.pdf'),
          _buildDropdownRow('Method', provider.method, ["Secure QR", "Secure Link"], (val) => provider.setMethod(val!)),
          _buildDropdownRow('Protection', provider.protection, ["Generate PIN", "WithOut PIN"], (val) => provider.setProtection(val!)),
          _buildTextFieldRow('PIN', '', isEditable: false, controller: provider.pinController),
          _buildTextFieldRow('Shared With', '', isEditable: true, controller: provider.sharedWithController),
          _buildDateFieldRow(context, 'Expires On', provider.expiresOn, (date) => provider.setExpiresOn(date)),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(String label, String value, {bool isEditable = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600))),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              initialValue: controller == null ? value : null,
              readOnly: !isEditable,
              decoration: _inputDecoration(),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600))),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: value,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
              decoration: _inputDecoration(),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFieldRow(BuildContext context, String label, DateTime value, ValueChanged<DateTime> onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600))),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () async {

                final now = DateTime.now();
                final DateTime firstDate =
                DateTime(now.year, now.month, now.day);

                final DateTime lastDate = firstDate.add(
                  const Duration(days: 7),
                );
                final DateTime initialDate =
                value.isBefore(firstDate) ? firstDate : value;

                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  helpText: 'Select date',
                );

                if (pickedDate != null) onDateChanged(pickedDate);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('d MMM yyyy, hh:mm a').format(value),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ColorUtils.fromHex("#5A48F5"))),
    );
  }

  Widget _buildActionButtons(BuildContext context, EditShareDetailsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => provider.editShare(false),
            icon: Icon(Icons.check, color: ColorUtils.fromHex("#5A48F5")),
            label: Text('Save Details', style: TextStyle(color: ColorUtils.fromHex("#5A48F5"))),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: ColorUtils.fromHex("#5A48F5")),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Do you want to revoke this link?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Revoke Link', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          provider.deleteSharedDoc();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Revoke Link', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareDocumentButton(BuildContext context, EditShareDetailsProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => provider.editShare(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorUtils.fromHex("#5A48F5"),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Share Document',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
