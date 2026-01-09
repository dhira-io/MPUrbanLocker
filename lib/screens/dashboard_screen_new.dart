import 'package:carousel_slider/carousel_slider.dart';
import 'package:digilocker_flutter/models/doc_service_config.dart';
import 'package:digilocker_flutter/screens/myDocuments_screen.dart';
import 'package:digilocker_flutter/screens/profile_screen.dart';
import 'package:digilocker_flutter/screens/comingsoon_screen.dart';
import 'package:digilocker_flutter/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document.dart';
import '../models/documentExpiry_model.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart'; // Used for Carousel index
import '../providers/scheme_provider.dart';
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
import 'category_wise_doc_list_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Access the provider
      final provider = Provider.of<SchemeProvider>(context, listen: false);

      // 3. Await the second call (Documents)
      // This ensures provider.documents is now full of data
      await provider.fetchDocumentsExpiry(context);

      // 4. Check if the widget is still in the tree before showing dialog
      if (mounted) {
        _checkAndShowExpiryPopup(provider.documents);
      }
    });

    // Initialize with an empty list for suggestions
    _filteredServices = [];

    // Add listeners for search and focus changes
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChange);
  }
  void _checkAndShowExpiryPopup(List<DocumentExpiry> documents) {
    // 1. Filter the list to get ALL documents with expiry enabled
    final expiredDocs = documents.where((doc) => doc.hasExpiry == true).toList();

    // 2. Only show the dialog if the list is not empty
    if (expiredDocs.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1E4B), Color(0xFF1A3B8B)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Dialog shrinks to fit content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Document Validity Expired!',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. The List of Expired Documents
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: expiredDocs.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.docType.replaceAll('_', ' '),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFDBEAFE),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doc.expiryDate != null && doc.expiryDate!.isNotEmpty
                                    ? 'Expires: ${doc.expiryDate}'
                                    : 'Expiry tracking active',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                              const Divider(color: Colors.white10, height: 20),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // White Action Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Got it',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF613AF5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF613AF5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
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
      final pref = await SharedPreferences.getInstance();
      String userId = await pref.getString(AppConstants.userIdKey) ?? "";
      final apiService = context.read<ApiService>();

      final Map<String, dynamic> response = await apiService.getRequest(
        AppConstants.userDocumentsEndpoint,
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
    // _pages[0] = _buildHomePage();
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
        showAllPopularDocs
            ? _buildPopularDocsGrid(context)
            : _buildDocumentsList(context),
        const SizedBox(height: 20),

        _sectionTitle("Document Categories"),
        Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 10),
          child: _documentCategories(),
        ),

        // _smartInsightCard(),
        // const SizedBox(height: 20),
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
                      color: ColorUtils.fromHex("#1F2937"),
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
                    //ColorUtils.fromHex("#EBE5FF"),
                    Colors.deepPurpleAccent.shade100,
                  ),
                  _buildQuickActionTile(
                    "Document Drive",
                    Icons.drive_folder_upload_rounded,
                    Colors.deepPurpleAccent.shade100,
                    // Colors.blue,
                  ),
                  _buildQuickActionTile(
                    "My Consents",
                    Icons.question_mark_rounded,
                    Colors.deepPurpleAccent.shade100,
                    //Colors.green,
                  ),
                  _buildQuickActionTile(
                    "Activity Log",
                    Icons.history,
                    Colors.deepPurpleAccent.shade100,
                    // Colors.blueAccent,
                  ),
                  _buildQuickActionTile(
                    "Support",
                    Icons.support_agent,
                    Colors.deepPurpleAccent.shade100,
                    //  Colors.cyan,
                  ),
                  _buildQuickActionTile(
                    "More",
                    Icons.add,
                    Colors.deepPurpleAccent.shade100,
                    // Colors.amber
                  ),
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
                "Issued documents",
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorUtils.fromHex("#1F2937"),
        ),
      ),
    );
  }

  Widget _documentCategories() {
    return Row(
      children: [
        _categoryCard("Documents for\nCitizen / Individual", Icons.group),
        const SizedBox(width: 12),
        _categoryCard("Documents for\nBusiness Entity", Icons.business),
      ],
    );
  }

  Widget _categoryCard(String title, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CategoryWiseDocListScreen(),
            ),
          ).then((_) {
            print("refresh call");
            getDocuments();
          });

        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                radius: 26,
                child: Icon(icon, color: Colors.deepPurple),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smartInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3A8D), Color(0xFF1E63E9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smart AI Insight pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  "Smart AI Insight",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Title
          const Text(
            "We found more documents linked to\nyour mobile number",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          // Description
          const Text(
            "You have 10 government documents registered\nwith your mobile number.\n\n"
            "You’ve already fetched 4 documents in MP Urban\nLocker.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Available to access chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_open, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "Available to access",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(width: 6),
                Text(
                  "6 more",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Fetch button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A48F2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Fetch More Documents  >",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Footer note
          const Row(
            children: [
              Icon(Icons.verified_user, size: 14, color: Colors.white70),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Documents are identified securely using your registered mobile number.",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
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
    Widget currentBody;
    switch (_selectedIndex) {
      case 0:
        currentBody = _buildHomePage();
        break;
      case 1:
        currentBody = MyDocumentsScreen();
        break;
      case 2:
        currentBody = NotificationScreen();
        break;
      case 3:
        currentBody = const ProfileScreen();
        break;
      default:
        currentBody = _buildHomePage();
    }
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
        body: currentBody,
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
                    child: Image.asset(logoImage, color: Color(0xff613AF5)),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ComingSoonScreen(docType: "Documents Drive"),
                  ),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/settings.png'),
              title: const Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(docType: "Settings"),
                  ),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/shield.png'),
              title: const Text('Validate Certificate'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ComingSoonScreen(docType: "Validate Certificate"),
                  ),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/log.png'),
              title: const Text('Activity Log'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(docType: "Activity Log"),
                  ),
                );
              },
            ),
            Divider(color: Color(0xffDDDDDD)),

            ListTile(
              leading: Image.asset('assets/contact.png'),
              title: const Text('Contact Support'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ComingSoonScreen(docType: "Contact Support"),
                  ),
                );
              },
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
          onPressed: () {},
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
        // Animated Dots
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => ComingSoonScreen(docType: title),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON + OVERLAY BADGE
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Icon background
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(icon, size: 26, color: color),
                ),

                // Coming Soon badge (overlapping)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      //const Color(0xFFEDE9FE), // light purple
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Text(
                      "Coming Soon",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: ColorUtils.fromHex("#374151"),
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
              child: Container(
                alignment: Alignment.bottomCenter,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: bgColor,
                  child: image,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
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
