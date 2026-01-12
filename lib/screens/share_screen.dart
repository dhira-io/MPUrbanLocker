import 'package:digilocker_flutter/screens/shared_doc_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../components/common_appbar.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';

class ShareScreen extends StatefulWidget {
  final String documentTitle;
  final String documentId;

  const ShareScreen({Key? key, required this.documentTitle,required this.documentId}) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

enum ShareOption { link, qr }
enum ProtectionOption { otp, withoutOtp }
enum DurationOption { fifteenMin, oneHour, twentyFourHours, custom }
enum PermissionOption { viewOnly, viewAndDownload }

class _ShareScreenState extends State<ShareScreen> {
  int _currentStep = 0;
  bool _isFlowComplete = false;

  ShareOption? _selectedOption;
  ProtectionOption? _selectedProtectionOption;
  DurationOption? _selectedDurationOption;
  PermissionOption? _selectedPermissionOption;

  final TextEditingController _shareWithController = TextEditingController();

  // single custom expiry date (max 7 days from now)
  DateTime? _customExpiryDate;

  @override
  void initState() {
    super.initState();
    _shareWithController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _shareWithController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.fromHex("#F9FAFB"),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: Column(
        children: [
          _buildHeader(),
          if (!_isFlowComplete) _buildStepper(),
          Expanded(
            child: _buildContent(),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_isFlowComplete) {
                setState(() {
                  _isFlowComplete = false;
                });
              } else if (_currentStep == 0) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _currentStep--;
                });
              }
            },
          ),
          Expanded(
            child: Text(
              widget.documentTitle,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStep(index: 0, label: 'Generate\nLink/QR'),
          _buildStep(index: 1, label: 'Set\nProtection'),
          _buildStep(index: 2, label: 'Set\nDuration'),
          _buildStep(index: 3, label: 'Set\nPermissions'),
        ],
      ),
    );
  }

  Widget _buildStep({required int index, required String label}) {
    bool isCompleted = index < _currentStep;
    bool isActive = index == _currentStep;
    return Column(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: isCompleted
              ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorUtils.fromHex("#1DBF73"),
            ),
            child: const Icon(Icons.check,
                color: Colors.white, size: 16),
          )
              : isActive
              ? CircularProgressIndicator(
            value: 0.75,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
                ColorUtils.fromHex("#1DBF73")),
            backgroundColor: Colors.grey.shade300,
          )
              : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color:
            (isActive || isCompleted) ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isFlowComplete) {
      return _buildSummaryStep();
    }

    switch (_currentStep) {
      case 0:
        return _buildGenerateStep();
      case 1:
        return _buildProtectionStep();
      case 2:
        return _buildDurationStep();
      case 3:
        return _buildPermissionsStep();
      default:
        return Container();
    }
  }

  // ---------- STEP 0 ----------
  Widget _buildGenerateStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Document',
            style:
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to share this document securely.',
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildShareOptionCard(
            icon: Icons.link,
            title: 'Generate Link',
            subtitle: 'Create a secure, shareable link for this document.',
            option: ShareOption.link,
          ),
          const SizedBox(height: 16),
          _buildShareOptionCard(
            icon: Icons.qr_code,
            title: 'Generate QR Code',
            subtitle:
            'Generate a QR code that can be scanned to access the document.',
            option: ShareOption.qr,
          ),
        ],
      ),
    );
  }

  // ---------- STEP 1 ----------
  Widget _buildProtectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Access Protection',
            style:
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how the recipient should access this document.',
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildProtectionOptionCard(
            icon: Icons.phone_android_outlined,
            title: 'OTP Protected',
            subtitle: 'Recipient will receive a one-time password.',
            option: ProtectionOption.otp,
          ),
          const SizedBox(height: 16),
          _buildProtectionOptionCard(
            icon: Icons.lock_open_outlined,
            title: 'Without OTP',
            subtitle:
            'Anyone with the link or QR can access the document.',
            option: ProtectionOption.withoutOtp,
          ),
          const SizedBox(height: 24),
          _buildInfoBox(
            icon: Icons.shield_outlined,
            text: 'You can change or revoke access anytime.',
          ),
        ],
      ),
    );
  }

  // ---------- STEP 2 (UPDATED) ----------
  Widget _buildDurationStep() {
    final String customLabel;
    if (_customExpiryDate != null) {
      customLabel = DateFormat('EEE, MMM d').format(_customExpiryDate!);
    } else {
      customLabel = 'Custom';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Access Duration',
            style:
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how long this document should remain accessible.',
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Container(
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
                  'Document Access Validity',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildDurationButton(
                        '15 minutes', DurationOption.fifteenMin),
                    _buildDurationButton(
                        '1 hour', DurationOption.oneHour),
                    _buildDurationButton(
                        '24 hours', DurationOption.twentyFourHours),
                    _buildCustomDurationButton(customLabel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoBox(
            icon: Icons.info_outline,
            text:
            'After expiry, the document cannot be accessed by anyone using the shared link or QR code.',
            isBlue: true,
          ),
        ],
      ),
    );
  }

  // ---------- STEP 3 ----------
  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Access Permissions',
            style:
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose what the recipient is allowed to do.',
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildPermissionOptionCard(
            icon: Icons.visibility_outlined,
            title: 'View Only',
            subtitle: 'Recipient can only view the document.',
            option: PermissionOption.viewOnly,
          ),
          const SizedBox(height: 16),
          _buildPermissionOptionCard(
            icon: Icons.download_outlined,
            title: 'View & Download',
            subtitle: 'Recipient can download a copy of the document.',
            option: PermissionOption.viewAndDownload,
          ),
          const SizedBox(height: 24),
          _buildInfoBox(
            icon: Icons.shield_outlined,
            text:
            'Downloaded files are encrypted and watermarked for security.',
          ),
        ],
      ),
    );
  }

  // ---------- SUMMARY STEP ----------
  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding:
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorUtils.fromHex("#1DBF73"),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your secure shareable item has been generated.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildSharingSummaryCard(),
          const SizedBox(height: 24),
          _buildShareWithInput(),
        ],
      ),
    );
  }

  Widget _buildShareOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required ShareOption option,
  }) {
    bool isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = option),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorUtils.fromHex("#5A48F5")
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorUtils.fromHex("#EEF2FF"),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: ColorUtils.fromHex("#5A48F5"), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required ProtectionOption option,
  }) {
    bool isSelected = _selectedProtectionOption == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedProtectionOption = option),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorUtils.fromHex("#5A48F5")
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorUtils.fromHex("#EEF2FF"),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: ColorUtils.fromHex("#5A48F5"), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- DURATION BUTTONS ----------
  Widget _buildDurationButton(String label, DurationOption option) {
    bool isSelected = _selectedDurationOption == option;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDurationOption = option;
          if (option != DurationOption.custom) {
            _customExpiryDate = null;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
        isSelected ? ColorUtils.fromHex("#EEF2FF") : Colors.grey.shade100,
        foregroundColor:
        isSelected ? ColorUtils.fromHex("#4F46E5") : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? ColorUtils.fromHex("#5A48F5")
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  // custom duration button with single date picker (max 7 days)
  Widget _buildCustomDurationButton(String label) {
    bool isSelected = _selectedDurationOption == DurationOption.custom;

    return ElevatedButton(
      onPressed: () async {
        final now = DateTime.now();
        final DateTime firstDate =
        DateTime(now.year, now.month, now.day); // today (no time)
        final DateTime lastDate =
        firstDate.add(const Duration(days: 7)); // max +7 days

        final picked = await showDatePicker(
          context: context,
          initialDate: _customExpiryDate ?? firstDate,
          firstDate: firstDate,
          lastDate: lastDate,
          helpText: 'Select date',
        );

        if (picked != null) {
          setState(() {
            _selectedDurationOption = DurationOption.custom;
            _customExpiryDate = picked;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
        isSelected ? ColorUtils.fromHex("#EEF2FF") : Colors.grey.shade100,
        foregroundColor:
        isSelected ? ColorUtils.fromHex("#4F46E5") : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? ColorUtils.fromHex("#5A48F5")
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  // ---------- PERMISSION BUTTON ----------
  Widget _buildPermissionOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionOption option,
  }) {
    bool isSelected = _selectedPermissionOption == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedPermissionOption = option),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorUtils.fromHex("#5A48F5")
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorUtils.fromHex("#EEF2FF"),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: ColorUtils.fromHex("#5A48F5"), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- SUMMARY HELPERS ----------
  Widget _buildSharingSummaryCard() {
    String expiresOn;
    if (_selectedDurationOption == DurationOption.custom &&
        _customExpiryDate != null) {
      expiresOn = DateFormat('d MMM yyyy, hh:mm a').format(_customExpiryDate!);
    } else {
      // fallback: fixed expiration for non-custom selections
      expiresOn = DateFormat('d MMM yyyy, hh:mm a')
          .format(DateTime.now().add(const Duration(days: 2)));
    }

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
          Text('Sharing Summary',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildSummaryRow('Document', '${widget.documentTitle}.pdf'),
          _buildSummaryRow('Method', _getShareOptionString(_selectedOption),
              icon: Icons.link),
          _buildSummaryRow(
              'Protection',
              _getProtectionOptionString(_selectedProtectionOption),
              icon: Icons.lock_outline),
          _buildSummaryRow(
              'Permission', _getPermissionOptionString(_selectedPermissionOption)),
          const Divider(height: 24),
          _buildSummaryRow('Expires On', expiresOn),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.grey.shade600)),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
              ],
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareWithInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share Document With',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          controller: _shareWithController,
          maxLength: 50,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter the name',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: ColorUtils.fromHex("#5A48F5")),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_shareWithController.text.length}/50',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  // ---------- ENUM STRING HELPERS ----------
  String _getShareOptionString(ShareOption? option) {
    return option == ShareOption.link ? 'Secure Link' : 'QR Code';
  }

  String _getProtectionOptionString(ProtectionOption? option) {
    return option == ProtectionOption.otp ? 'OTP Protected' : 'Without OTP';
  }

  String _getPermissionOptionString(PermissionOption? option) {
    return option == PermissionOption.viewAndDownload
        ? 'View & Download'
        : 'View Only';
  }

  // ---------- COMMON WIDGETS ----------
  Widget _buildInfoBox(
      {required IconData icon,
        required String text,
        bool isBlue = false}) {
    final Color bgColor = isBlue
        ? ColorUtils.fromHex("#EFF6FF")
        : ColorUtils.fromHex("#EEF2FF");
    final Color iconColor =
    isBlue ? ColorUtils.fromHex("#3B82F6") : ColorUtils.fromHex("#5A48F5");
    final Color textColor =
    isBlue ? ColorUtils.fromHex("#1E40AF") : ColorUtils.fromHex("#4F46E5");
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    if (_isFlowComplete) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _shareWithController.text.isNotEmpty
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SharedDocListScreen(),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorUtils.fromHex("#5A48F5"),
              disabledBackgroundColor:
              ColorUtils.fromHex("#5A48F5").withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Share Document',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
      );
    }

    bool canContinue =
        (_currentStep == 0 && _selectedOption != null) ||
            (_currentStep == 1 && _selectedProtectionOption != null) ||
            (_currentStep == 2 && _selectedDurationOption != null) ||
            (_currentStep == 3 && _selectedPermissionOption != null);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canContinue
              ? () {
            setState(() {
              if (_currentStep < 3) {
                _currentStep++;
              } else {
                _isFlowComplete = true;
              }
            });
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorUtils.fromHex("#5A48F5"),
            disabledBackgroundColor:
            const Color.fromRGBO(160, 148, 245, 0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Continue',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> fetchSchemes(BuildContext context) async {
    // _isLoading = true;
    // _errorMessage = '';
    // notifyListeners();

    try {
      final apiService = context.read<ApiService>();

      final Map<String, dynamic> response = await apiService.getRequest(
        AppConstants.shareDocumentEndpoint(widget.documentId),
        includeAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> decodedData = response;
        print(decodedData);
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

}
