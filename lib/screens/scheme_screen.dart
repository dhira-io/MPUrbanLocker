import 'package:digilocker_flutter/screens/schemeDetail_screen.dart';
import 'package:digilocker_flutter/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SchemeScreen extends StatefulWidget {
  const SchemeScreen({super.key});

  @override
  State<SchemeScreen> createState() => _SchemeScreenState();
}

class _SchemeScreenState extends State<SchemeScreen> {
  // --- Search functionality ---
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // To track search bar focus

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSearchBar(),

          Text(
            'Recommended Schemes',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorUtils.fromHex("#1F2937"),
            ),
          ),
          Text(
            'Based on your fetched documents, MP Locker intelligently identifies government schemes that are recommended to you:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorUtils.fromHex("#4B5563"),
            ),
          ),
          const SizedBox(height: 16),

          // Promotional Banner Card
          // const PromoBanner(),

          // const SizedBox(height: 20),

          // Scheme List Items
          SchemeItem(
            title: 'Stand-Up India',
            ministry: 'Ministry of Finance',
            description:
                'A scheme by Ministry of Finance for financing SC/ST and Women Entrepreneurs by facilitating bank loans for setting up a greenfield project Enterprise in manufacturing, services, trading sector and activities allied to agriculture.',
            tags: [
              {'label': 'Business', 'color': ColorUtils.fromHex("#1D4ED8")},
              {'label': 'Entrepreneur', 'color': ColorUtils.fromHex("#C2410C")},
              {'label': 'Finance', 'color': ColorUtils.fromHex("#7E22CE")},
            ],
          ),
          SchemeItem(
            title: 'Savitribai Phule Self-Help',
            ministry: 'Government of Madhya Pradesh',
            description:
                'The scheme provides financial support to unemployed women from the Scheduled Caste (SC) category in the state to help them start businesses in industry, service, or trade sectors.',
            tags: [
              {
                'label': 'Business Loan',
                'color': ColorUtils.fromHex("#15803D"),
              },
              {'label': 'BPL', 'color': ColorUtils.fromHex("#1D4ED8")},
              {
                'label': 'Self Employment',
                'color': ColorUtils.fromHex("#A16207"),
              },
            ],
          ),
          SchemeItem(
            title: 'PM Vishwakarma',
            ministry: 'Ministry Of Micro, Small and Medium Enterprises',
            description:
                'The scheme "PM Vishwakarma " by the Ministry of Micro, Small & Medium Enterprises, is a new scheme that envisages providing end-to-end holistic support to traditional artisans and craftspeople in scaling up their conventional products and services.',
            tags: [
              {'label': 'Artisans', 'color': ColorUtils.fromHex("#B91C1C")},
              {'label': 'Craftspeople', 'color': ColorUtils.fromHex("#4338CA")},
              {
                'label': 'Skill Upgradation',
                'color': ColorUtils.fromHex("#0F766E"),
              },
            ],
          ),
          SchemeItem(
            title: 'New Swarnima Scheme For Women',
            ministry: 'Ministry Of Social Justice and Empowerment',
            description:
                'A term loan scheme by the Ministry of Social Justice and Empowerment for women entrepreneurs from backward classes to obtain a loan of up to ₹2,00,000/- @ 5% per annum, thereby providing them social & financial security.',
            tags: [
              {'label': 'Business', 'color': ColorUtils.fromHex("#6D28D9")},
              {'label': 'Women', 'color': ColorUtils.fromHex("#BE185D")},
              {'label': 'Empowerment', 'color': ColorUtils.fromHex("#B45309")},
            ],
          ),
        ],
      ),
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
}

/*
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3B8B), Color(0xFF0D1E4B)], // Navy Blue Gradient
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Schemes you are eligible for',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[800], // Orange badge
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('New Matches', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Based on your available documents, MP Locker intelligently identifies government schemes you may be eligible for.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check which government benefits you can access today.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 20),
          // White Button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View All Schemes', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.indigo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

class SchemeItem extends StatelessWidget {
  final String title;
  final String ministry;
  final String description;
  final List<Map<String, dynamic>> tags;

  const SchemeItem({
    super.key,
    required this.title,
    required this.ministry,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.fromHex("#1F2937"),
                    ),
                  ),
                ), // Title
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SchemeDetailScreen()),
                    );
                  },
                  child: Text(
                    'View More',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorUtils.fromHex("#613AF5"),
                    ),
                  ),
                ), //#613AF5
              ],
            ),
            Text(
              ministry,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#6B7280"),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563"),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (tag['color'] as Color).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (tag['color'] as Color).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        tag['label'],
                        style: TextStyle(
                          color: tag['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
