import 'package:digilocker_flutter/screens/AboutMpUrbanLockerScreen.dart';
import 'package:digilocker_flutter/screens/FAQScreen.dart';
import 'package:digilocker_flutter/screens/NotificationScreen.dart';
import 'package:digilocker_flutter/screens/PrivacyPolicyScreen.dart';
import 'package:digilocker_flutter/screens/TermsConditionScreen.dart';
import 'package:digilocker_flutter/screens/comingsoon_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Required for SystemUiOverlayStyle
import 'package:url_launcher/url_launcher.dart';
import '../utils/color_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  // 40.0 (Purple Bar) + 60.0 (White Bar) = 100.0
  Size get preferredSize => const Size.fromHeight(100.0);
  // Placeholder assets used in AppBar. Ensure these assets exist.
  final String logoImage = 'assets/logo.png';
  final String lionImage = 'assets/lion.png';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // This part ensures Wi-Fi/Signal icons are white and the bar is transparent
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Makes the system bar transparent
        statusBarIconBrightness: Brightness.light, // White icons for Android
        statusBarBrightness: Brightness.dark, // White icons for iOS
      ),
      child: Material(
        elevation: 0,
        child: Column(
          children: [
            // --- 1. GLOBAL GOVERNMENT HEADER (Purple) ---
            Container(
              width: double.infinity,
              // This color will now show behind the Wi-Fi/Signal icons
              color: ColorUtils.fromHex("#613AF5"),
              child: SafeArea(
                bottom: false,
                top: true, // This ensures content stays below the status bar icons
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset('assets/india_flag.png', height: 25),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          //https://www.india.gov.in/
                          final uri = Uri.parse('https://www.india.gov.in/');
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            Fluttertoast.showToast(msg: "Could not open website");
                          }
                        },
                        child: Text(
                          'Gov. of India',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(icon: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
                        onPressed: () async {
                          final uri = Uri.parse('https://www.india.gov.in/');
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            Fluttertoast.showToast(msg: "Could not open website");
                          }
                        },),
                      const Spacer(),
                      const Icon(Icons.g_translate, color: Colors.white, size: 25),
                      //const SizedBox(width: 12),
                      // const Icon(Icons.accessibility, color: Colors.white, size: 14),
                      // const SizedBox(width: 4),
                      // Text(
                      //   'Accessibility',
                      //   style: GoogleFonts.inter(
                      //     color: Colors.white,
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 2. MAIN APP HEADER (White) ---
            Expanded(
              child: Container(
                height: 60,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Row for left & right sides
                    Row(
                      children: [
                        // Left side icons
                        SizedBox(width: 24, height: 40, child: Image.asset(lionImage)),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 33,
                          height: 40,
                          child: Image.asset(logoImage, color: ColorUtils.fromHex("#613AF5")),
                        ),

                        Spacer(),

                        // Right side icons
                        IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner,
                            color: ColorUtils.fromHex("#212121"),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComingSoonScreen(docType: "QR Code Scanner"),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => Scaffold.of(context).openEndDrawer(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.menu, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Centered title
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: Text(
                        'MP Urban Locker',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorUtils.fromHex("#613AF5"),
                        ),
                        maxLines: 1,  // ensures no wrapping
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customEndDrawer(BuildContext context) {
  return Drawer(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0,bottom: 20),
            child: Row(
              children: [
                // Placeholder for the Government/MP Logo
                SizedBox(
                    width: 23.64,
                    height: 40,
                    child: Image.asset('assets/lion.png')),
                const SizedBox(width: 6),
                SizedBox(
                  width: 33,
                  height: 40,
                  //color: Colors.blue[50],
                  child: Image.asset('assets/logo.png', color: ColorUtils.fromHex("#613AF5")),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child:  Text(
                      'MP Urban Locker',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorUtils.fromHex("#613AF5")
                      )
                  ),
                ),
                const SizedBox(width: 6),
                // Close Button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
            child: Text("Menu",style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorUtils.fromHex("#9CA3AF")
            ),),
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
            leading: Image.asset('assets/drive.png'),
            title:  Text('Documents Drive',style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),
            ),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
            visualDensity: VisualDensity(vertical: -3),
            onTap: () =>   Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComingSoonScreen(docType: "Documents Drive")),
            ),
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
            leading: Image.asset('assets/settings.png'),
            title:  Text('Settings',style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
            visualDensity: VisualDensity(vertical: -2),
            onTap: () =>  Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComingSoonScreen(docType: "Settings")),
            ),
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
            leading: Image.asset('assets/shield.png'),
            title:  Text('Validate Certificate',style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
            visualDensity: VisualDensity(vertical: -1),
            onTap: () =>  Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComingSoonScreen(docType: "Validate Certificate")),
            ),
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
            leading: Image.asset('assets/log.png'),
            title:  Text('Activity Log',style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
            onTap: () =>Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComingSoonScreen(docType: "Activity Log")),
            ),
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
            leading: Image.asset('assets/contact.png'),
            title: Text('Contact Support' ,style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComingSoonScreen(docType: "Contact Support")),
            ),
          ),
          Divider(color: Color(0xffDDDDDD)),
          Padding(
            padding: const EdgeInsets.only(top: 12.0,bottom: 12.0),
            child: Text("About MP Urban Locker",style:GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorUtils.fromHex("#9CA3AF")
            ),),
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
              leading: Image.asset('assets/about.png'),
              title:  Text('About MP Urban Locker',style:GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorUtils.fromHex("#4B5563")
              ),),
              trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AboutMpUrbanLockerScreen()),
                );
              }
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
              leading: Image.asset('assets/faq.png'),
              title:  Text('FAQ',style:GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorUtils.fromHex("#4B5563")
              ),),
              trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FaqScreen()),
                );
              }
          ),
          Divider(color: Color(0xffDDDDDD)),
          ListTile(
            leading: Image.asset('assets/terms.png'),
            title:  Text('Terms & Conditions',style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
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
            title:  Text('Privacy Policy',style:GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563")
            ),),
            trailing: Icon(Icons.arrow_forward_ios,size: 16,color: ColorUtils.fromHex("#9CA3AF"),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
              );
            },
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Divider(color: Color(0xffDDDDDD)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<String>(
                  future: AppVersion().getAppVersion(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(); // or loader
                    }

                    return Text(
                      "Version ${snapshot.data}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ColorUtils.fromHex("#9CA3AF"),
                      ),
                    );
                  },
                ),
              )

            ],
          ),
        ],
      ),
    ),
  );
}
