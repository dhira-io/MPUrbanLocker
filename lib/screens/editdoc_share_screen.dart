import 'package:digilocker_flutter/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../components/common_appbar.dart';
import '../providers/shared_doc_list_provider.dart';
import '../utils/color_utils.dart';

class EditShareDetailsScreen extends StatefulWidget {
  final SharedDocModel document;

  const EditShareDetailsScreen({Key? key, required this.document}) : super(key: key);

  @override
  _EditShareDetailsScreenState createState() => _EditShareDetailsScreenState();
}

class _EditShareDetailsScreenState extends State<EditShareDetailsScreen> {
  late String _method;
  late String _protection;
  late String _sharedWith;
  late DateTime _expiresOn;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _method =  widget.document.shareMethod;
     _protection = widget.document.shareMethod; //widget.document.protectionType;
     _sharedWith = widget.document.sharedWithName;
     _expiresOn = widget.document.expiresAt;
  }


  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.fromHex("#F9FAFB"),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSharingSummaryCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildShareDocumentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Text(
          widget.document.documentName,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSharingSummaryCard() {
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
          Text('Sharing Summary', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildTextFieldRow('Document', '${widget.document.documentName}.pdf'),
          _buildDropdownRow('Method', _method, ['link', 'qr'], (val) => setState(() => _method = val!)),
           _buildDropdownRow('Protection', _method, ['link', 'qr'], (val) => setState(() => _protection = val!)),
          // if (_protection == 'Generate PIN') _buildTextFieldRow('PIN', '4832', controller: _pinController, isEditable: true),
          // _buildTextFieldRow('Shared With', _sharedWith, isEditable: true),
          _buildTextFieldRow('PIN', '${widget.document.pin}'),
          _buildTextFieldRow('Shared With', '${widget.document.documentName}'),
          _buildDateFieldRow('Expires On', _expiresOn, (date) => setState(() => _expiresOn = date)),

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
          Expanded(flex: 3,
              child: isEditable
                  ? TextFormField(initialValue: value, controller: controller, decoration: _inputDecoration(), style: GoogleFonts.inter(fontWeight: FontWeight.w600))
                  : Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600))
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
          Expanded(flex: 3,
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

  Widget _buildDateFieldRow(String label, DateTime value, ValueChanged<DateTime> onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600))),
          Expanded(flex: 3,
            child: InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(context: context, initialDate: value, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                if (pickedDate != null) onDateChanged(pickedDate);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('d MMM yyyy, hh:mm a').format(value), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Logic to save details
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save Details', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.fromHex("#5A48F5"),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12)
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () { print('Revoke link tapped'); },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Revoke Link', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareDocumentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () { print('Share document tapped'); },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorUtils.fromHex("#5A48F5").withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Share Document', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
