
import 'package:flutter/material.dart' hide DateUtils;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/common_appbar.dart';
import '../providers/share_provider.dart';
import '../utils/DateUtils.dart';
import '../utils/color_utils.dart';

class ShareScreen extends StatelessWidget {
  final String documentTitle;
  final String documentId;

  const ShareScreen({
    Key? key,
    required this.documentTitle,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShareProvider(),
      child: Consumer<ShareProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: ColorUtils.fromHex("#F9FAFB"),
            appBar: CustomAppBar(),
            endDrawer: customEndDrawer(context),
            body: Column(
              children: [
                _buildHeader(context, provider),
                if (!provider.isFlowComplete) _buildStepper(provider),
                Expanded(child: _buildContent(context, provider)),
                _buildContinueButton(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ShareProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (provider.isFlowComplete) {
                provider.setFlowComplete(false);
              } else if (provider.currentStep == 0) {
                Navigator.of(context).pop();
              } else {
                provider.setCurrentStep(provider.currentStep - 1);
              }
            },
          ),
          Expanded(
            child: Text(
              documentTitle,
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

  Widget _buildStepper(ShareProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStep(provider, index: 0, label: 'Generate\nLink/QR'),
          _buildStep(provider, index: 1, label: 'Set\nProtection'),
          _buildStep(provider, index: 2, label: 'Set\nDuration'),
        ],
      ),
    );
  }

  Widget _buildStep(ShareProvider provider, {required int index, required String label}) {
    bool isCompleted = index < provider.currentStep;
    bool isActive = index == provider.currentStep;
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
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          )
              : isActive
              ? CircularProgressIndicator(
            value: 0.75,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              ColorUtils.fromHex("#1DBF73"),
            ),
            backgroundColor: Colors.grey.shade300,
          )
              : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
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
            color: (isActive || isCompleted) ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ShareProvider provider) {
    if (provider.isFlowComplete) {
      return _buildSummaryStep(provider);
    }

    switch (provider.currentStep) {
      case 0:
        return _buildGenerateStep(provider);
      case 1:
        return _buildProtectionStep(provider);
      case 2:
        return _buildDurationStep(context, provider);
      default:
        return Container();
    }
  }

