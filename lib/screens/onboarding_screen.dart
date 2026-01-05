import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/color_utils.dart';
import 'combine_dashboard.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> slides = [
    {
      "title": "Secure Digital Locker",
      "subtitle": "Store, manage, and access all your documents in one place.",
      "image": "assets/img1.png"
    },
    {
      "title": "Fetch Verified Documents",
      "subtitle": "Official verification backed by Government of MP.",
      "image": "assets/img2.png"
    },
    {
      "title": "Share Documents Instantly",
      "subtitle": "Securely share your documents with anyone anytime.",
      "image": "assets/img3.png"
    }
  ];

  // 👇 Use the correct controller type for carousel_slider v5+
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 30, height: 40, child: Image.asset("assets/lion.png")),
            const SizedBox(width: 10),
            Image.asset(
              'assets/logo.png',
              height: 30,
              width: 30,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Text(
              'MP Urban Locker',
              style:  GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ColorUtils.fromHex("#613AF5")
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CombinedDashboard(isLoggedIn: false,)),
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(color: Color(0xFF5C3AFF), fontSize: 16),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: slides.length,
                options: CarouselOptions(
                  height: double.infinity,
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    provider.setIndex(index);
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Image.asset(
                              slide["image"]!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide["title"]!,
                          style:  GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: ColorUtils.fromHex("#1F2937")
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide["subtitle"]!,
                          style:GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: ColorUtils.fromHex("#4B5563")
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
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

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF5C3AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (provider.currentIndex < slides.length - 1) {
                    int nextIndex = provider.currentIndex + 1;
                    _carouselController.animateToPage(nextIndex);
                    provider.setIndex(nextIndex);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CombinedDashboard(isLoggedIn: false,)),
                    );
                  }
                },
                child: Text(
                  provider.currentIndex < slides.length - 1
                      ? "Next"
                      : "Get Started",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
