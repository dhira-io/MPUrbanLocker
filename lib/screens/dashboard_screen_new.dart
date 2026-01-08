import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:digilocker_flutter/models/doc_service_config.dart';
import 'package:digilocker_flutter/screens/myDocuments_screen.dart';
import 'package:digilocker_flutter/screens/profile_screen.dart';
import 'package:digilocker_flutter/screens/scheme_screen.dart';
import 'package:digilocker_flutter/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart'; // Used for Carousel index
import '../services/api_service.dart';
import '../services/config_service.dart';
import '../utils/constants.dart';
import 'AboutMpUrbanLockerScreen.dart';
import 'CreateDocumentForm.dart';
import 'DocumentPreview.dart';
import 'FAQScreen.dart';
import 'NotificationScreen.dart';
import 'PrivacyPolicyScreen.dart';
import 'TermsConditionScreen.dart';
import 'combine_dashboard.dart';

class DashboardScreen_new extends StatefulWidget {
  const DashboardScreen_new({super.key});

  @override
  _DashboardScreen_newState createState() => _DashboardScreen_newState();
}

class _DashboardScreen_newState extends State<DashboardScreen_new> {
  List<Document> issuedDocs = [];
  bool isLoading = true;
  int _selectedIndex = 0; // The index for the selected tab
  bool showAllPopularDocs = false; // <-- Added flag

  // --- Search functionality ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // To track search bar focus
  List<DocServiceConfig> _filteredServices = [];

  late final List<Widget> _pages;