  Widget _buildGenerateStep(ShareProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Document',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to share this document securely.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildShareOptionCard(
            provider,
            icon: Icons.link,
            title: 'Generate Link',
            subtitle: 'Create a secure, shareable link for this document.',
            option: ShareOption.link,
          ),
          const SizedBox(height: 16),
          _buildShareOptionCard(
            provider,
            icon: Icons.qr_code,
            title: 'Generate QR Code',
            subtitle: 'Generate a QR code that can be scanned to access the document.',
            option: ShareOption.qr,
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionStep(ShareProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Access Protection',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how the recipient should access this document.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildProtectionOptionCard(
            provider,
            icon: Icons.phone_android_outlined,
            title: 'Generate PIN',
            subtitle: 'You will receive a PIN on your registered mobile number.',
            option: ProtectionOption.pin,
          ),
          const SizedBox(height: 16),
          _buildProtectionOptionCard(
            provider,
            icon: Icons.lock_open_outlined,
            title: 'Share Without PIN',
            subtitle: 'Anyone with the link or QR can access the document.',
            option: ProtectionOption.withoutPin,
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

  Widget _buildDurationStep(BuildContext context, ShareProvider provider) {
    final String customLabel;
    if (provider.customExpiryDate != null) {
      customLabel = DateFormat('EEE, MMM d').format(provider.customExpiryDate!);
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
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how long this document should remain accessible.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
                      provider,
                      '15 minutes',
                      DurationOption.fifteenMin,
                    ),
                    _buildDurationButton(provider, '1 hour', DurationOption.oneHour),
                    _buildDurationButton(
                      provider,
                      '24 hours',
                      DurationOption.twentyFourHours,
                    ),
                    _buildCustomDurationButton(context, provider, customLabel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoBox(
            icon: Icons.info_outline,
            text: 'After expiry, the document cannot be accessed by anyone using the shared link or QR code.',
            isBlue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(ShareProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorUtils.fromHex("#1DBF73"),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Your secure shareable item has been generated.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          _buildSharingSummaryCard(provider),
          const SizedBox(height: 24),
          _buildShareWithInput(provider),
        ],
      ),
    );
  }

  Widget _buildShareOptionCard(
      ShareProvider provider,
      {
        required IconData icon,
        required String title,
        required String subtitle,
        required ShareOption option,
      }) {
    bool isSelected = provider.selectedOption == option;
    return GestureDetector(
      onTap: () => provider.setSelectedOption(option),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorUtils.fromHex("#5A48F5") : Colors.grey.shade200,
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
              child: Icon(icon, color: ColorUtils.fromHex("#5A48F5"), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionOptionCard(
      ShareProvider provider,
      {
        required IconData icon,
        required String title,
        required String subtitle,
        required ProtectionOption option,
      }) {
    bool isSelected = provider.selectedProtectionOption == option;
    return GestureDetector(
      onTap: () => provider.setSelectedProtectionOption(option),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorUtils.fromHex("#5A48F5") : Colors.grey.shade200,
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
              child: Icon(icon, color: ColorUtils.fromHex("#5A48F5"), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButton(ShareProvider provider, String label, DurationOption option) {
    bool isSelected = provider.selectedDurationOption == option;
    return ElevatedButton(
      onPressed: () => provider.setSelectedDurationOption(option),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? ColorUtils.fromHex("#EEF2FF") : Colors.grey.shade100,
        foregroundColor: isSelected ? ColorUtils.fromHex("#4F46E5") : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? ColorUtils.fromHex("#5A48F5") : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildCustomDurationButton(BuildContext context, ShareProvider provider, String label) {
    bool isSelected = provider.selectedDurationOption == DurationOption.custom;

    return ElevatedButton(
      onPressed: () async {
        final now = DateTime.now();
        final DateTime firstDate = DateTime(now.year, now.month, now.day);
        final DateTime lastDate = firstDate.add(const Duration(days: 7));

        final picked = await showDatePicker(
          context: context,
          initialDate: provider.customExpiryDate ?? firstDate,
          firstDate: firstDate,
          lastDate: lastDate,
          helpText: 'Select date',
        );

        if (picked != null) {
          provider.setCustomExpiryDate(picked);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? ColorUtils.fromHex("#EEF2FF") : Colors.grey.shade100,
        foregroundColor: isSelected ? ColorUtils.fromHex("#4F46E5") : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? ColorUtils.fromHex("#5A48F5") : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildSharingSummaryCard(ShareProvider provider) {
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
          _buildSummaryRow('Document', '$documentTitle.pdf'),
          _buildSummaryRow(
            'Method',
            _getShareOptionString(provider.selectedOption),
            icon: Icons.link,
          ),
          _buildSummaryRow(
            'Protection',
            _getProtectionOptionString(provider.selectedProtectionOption),
            icon: Icons.lock_outline,
          ),
          provider.objShareResponse != null
              ? _buildSummaryRow('PIN', provider.objShareResponse?.pin ?? '')
              : Text(''),
          _buildSummaryRow(
            'Permission',
            _getPermissionOptionString(provider.selectedPermissionOption),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Expires On',
            DateUtils.formatDate(provider.objShareResponse?.expiresAt ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareWithInput(ShareProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Document With',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: provider.shareWithController,
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
              borderSide: BorderSide(color: ColorUtils.fromHex("#5A48F5")),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${provider.shareWithController.text.length}/50',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  String _getShareOptionString(ShareOption? option) {
    return option == ShareOption.link ? 'Secure Link' : 'QR Code';
  }

  String _getProtectionOptionString(ProtectionOption? option) {
    return option == ProtectionOption.pin ? 'Generate PIN' : 'Without PIN';
  }

  String _getPermissionOptionString(PermissionOption? option) {
    return 'View & Download';
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String text,
    bool isBlue = false,
  }) {
    final Color bgColor = isBlue ? ColorUtils.fromHex("#EFF6FF") : ColorUtils.fromHex("#EEF2FF");
    final Color iconColor = isBlue ? ColorUtils.fromHex("#3B82F6") : ColorUtils.fromHex("#5A48F5");
    final Color textColor = isBlue ? ColorUtils.fromHex("#1E40AF") : ColorUtils.fromHex("#4F46E5");
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, ShareProvider provider) {
    if (provider.isFlowComplete) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.shareWithController.text.isNotEmpty
                ? () {
              provider.isLoading ? null : provider.apicall_put_shareWithName(context);
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorUtils.fromHex("#5A48F5"),
              disabledBackgroundColor: ColorUtils.fromHex("#5A48F5").withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isLoading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ) : Text(
              'Share Document',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    bool canContinue = (provider.currentStep == 0 && provider.selectedOption != null) ||
        (provider.currentStep == 1 && provider.selectedProtectionOption != null) ||
        (provider.currentStep == 2 && provider.selectedDurationOption != null);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canContinue
              ? () {
            if (provider.currentStep < 2) {
              provider.setCurrentStep(provider.currentStep + 1);
            } else {
              provider.isLoading  ? null :  provider.apicall_shareIDGenerate(context, documentId);
            }
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorUtils.fromHex("#5A48F5"),
            disabledBackgroundColor: const Color.fromRGBO(160, 148, 245, 0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: provider.isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ) : Text(
            'Continue',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
