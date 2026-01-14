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
import '../models/doc_service_config.dart';
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
  final Widget image;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatisticCard({
    required this.value,
    required this.label,
    required this.image,
    required this.iconColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withOpacity(0.15),
                child: image,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4B5563),
                ),
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
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        alignment: Alignment.center,
        width: 140,
        height: 140,
        // Fixed width for horizontal scroll
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        //padding: const EdgeInsets.all(12.0),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding:  EdgeInsets.only(bottom: 8),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: bgColor,
                    child: image,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.fromHex("#4B5563"),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // const SizedBox(height: 10),
            // CircleAvatar(radius: 28, backgroundColor: bgColor, child: image),
            // const SizedBox(height: 4),
            // Text(
            //   title,
            //   textAlign: TextAlign.center,
            //   style: GoogleFonts.inter(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w600,
            //     color: ColorUtils.fromHex("#4B5563"),
            //   ),
            //   maxLines: 3,
            //   overflow: TextOverflow.ellipsis,
            // ),
            // const SizedBox(height: 10),
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
  // --- Search functionality ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // To track search bar focus
  List<DocServiceConfig> _filteredServices = [];


  Widget _buildMainContent() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildBanner(context, ''),
        ),

        const SizedBox(height: 20),

        _buildSectionHeader(title: 'Documents you might need'),
        _buildDocumentsList(context),

        //  _buildSectionHeader(title: 'State-wide statistics'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "State-wide statistics",
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        _buildStatisticsRow(context, _isNavigating),
        const SizedBox(height: 20),

        _buildSectionHeader(title: 'Departments'),
        _buildDepartmentsGrid(),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildBanner(context, 'New in MP Urban Locker'),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text("About MP Urban Locker", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600))),

            ],
          ),
        ),
        _buildAboutButtonsRow(context),

        const SizedBox(height: 30),
      ],
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize with an empty list for suggestions
    _filteredServices = [];

    // Add listeners for search and focus changes
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChange);
  }
    @override
  Widget build(BuildContext context) {
            // Determine if the suggestion list should be visible
      final bool showSuggestions =
          _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          // 2. The rest of the page is a Stack to overlay suggestions
          Expanded(
            child: Stack(
              children: [
                // The main content is visible only when not showing suggestions
                Visibility(
                  visible: !showSuggestions,
                  maintainState: true, // Keep the state of the list
                  child: _buildMainContent(),
                ),

                // Show the suggestions list when searching
                if (showSuggestions) _buildSuggestionsList(context),
              ],
            ),
          ),
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
  // --- Builds the search suggestions list ---
  Widget _buildSuggestionsList(BuildContext ctxt) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        itemCount: _filteredServices.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Divider(
            color: Color(0xffDDDDDD),
            height: 1,
            thickness: 1,
          ),
        ),
        itemBuilder: (context, index) {
          final service = _filteredServices[index];

          return ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: service.bgcolor,
              child: Image.asset(service.imagePath),
            ),
            title: Text(
              service.displayName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              _searchController.clear();
              _searchFocusNode.unfocus();
              _isNavigating ? null : _navigateToDigiLockerAuth(ctxt, 'search');


            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }
  // --- Search and Focus Handlers ---
  void _onFocusChange() {
    // Rebuild the UI when focus changes to show or hide suggestions
    setState(() {});
  }
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = []; // Clear suggestions if search is empty
      } else {
        // Filter services based on the search query for suggestions
        _filteredServices = ConfigService.docServices.where((service) {
          return service.displayName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.search, color: ColorUtils.fromHex("#212121")),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode, // Assign the focus node
                  decoration: InputDecoration(
                    hintText: 'Search for documents...',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorUtils.fromHex("#2121217A"),
                    ),
                  ),
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
            Icon(Icons.mic, color: ColorUtils.fromHex("#212121")),
          ],
        ),
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
            onTap: () {
              _navigateToDigiLockerAuth(context, "documentType");
            },
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
        // CarouselSlider.builder(
        //   itemCount: AppConstants.appSlides.length,
        //   options: CarouselOptions(
        //     height: 150,
        //     enlargeCenterPage: true,
        //     viewportFraction: (screenWidth - 10) / screenWidth,
        //     autoPlay: true,
        //   ),
        //   itemBuilder: (context, index, realIndex) {
        //     final slide = AppConstants.appSlides[index];
        //     return SizedBox(
        //       width: screenWidth - 40,
        //       child: Card(
        //         elevation: 4,
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //         clipBehavior: Clip.hardEdge,
        //         child: Image.asset(slide["image"]!, fit: BoxFit.fitWidth),
        //       ),
        //     );
        //   },
        // ),
        CarouselSlider.builder(
          itemCount: AppConstants.appSlides.length,
          options: CarouselOptions(
            height: 160,
            enlargeCenterPage: true,
            viewportFraction: (screenWidth - 10) / screenWidth,

            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              provider.setIndex(index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final slide = AppConstants.appSlides[index];
            return Container(
              // The horizontal margin creates the visible gap between slides
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  slide["image"]!,
                  fit: BoxFit.fitWidth,
                  // Ensures the image fills the card without gaps inside
                  width: double.infinity,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AppConstants.appSlides.asMap().entries.map((entry) {
            bool isActive = provider.currentIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 8,
              // Expansion effect for active dot
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF5C3AFF)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
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

  Widget _buildStatisticsRow(BuildContext context, bool _isNavigating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      // IntrinsicHeight calculates the height of the tallest child
      // and forces all other children to be able to match it.
      child: IntrinsicHeight(
        child: Row(
          // Stretch forces the Expanded children to fill the full
          // height calculated by IntrinsicHeight.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatisticCard(
              value: '2.7 Lakhs+',
              label: 'Trade Licenses',
              image: Image.asset('assets/services/trade_license_certificate.png'),
              iconColor: const Color(0xFF613AF5),
              onTap: _isNavigating
                  ? null
                  : () => _navigateToDigiLockerAuth(context, "Trade Licenses"),
            ),
            StatisticCard(
              value: '1.9 Lakhs+',
              label: 'Marriage Certificate',
              image: Image.asset('assets/services/marriage_certificate.png'),
              iconColor: const Color(0xff613AF5),
              onTap: _isNavigating
                  ? null
                  : () => _navigateToDigiLockerAuth(context, "Marriage Certificate"),
            ),
            StatisticCard(
              value: '10.2 Lakhs+',
              label: 'Property Tax Receipts',
              image: Image.asset('assets/services/property_tax_receipt.png'),
              iconColor: const Color(0xffE66B00),
              onTap: _isNavigating
                  ? null
                  : () => _navigateToDigiLockerAuth(context, "Property Tax Receipts"),
            ),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildStatisticsRow(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          StatisticCard(
            value: '2.7 Lakhs+',
            label: 'Trade Licenses',
            image: Image.asset('assets/services/trade_license_certificate.png'),
            iconColor: Color(0xFF613AF5),
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, "Documents Issued"),
          ),
          StatisticCard(
            value: '1.9 Lakhs+',
            label: 'Marriage Certificate',
            image: Image.asset('assets/services/marriage_certificate.png'),
            iconColor: Color(0xff613AF5),
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, "Departments Live"),
          ),
          StatisticCard(
            value: '10.2 Lakhs+',
            label: 'Property Tax Receipts',
            image: Image.asset('assets/services/property_tax_receipt.png'),
            iconColor: Color(0xffE66B00),
            onTap: _isNavigating
                ? null
                : () => _navigateToDigiLockerAuth(context, "Verified Citizens"),
          ),
        ],
      ),
    );
  }
*/

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
                  title: 'Urban Administration & development Department',
                  onTap:(){_navigateToDigiLockerAuth(context, "Department");}
                  ,
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
