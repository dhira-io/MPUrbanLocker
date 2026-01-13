import 'dart:io';

import 'package:digilocker_flutter/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../components/common_appbar.dart';
import '../providers/shared_doc_list_provider.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';

class EditShareDetailsScreen extends StatefulWidget {
  final SharedDocModel document;

  const EditShareDetailsScreen({Key? key, required this.document})
    : super(key: key);

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
    print(widget.document.shareMethod);
    print(ShareOption.qr);
    _method = widget.document.shareMethod == ShareOption.qr.name
        ? "Secure QR"
        : "Secure Link";
    print(_method);

    _protection = widget.document.protectionType == ProtectionOption.pin.name
        ? "Generate PIN"
        : "WithOut PIN";
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
            _buildActionButtons(context),
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
        Flexible(
          child: Text(
            widget.document.documentName,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
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
          Text(
            'Sharing Summary',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextFieldRow('Document', '${widget.document.documentName}.pdf'),
          _buildDropdownRow('Method', _method, [
            "Secure QR",
            "Secure Link",
          ], (val) => setState(() => _method = val!)),
          _buildDropdownRow('Protection', _protection, [
            "Generate PIN",
            "WithOut PIN",
          ], (val) => setState(() => _protection = val!)),
          // if (_protection == 'Generate PIN') _buildTextFieldRow('PIN', '4832', controller: _pinController, isEditable: true),
          // _buildTextFieldRow('Shared With', _sharedWith, isEditable: true),
          _buildTextFieldRow('PIN', '${widget.document.pin}'),
          _buildTextFieldRow(
            'Shared With',
            '${widget.document.sharedWithName}',
          ),
          _buildDateFieldRow(
            'Expires On',
            _expiresOn,
            (date) => setState(() => _expiresOn = date),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(
    String label,
    String value, {
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditable
                ? TextFormField(
                    initialValue: value,
                    controller: controller,
                    decoration: _inputDecoration(),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  )
                : Text(
                    value,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: _inputDecoration(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFieldRow(
    String label,
    DateTime value,
    ValueChanged<DateTime> onDateChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () async {
                final DateTime lastDate = _expiresOn.add(
                  const Duration(days: 7),
                );
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: value,
                  firstDate: DateTime.now(),
                  lastDate: lastDate, //DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (pickedDate != null) onDateChanged(pickedDate);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('d MMM yyyy, hh:mm a').format(value),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorUtils.fromHex("#5A48F5")),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext ctx) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Logic to save details
              // Navigator.pop(context);
              print('${_method}');
              print('${_protection}');
              print('${_expiresOn}');
              apicall_edit_share(context, false);
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Save Details',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorUtils.fromHex("#5A48F5"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              print('Revoke link tapped');
              apicall_DeleteSharedDoc(ctx,widget.document.id);
            },
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text(
              'Revoke Link',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
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
        onPressed: () {
          print('Share document tapped');
          apicall_edit_share(context, true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorUtils.fromHex("#5A48F5").withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Share Document',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> apicall_edit_share(BuildContext context, bool isShare) async {

    String customExpiry = _expiresOn!.toUtc().toIso8601String();
    var reqBody = {
      "shareMethod": _method == "Secure QR" ? ShareOption.qr.name : ShareOption.link.name,
      "protectionType": _protection == "Generate PIN"
          ? ProtectionOption.pin.name
          : ProtectionOption.withoutPin.name.toLowerCase(),
       "expiresIn": "custom", //"24h",
       "customExpiry": customExpiry, //"2026-01-12T08:00:55.182Z",
       "sharedWithName": widget.document.sharedWithName,
      "canDownload" : widget.document.canDownload
    };
    print(reqBody);
    try {
      final apiService = context.read<ApiService>();
      final Map<String, dynamic> response = await apiService.putRequest(
        AppConstants.editShareDocumentEndpoint(widget.document.id),
        includeAuth: true,
        body: reqBody,
      );
      if (response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> responseData = response;
        ShareResponseModel model = ShareResponseModel.fromJson(
          responseData["data"],
        );
        if (isShare) {
          var result = null;
          if (model.qrCode != null) {
            File objFile = await DataToImageFile.base64ToImageFile(
              model.qrCode ?? "",
            );
            result = await SharePlus.instance.share(
              ShareParams(files: [XFile(objFile.path)]),
            );
          } else {
            result = await SharePlus.instance.share(
              ShareParams(text: model.shareUrl),
            );
          }
          // This executes AFTER share sheet is closed
          if (result.status == ShareResultStatus.success) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
          print("result ${result.status}");
        }else {
          print("messageeee${response["message"]}");
          String errorMessage = response['message'] ?? 'Something went wrong';
          Fluttertoast.showToast(msg: errorMessage);
          Navigator.of(context).pop();
        }
      } else {
        String errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: errorMessage);
      }
    } on NoInternetException catch (e) {
      Fluttertoast.showToast(msg: '${e.toString()}');
    } catch (e) {
      debugPrint('Fetch Error: $e');
      Fluttertoast.showToast(msg: '${e.toString()}');
    } finally {
      // _isLoading = false;
      // notifyListeners();
    }
  }

  Future<void> apicall_DeleteSharedDoc(
      BuildContext context,
      String id,
      ) async {
    print("calll");
   // isLoading = true;
   // notifyListeners();

    try {
      final apiService = context.read<ApiService>();

      final response = await apiService.deleteRequest(
        AppConstants.deleteShareEndpoint(id),
        includeAuth: true,
      );

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: response["message"] ?? "");
        Navigator.of(context).pop();
      } else {
      String  errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: errorMessage);
      }
    } catch (e) {
      debugPrint('Delete Error: $e');
      Fluttertoast.showToast(msg: e.toString());
    } finally {
     // isLoading = false;
      //notifyListeners();
    }
  }
}
