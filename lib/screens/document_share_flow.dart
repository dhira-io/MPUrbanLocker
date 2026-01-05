import 'package:flutter/material.dart';

class DocumentShareFlow extends StatefulWidget {
  const DocumentShareFlow({super.key});

  @override
  State<DocumentShareFlow> createState() => _DocumentShareFlowState();
}

class _DocumentShareFlowState extends State<DocumentShareFlow> {
  int currentStep = 0;

  bool otpProtected = true;
  int validityIndex = 0;
  int permissionIndex = 0;

  final List<String> steps = [
    'Generate\nLink / QR',
    'Set\nProtection',
    'Set\nDuration',
    'Set\nPermissions',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Driving License'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _stepIndicator(),
          const SizedBox(height: 16),
          Expanded(child: _stepContent()),
          _continueButton(),
        ],
      ),
    );
  }

  /// 🔹 Step Indicator
  Widget _stepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isDone = index < currentStep;
          final isActive = index == currentStep;

          return Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isDone || isActive
                    ? Colors.green
                    : Colors.grey.shade300,
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isActive
                    ? const CircleAvatar(radius: 4, backgroundColor: Colors.white)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// 🔹 Step Content Switch
  Widget _stepContent() {
    switch (currentStep) {
      case 0:
        return _generateLinkStep();
      case 1:
        return _protectionStep();
      case 2:
        return _durationStep();
      case 3:
        return _permissionStep();
      default:
        return const SizedBox();
    }
  }

  /// 🟣 Step 1: Generate Link / QR
  Widget _generateLinkStep() {
    return _cardColumn([
      _optionCard(
        title: 'Generate Link',
        subtitle: 'Create a secure, shareable link',
        selected: true,
      ),
      _optionCard(
        title: 'Generate QR Code',
        subtitle: 'Scan QR code to access',
      ),
    ]);
  }

  /// 🔐 Step 2: Protection
  Widget _protectionStep() {
    return _cardColumn([
      _optionCard(
        title: 'OTP Protected',
        subtitle: 'Recipient receives one-time password',
        selected: otpProtected,
        onTap: () => setState(() => otpProtected = true),
      ),
      _optionCard(
        title: 'Without OTP',
        subtitle: 'Anyone with link can access',
        selected: !otpProtected,
        onTap: () => setState(() => otpProtected = false),
      ),
    ]);
  }

  /// ⏱ Step 3: Duration
  Widget _durationStep() {
    final durations = ['15 minutes', '1 hour', '24 hours', 'Custom'];

    return _cardColumn([
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(durations.length, (index) {
          return ChoiceChip(
            label: Text(durations[index]),
            selected: validityIndex == index,
            onSelected: (_) => setState(() => validityIndex = index),
          );
        }),
      ),
      const SizedBox(height: 12),
      const Text(
        'After expiry, document cannot be accessed.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ]);
  }

  /// 👁 Step 4: Permissions
  Widget _permissionStep() {
    return _cardColumn([
      _optionCard(
        title: 'View Only',
        subtitle: 'Recipient can only view',
        selected: permissionIndex == 0,
        onTap: () => setState(() => permissionIndex = 0),
      ),
      _optionCard(
        title: 'View & Download',
        subtitle: 'Recipient can download copy',
        selected: permissionIndex == 1,
        onTap: () => setState(() => permissionIndex = 1),
      ),
    ]);
  }

  /// 🔘 Continue Button
  Widget _continueButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (currentStep < 3) {
              setState(() => currentStep++);
            } else {
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A48F5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  /// 🔹 Common UI Helpers
  Widget _optionCard({
    required String title,
    required String subtitle,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.deepPurple : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.deepPurple : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardColumn(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
