import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/editdoc_share_provider.dart';

class EditDocShareScreen extends StatelessWidget {
  const EditDocShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditDocShareProvider(),
      child: const _EditDocShareView(),
    );
  }
}

class _EditDocShareView extends StatelessWidget {
  const _EditDocShareView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditDocShareProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "Driving License",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sharingSummaryCard(provider),
            const SizedBox(height: 24),
            _actionButtons(provider),
            const SizedBox(height: 16),
            _shareButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _sharingSummaryCard(EditDocShareProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sharing Summary",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 16),

          _readOnlyField("Document", provider.documentController),
          _dropdownField(
            "Method",
            provider.selectedMethod,
            provider.methods,
            provider.setMethod,
          ),
          _dropdownField(
            "Protection",
            provider.selectedProtection,
            provider.protections,
            provider.setProtection,
          ),
          _readOnlyField("Shared With", provider.sharedWithController),
          _dropdownField(
            "Expires On",
            provider.selectedExpiry,
            provider.expiryOptions,
            provider.setExpiry,
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: _inputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(
      String label,
      String value,
      List<String> items,
      ValueChanged<String> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
                .toList(),
            onChanged: (val) => onChanged(val!),
            decoration: _inputDecoration(),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(EditDocShareProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: provider.saveDetails,
            icon: const Icon(Icons.check, size: 18),
            label: const Text("Save Details"),
            style: _outlinedButtonStyle(Colors.deepPurple),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: provider.revokeLink,
            icon: const Icon(Icons.close, size: 18),
            label: const Text("Revoke Link"),
            style: _outlinedButtonStyle(Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _shareButton(EditDocShareProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.shareDocument,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
        child: const Text(
          "Share Document",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
  }
}
