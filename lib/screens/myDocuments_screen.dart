// lib/screens/myDocuments_screen.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:digilocker_flutter/models/doc_service_config.dart';
import 'package:digilocker_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../services/config_service.dart';
import '../utils/color_utils.dart';
import 'CreateDocumentForm.dart';

class MyDocumentsScreen extends StatefulWidget {
  MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  bool showAllPopularDocs = false;

  // --- Search functionality ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // To track search bar focus
  List<DocServiceConfig> _filteredServices = [];

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    // We return a ListView directly, assuming the parent (DashboardScreen_new)
    // provides the Scaffold, AppBar, and BottomNavigationBar.

    final bool showSuggestions = _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;

    return Column(
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
    );
  }

  // --- Builds the main dashboard content (everything below the search bar) ---
  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most Popular Documents',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: ColorUtils.fromHex("#1F2937"),
                  fontWeight: FontWeight.w600,
                ),
              ),
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

        // Categories Section
     /*   _buildSectionTitle(title: 'Categories', showViewAll: true),
        _buildCategoriesGrid(),
        const SizedBox(height: 30),*/

        // What's New Section (using the banner image from the screenshot)
        _buildBannerPlaceholder(context, "What's New"),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- Builds the search suggestions list ---
  Widget _buildSuggestionsList() {
    return Container(
      color: Colors.white, // Give it a solid background
      child: ListView.builder(
        itemCount: _filteredServices.length,
        itemBuilder: (context, index) {
          final service = _filteredServices[index];
          return ListTile(
            title: Text(service.displayName),
            onTap: () {
              // When a suggestion is tapped, navigate and clear the search
              _navigateToDigiLockerAuth(context, service.displayName);
              _searchController.clear();
              _searchFocusNode.unfocus(); // Hides keyboard and suggestions
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        // Changed to white for better contrast with grey[50] background
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode, // Assign the focus node
                  decoration: InputDecoration(
                    hintText: 'Search for documents...',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: GoogleFonts.inter(fontSize: 16,fontWeight: FontWeight.w400, color: ColorUtils.fromHex("#2121217A")),
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
            const Icon(Icons.mic, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required String title, bool showViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: ColorUtils.fromHex("#1F2937"),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {
                print("View All Categories");
              },
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ColorUtils.fromHex("#613AF5"),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- HORIZONTAL DOCUMENTS LIST (Popular Docs) ---
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
          childAspectRatio: 1,
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


  Widget _buildCategoriesGrid() {
    final categories = [
      {'title': 'Education & Learning', 'icon': Icons.school, 'color': Colors.deepPurple},
      {'title': 'Banking & Financial', 'icon': Icons.account_balance, 'color': Colors.indigo},
      {'title': 'Transport & Infrastructure', 'icon': Icons.train, 'color': Colors.blue},
      {'title': 'Health & Wellness', 'icon': Icons.local_hospital, 'color': Colors.purple},
      {'title': 'Sports & Culture', 'icon': Icons.sports_soccer, 'color': Colors.deepOrange},
      {'title': 'Identity Docs', 'icon': Icons.person_pin, 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1, // Make them square
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryTile(
          title: category['title'] as String,
          icon: category['icon'] as IconData,
          color: category['color'] as Color,
        );
      },
    );
  }

  Widget _buildCategoryTile({required String title, required IconData icon, required Color color}) {
    return GestureDetector(
      onTap: () {
        print('Tapped $title category');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 25, color: color),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColorUtils.fromHex("#374151"),
                  fontWeight: FontWeight.w500,
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

  // --- CAROUSEL SLIDER ---
  Widget _buildBannerPlaceholder(BuildContext context, String? title) {
    final provider = Provider.of<OnboardingProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title.trim().isNotEmpty) ...[
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: ColorUtils.fromHex("#1F2937"),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],

        CarouselSlider.builder(
          itemCount: AppConstants.appSlides.length,
          options: CarouselOptions(
            height: 160,
            enlargeCenterPage: true,
            viewportFraction: (screenWidth - 10) / screenWidth,

            //auto play
            autoPlay: true,                // Enable auto scroll
            autoPlayInterval: Duration(seconds: 3), // Duration between slides
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
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  slide["image"]!,
                  fit: BoxFit.cover,
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

  void _navigateToDigiLockerAuth(BuildContext context, String documentType) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateDocumentForm(docType: documentType,)),
    );
    print('Navigate to fetch service for $documentType');
  }
}

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
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColorUtils.fromHex("#4B5563"),
                  fontWeight: FontWeight.w500,
                ),
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