  // Placeholder assets used in AppBar. Ensure these assets exist.
  final String logoImage = 'assets/logo.png';
  final String lionImage = 'assets/lion.png';

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _buildHomePage(), // Index 0: Home/Dashboard Content
      MyDocumentsScreen(),
      //SchemeScreen(),// Index 1: Docs & Services
      NotificationScreen(), // Index 2: Notifications
      const ProfileScreen(), // Index 3: Profile
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDocuments();
    });

    // Initialize with an empty list for suggestions
    _filteredServices = [];

    // Add listeners for search and focus changes
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChange);
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

  Future<void> getDocuments() async {
    List<Document> loadedDocs = [];
       // Only fetch documents if the user is logged in
        try {
          final pref =await SharedPreferences.getInstance();
          String userId = await pref.getString(AppConstants.userIdKey) ?? "";
          final apiService = context.read<ApiService>();

          final Map<String, dynamic> response = await apiService.getRequest(
            AppConstants.userDocumentsEndpoint(userId),
            includeAuth: true,
          );

          if (response['success'] == true && response['data'] != null) {
            final Map<String, dynamic> data =
            response['data'] as Map<String, dynamic>;

            final List<dynamic> documents = (data['documents'] as List?) ?? [];
            List<Document> arrdocuments = documents
                .map((e) => Document.fromJson(e as Map<String, dynamic>))
                .toList();
            loadedDocs = {
              for (final doc in arrdocuments)
                if (doc.doctype != null) doc.doctype!: doc,
            }.values.toList();
          } else {
            String errorMessage = response['message'] ?? 'Something went wrong';
            Fluttertoast.showToast(msg: errorMessage);
          }
        } on NoInternetException catch (e) {
          debugPrint('Fetch Error: $e');
          Fluttertoast.showToast(msg: '${e.toString()}');
        } catch (e) {
          debugPrint('Fetch Error: $e');
          Fluttertoast.showToast(msg: '${e.toString()}');
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
              issuedDocs = loadedDocs;
            });
          }
        }
  }

  // --- BOTTOM NAV NAVIGATION HANDLER ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Ensure the Home page content is refreshed if switching away/back
    _pages[0] = _buildHomePage();
  }

  // --- WIDGET FOR HOME TAB CONTENT (Index 0) ---
  Widget _buildHomePage() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Determine if the suggestion list should be visible
    final bool showSuggestions =
        _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;

    return SafeArea(
      child: Column(
        children: [
          // 1. Search Bar is always visible at the top
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
                if (showSuggestions) _buildSuggestionsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Builds the main dashboard content (everything below the search bar) ---
  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const SizedBox(height: 10),

        // 2. Carousel Banner/Illustration
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildBannerPlaceholder(context),
        ),
        const SizedBox(height: 20),

        // 3. Most Popular Documents Section (Horizontal Scroll)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
              child: Text(
                'Documents you might need',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.fromHex("#1F2937"),
                ),
              ),
            ),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAllPopularDocs = !showAllPopularDocs;
                  });
                },
                child: Text(
                  showAllPopularDocs ? 'View Less' : 'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: ColorUtils.fromHex("#613AF5"),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- LIST OR GRID BASED ON toggle ---
         showAllPopularDocs ?
             _buildPopularDocsGrid(context)
             : _buildDocumentsList(context),
        const SizedBox(height: 20),

        //scheme card
/*
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1E4B), Color(0xFF1A3B8B)], // Navy Blue Gradient
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Schemes you are eligible for',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorUtils.fromHex("#FFFFFF"),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorUtils.fromHex("#FF8C00"),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text('New Matches', style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.fromHex("#FFFFFF"),
                    ),),
                  ),
                ],
              ),
              const SizedBox(height: 12),
               Text(
                'Based on your fetched documents, MP Locker intelligently identifies government schemes that are recommended to you.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorUtils.fromHex("#DBEAFE"),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check which government benefits you can access today.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorUtils.fromHex("#DBEAFE"),
                ),
              ),
              const SizedBox(height: 20),
              // White Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;  // Switch to the Schemes tab
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('View All Schemes', style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorUtils.fromHex("#613AF5"),
                      ),),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 16, color: ColorUtils.fromHex("#613AF5")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
*/
                // 4. Quick Actions Grid
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      "Quick Actions",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorUtils.fromHex("#1F2937")
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("View All Quick Actions");
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: ColorUtils.fromHex("#613AF5"),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // GridView for Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  // Adjust ratio for better text fit
                  children: [
                    _buildQuickActionTile(
                      "Validate Certificate",
                      Icons.qr_code,
                      Colors.red,
                    ),
                    _buildQuickActionTile(
                      "Document Drive",
                      Icons.drive_folder_upload_rounded,
                      Colors.blue,
                    ),
                    _buildQuickActionTile(
                      "My Consents",
                      Icons.question_mark_rounded,
                      Colors.green,
                    ),
                    _buildQuickActionTile(
                      "Activity Log",
                      Icons.history,
                      Colors.blueAccent,
                    ),
                    _buildQuickActionTile(
                      "Support",
                      Icons.support_agent,
                      Colors.cyan,
                    ),
                    _buildQuickActionTile("More", Icons.add, Colors.amber),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(height: 20),

        // 5. Issued Documents section
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "eNagar Palika documents",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.fromHex("#1F2937"),
                ),
              ),
              const SizedBox(height: 10),
              if (issuedDocs.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  child: Center(
                    child: Text(
                      'No documents issued yet.',
                      style: GoogleFonts.inter(
                        color: ColorUtils.fromHex("#4B5563"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ] else
                // Show API-fetched documents
                ...issuedDocs.map((doc) => _buildIssuedDocTile(doc)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  // --- Builds the search suggestions list ---
  Widget _buildSuggestionsList() {
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
            leading: CircleAvatar(radius: 28, backgroundColor: service.bgcolor, child: Image.asset(service.imagePath)),
            title: Text(
              service.displayName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              _navigateToDigiLockerAuth(context, service.displayName);
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
          );
        },
      ),
    );
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    _pages[0] = _buildHomePage();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog(context);
        if (shouldExit) {
          SystemNavigator.pop(); // closes the app
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _pages[_selectedIndex],
        // Displays the content of the selected tab
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: ColorUtils.fromHex("#613AF5"),
          unselectedItemColor: ColorUtils.fromHex("#9CA3AF"),
          type: BottomNavigationBarType.fixed,
          // Use fixed for more than 3 items
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Documents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),

        endDrawer: _buildDrawer(context),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Do you want to close this app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  // ===================== DRAWER =====================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20),
              child: Row(
                children: [
                  // Placeholder for the Government/MP Logo
                  SizedBox(
                    width: 23.64,
                    height: 40,
                    child: Image.asset(lionImage),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 33,
                    height: 40,
                    //color: Colors.blue[50],
                    child: Image.asset(
                      logoImage,
                      color: Color(0xff613AF5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'MP Urban Locker',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorUtils.fromHex("#613AF5"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                "Menu",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.fromHex("#9CA3AF"),
                ),
              ),
            ),
            Divider(color: Color(0xffDDDDDD)),
            ListTile(
              leading: Image.asset('assets/drive.png'),
              title: const Text('Documents Drive'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/settings.png'),
              title: const Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/shield.png'),
              title: const Text('Validate Certificate'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/log.png'),
              title: const Text('Activity Log'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/contact.png'),
              title: const Text('Contact Support'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: Color(0xffDDDDDD)),

            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                "About MP Urban Locker",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.fromHex("#9CA3AF"),
                ),
              ),
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/about.png'),
              title: const Text('About MP Urban Locker'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AboutMpUrbanLockerScreen()),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/faq.png'),
              title: const Text('FAQ'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FaqScreen()),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),
            ListTile(
              leading: Image.asset('assets/terms.png'),
              title: const Text('Terms & Conditions'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TermsAndConditionsScreen()),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),
            ListTile(
              leading: Image.asset('assets/privacy.png'),
              title: const Text('Privacy Policy'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),
            ListTile(
              leading: const Icon(Icons.logout),
              trailing: Icon(Icons.arrow_forward_ios),
              title: const Text('Logout'),
              onTap: () async {
                final authProvider = AuthProvider();
                await authProvider.logout();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CombinedDashboard(isLoggedIn: false),
                  ),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Version 1.0.0",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Placeholder for the Government/MP Logo
          SizedBox(width: 23.64, height: 40, child: Image.asset(lionImage)),
          const SizedBox(width: 10),
          SizedBox(
            width: 33,
            height: 40,
            child: Image.asset(logoImage, color: ColorUtils.fromHex("#613AF5")),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'MP Urban Locker',
              style: GoogleFonts.inter(
                color: ColorUtils.fromHex("#613AF5"),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.qr_code_scanner,
            color: ColorUtils.fromHex("#212121"),
          ),
          onPressed: () {
          
          },
        ),
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: ColorUtils.fromHex("#212121")),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  // --- SEARCH BAR ---
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

  // --- CAROUSEL SLIDER ---
  Widget _buildBannerPlaceholder(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: AppConstants.appSlides.length,
          options: CarouselOptions(
            height: 160,
            enlargeCenterPage: true,
            viewportFraction: (screenWidth - 10) / screenWidth,

            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,

            onPageChanged: (index, reason) {
              provider.setIndex(index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final slide = AppConstants.appSlides[index];
            return SizedBox(
              width: screenWidth - 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  slide["image"]!,
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            AppConstants.appSlides.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: provider.currentIndex == index ? 12 : 8,
              height: provider.currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: provider.currentIndex == index
                    ? const Color(0xFF5C3AFF)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

      ],
    );
  }

  // --- HORIZONTAL DOCUMENTS LIST (Popular Docs) ---
  // This now uses the original, unfiltered list of services
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
            onTap: () {
              _navigateToDigiLockerAuth(context, docConfig.displayName);
            },
          );
        }).toList(),
      ),
    );
  }

  // This grid also uses the original, unfiltered list
  Widget _buildPopularDocsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        itemCount: ConfigService.docServices.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final docConfig = ConfigService.docServices[index];
          return CategoryCard(
            image: Image.asset(docConfig.imagePath),
            title: docConfig.displayName,
            bgColor: docConfig.bgcolor,
            onTap: () {
              _navigateToDigiLockerAuth(context, docConfig.displayName);
            },
          );
        },
      ),
    );
  }

  // --- QUICK ACTION TILE (Grid Items) ---
  Widget _buildQuickActionTile(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        print("Quick Action: $title");
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.fromHex("#374151"),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- API ISSUED DOC TILE ---
  Widget _buildIssuedDocTile(Document doc) {
    IconData icon;
    Color color = Colors.deepPurple;
    String name = doc.name.toString().toLowerCase();

    // Icon and Color determination logic
    if (name.contains('aadhaar') || name.contains('id')) {
      icon = Icons.credit_card;
      color = Colors.orange;
    } else if (name.contains('license') || name.contains('dl')) {
      icon = Icons.drive_eta;
      color = Colors.red;
    } else if (name.contains('pan')) {
      icon = Icons.business;
      color = Colors.brown;
    } else if (name.contains('marksheet') || name.contains('school')) {
      icon = Icons.school;
      color = Colors.green;
    } else if (name.contains('certificate')) {
      icon = Icons.speaker_notes_rounded;
      color = Colors.green;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        title: Text(
          doc.name ?? 'Unknown Document',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorUtils.fromHex("#1F2937"),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.issuer ?? doc.type ?? 'Issued Document',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563"),
              ),
            ),
            Text(
              'Issued on: ${doc.date ?? 'N/A'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563"),
              ),
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            // Navigate to DocumentPreviewPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentPreview(
                  title: doc.name ?? "",
                  date: doc.date ?? "N/A",
                  docId: doc.id,
                  pdfString: '',
                ),
              ),
            );
          },
          child: Text(
            "View",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorUtils.fromHex("#6C47FF"),
            ),
          ),
        ),
        onTap: () {
          print("URI: ${doc.uri}");
        },
      ),
    );
  }

  void _navigateToDigiLockerAuth(BuildContext context, String documentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDocumentForm(docType: documentType),
      ),
    ).then((_) {
      print("refresh call");
      getDocuments();
    });
  }
}

// --- CATEGORY CARD COMPONENT (Used in Horizontal Document List) ---
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
        width: 140,
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
            CircleAvatar(radius: 28, backgroundColor: bgColor, child: image),
            const SizedBox(height: 4),
            SizedBox(
              height: 42,
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
          ],
        ),
      ),
    );
  }
}
