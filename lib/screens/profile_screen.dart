import 'dart:convert';

import 'package:digilocker_flutter/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as _client;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import 'combine_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userId = '';
  String _name = '';
  String _mobile = '';
  String _gender = '';
  String _userDOB = '';

  String? _profileImageUrl; // nullable
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }
  getUserProfile() async {
    final pref = await SharedPreferences.getInstance();
    final storedUserId = await pref.getString(AppConstants.userIdKey) ?? '';
    final apiService = context.read<ApiService>();
    try {
      Map<String, dynamic> response = await apiService.getProfileInfo(
          storedUserId);

      if (response['success'] != true) {
        debugPrint("❌ API returned success=false");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${response['message']} ${response['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        });
        return;
      }

      if (response['data'] == null) {
        debugPrint("❌ Document missing in response");
        return;
      }

      final User objUser = User.fromJson(
        response['data']["user"] as Map<String, dynamic>,
      );
      if (mounted) { //userId,username,mobile,gender
        setState(() {
          _userId = objUser.id ?? 'N/A';
          _name = objUser.name ?? '--';
          _mobile = objUser.mobile ?? '+91 ******4321';
          _gender = objUser.gender ?? 'N/A';
          _userDOB = objUser.dob ?? '';
          //_profileImageUrl =  prefs.getString('profileImage'); // may be null
          _isLoggedIn = objUser.id != null ? true : false;
          _isLoading = false;
        });
      }
    } on NoInternetException catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "${e.toString()}");
    } on Exception catch (e){
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileHeader(),
            const SizedBox(height: 24),

            Text(
                "Profile Information",
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorUtils.fromHex("#1F2937")
                )
            ),
            const SizedBox(height: 12),
            _profileInfoCard(),

            const SizedBox(height: 24),
            Text(
              "Account Actions",
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.fromHex("#1F2937")
              ),
            ),
            const SizedBox(height: 12),
            _actionInfoCard(),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF5639CC), Color(0xff6C47FF),],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _profileAvatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.fromHex("#FFFFFF")
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Verified via Aadhaar",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorUtils.fromHex("#FFFFFF")
                  ),
                ),
              ],
            ),
          ),
          Image.asset('assets/prosheild.png', width: 80, height: 80,color: Colors.white24,),
        ],
      ),
    );
  }

  // ================= PROFILE AVATAR =================

  Widget _profileAvatar() {
    final bool hasImage =
        _profileImageUrl != null && _profileImageUrl!.isNotEmpty;

    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: hasImage
              ? NetworkImage(_profileImageUrl!)
              : const AssetImage("assets/profile.jpg")
          as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 9,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.check_circle,
              size: 16,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  // ================= PROFILE INFO CARD =================

  Widget _profileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.person,
            iconColor: ColorUtils.fromHex("#613AF5"),
            iconBg: ColorUtils.fromHex("#EBE5FF"),
            title: "Date Of Birth",
            value: _formatDob(_userDOB),
            subtitle: "From Aadhaar (read-only)",
          ),
          Divider(color: Color(0xffF3F4F6)),
          _infoRow(
            icon: Icons.phone_android,
            iconColor: ColorUtils.fromHex("#613AF5"),
            iconBg: ColorUtils.fromHex("#EBE5FF"),
            title: "Registered Mobile",
            value: _mobile,
            subtitle: "Verified & secured",
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String subtitle,
    //Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.fromHex("#4B5563")
                ),),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorUtils.fromHex("#1F2937")
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorUtils.fromHex("#6B7280")
                  ),
                ),
              ],
            ),
          ),
          // if (trailing != null) trailing,
        ],
      ),
    );
  }
//Account actions

  Widget _actionInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _actionTile(
            icon:  Image.asset('assets/lock.png'),
            iconColor: ColorUtils.fromHex("#613AF5"),
            iconBg: ColorUtils.fromHex("#EBE5FF"),
            title: "Reset Security / Login PIN",
            subtitle: "Change your MP Locker PIN",
            onTap: _onResetPin,
          ),
          Divider(color: Color(0xffF3F4F6)),
          _actionTile(
            icon: Image.asset('assets/group.png'),
            iconColor: ColorUtils.fromHex("#613AF5"),
            iconBg: ColorUtils.fromHex("#EBE5FF"),
            title: "Switch Account",
            subtitle: "Change linked user account",
            onTap: _onSwitchAccount,
          ),
          Divider(color: Color(0xffF3F4F6)),
          _actionTile(
            icon: Image.asset('assets/logout.png'),
            iconColor: ColorUtils.fromHex("#613AF5"),
            iconBg: ColorUtils.fromHex("#EBE5FF"),
            title: "Logout",
            subtitle: "Sign out securely from this device",
            onTap: _onLogout,
          ),
        ],
      ),
    );
  }

  // ================= ACTION TILES =================


  Widget _actionTile({
    required Image icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBg,
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ColorUtils.fromHex("#1F2937")
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorUtils.fromHex("#4B5563")
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,color: ColorUtils.fromHex("#E5E7EB"),size: 26,fontWeight: FontWeight.w600,),
          ],
        ),
      ),
    );
  }


  // ================= ACTIONS =================

  void _onResetPin() {}

  void _onSwitchAccount() {}
  // ================= HELPERS =================

  String _formatDob(String? dob) {
    if (dob == null || dob.isEmpty) return 'N/A';

    // Backend sends: 21091994
    if (dob.length == 8) {
      return '${dob.substring(0, 2)}-'
          '${dob.substring(2, 4)}-'
          '${dob.substring(4)}';
    }
    return dob;
  }
  Future<void> _onLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final authProvider = AuthProvider();
    await authProvider.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CombinedDashboard(isLoggedIn: false),
      ),
    );
  }

}

