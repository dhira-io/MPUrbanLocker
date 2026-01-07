import 'package:carousel_slider/carousel_slider.dart';
import 'package:digilocker_flutter/components/common_appbar.dart';
import 'package:digilocker_flutter/screens/FAQScreen.dart';
import 'package:digilocker_flutter/screens/PrivacyPolicyScreen.dart';
import 'package:digilocker_flutter/screens/login_screen.dart';
import 'package:digilocker_flutter/screens/webview_auth_screen.dart';
import 'package:digilocker_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';
import '../utils/color_utils.dart';

// --- REUSABLE WIDGETS ---
// Statistic Card Component
class StatisticCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatisticCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, size: 28, color: iconColor),
              ),

              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ColorUtils.fromHex("#1F2937"),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: ColorUtils.fromHex("#4B5563")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Document/Department Card Component
class CategoryCard extends StatelessWidget {
  final Image image;
  final String title;
  final Color bgColor;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.image,
    required this.title,
    required this.bgColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 160,
        // Fixed width for horizontal scroll
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: bgColor,
              child: image,
            ),

            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,color: ColorUtils.fromHex("#4B5563")),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5)
          ],
        ),
      ),
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final Image image;
  final Color iconColor;
  final String title;
  final VoidCallback? onTap;

  const DepartmentCard({
    required this.image,
    required this.iconColor,
    required this.title,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Assign the callback
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(width: 35, height: 35, child: image),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600,color: ColorUtils.fromHex("#374151")),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen_old extends StatefulWidget {
  const DashboardScreen_old({super.key});

  @override
  _DashboardScreen_oldState createState() => _DashboardScreen_oldState();
}

class _DashboardScreen_oldState extends State<DashboardScreen_old> {
  bool _isNavigating = false; // Prevent multiple rapid clicks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView(
        children: [
          _buildSearchBar(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildBanner(context, ''),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader(title: 'Documents you might need'),
          _buildDocumentsList(context),
          const SizedBox(height: 20),

          _buildSectionHeader(title: 'State-wide statistics'),
          _buildStatisticsRow(context),
          const SizedBox(height: 20),

          _buildSectionHeader(title: 'Departments'),
          _buildDepartmentsGrid(),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildBanner(context, 'New in MP Urban Locker'),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader(title: 'About MP Urban Locker'),
          _buildAboutButtonsRow(context),

          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
          child: ElevatedButton(
            onPressed: _isNavigating ? null : () => _navigateToDigiLockerAuth(context, 'get started'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF613AF5),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: _isNavigating
                ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Text(
              'Get Started',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: ColorUtils.fromHex("#FFFFFF"),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      endDrawer: customEndDrawer(context),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: ColorUtils.fromHex("#212121")),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400]!),
              color: Colors.blue[50],
            ),
            child: Image.asset('assets/s_icon.png'),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.mic, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600))),
          GestureDetector(
            onTap: () {},
            child: Text(
              'View All',
              style: GoogleFonts.inter(fontSize: 14, color: ColorUtils.fromHex("#613AF5")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String title) {
    final provider = Provider.of<OnboardingProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        CarouselSlider.builder(
          itemCount: AppConstants.appSlides.length,
          options: CarouselOptions(
            height: 150,
            enlargeCenterPage: true,
            viewportFraction: (screenWidth - 10) / screenWidth,
            autoPlay: true,
          ),
          itemBuilder: (context, index, realIndex) {
            final slide = AppConstants.appSlides[index];
            return SizedBox(
              width: screenWidth - 40,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(slide["image"]!, fit: BoxFit.fitHeight),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocumentsList(context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: ConfigService.docServices.map((docConfig) {
          return CategoryCard(
            image: Image.asset(docConfig.imagePath),
            title: docConfig.displayName,
            bgColor: docConfig.bgcolor,
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, docConfig.displayName),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatisticsRow(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          StatisticCard(
            value: '5.2M+',
            label: 'Documents Issued',
            icon: Icons.description,
            iconColor: Colors.blueAccent,
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, "Documents Issued"),
          ),
          StatisticCard(
            value: '120+',
            label: 'Departments Live',
            icon: Icons.apartment,
            iconColor: Colors.green,
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, "Departments Live"),
          ),
          StatisticCard(
            value: '1K+',
            label: 'Verified Citizens',
            icon: Icons.person,
            iconColor: Colors.purple,
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, "Verified Citizens"),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DepartmentCard(
                  image: Image.asset('assets/appartment.png'),
                  iconColor: const Color(0xFF673AB7),
                  title: 'Urban Admin & Development',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutButtonsRow(context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildPillButton(Icons.help_outline, 'FAQ', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()));
          }),
          _buildPillButton(Icons.lock_outline, 'Privacy', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildPillButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: ColorUtils.fromHex("#613AF5")),
            const SizedBox(width: 6),
            Text(text, style: GoogleFonts.inter(color: ColorUtils.fromHex("#613AF5"), fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDigiLockerAuth(
      BuildContext context,
      String documentType,
      ) async {

    bool internet_status = await CheckInternet.isInternetAvailable();
    if (internet_status == false) {
      CheckInternet.showNoInternetToast();
      return;
    }

    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    SharedPreferences pref = await SharedPreferences.getInstance();
    bool in_store_review = pref.getBool("in_store_review") ?? false;

    if (in_store_review == true) {
      await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      final authProvider = context.read<AuthProvider>();
      final session = await authProvider.startOAuthFlow(useMobileRedirect: false);

      if (session != null && context.mounted) {
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewAuthScreen(
              authorizationUrl: session.authorizationUrl,
              state: session.state,
            ),
          ),
        );
      }
    }

    if (mounted) setState(() => _isNavigating = false);
  }
}
