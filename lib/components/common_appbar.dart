import 'package:digilocker_flutter/screens/AboutMpUrbanLockerScreen.dart';
import 'package:digilocker_flutter/screens/FAQScreen.dart';
import 'package:digilocker_flutter/screens/NotificationScreen.dart';
import 'package:digilocker_flutter/screens/PrivacyPolicyScreen.dart';
import 'package:digilocker_flutter/screens/TermsConditionScreen.dart';
import 'package:digilocker_flutter/screens/comingsoon_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          SizedBox(width: 23.64, height: 40, child: Image.asset("assets/lion.png")),
          const SizedBox(width: 10),
          SizedBox(
            width: 33,
            height: 40,
            child: Image.asset("assets/logo.png", color: ColorUtils.fromHex("#613AF5")),
          ),
          const SizedBox(width: 10),
          Flexible(
            child:  Text(
                'MP Urban Locker',
                style:GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorUtils.fromHex("#613AF5")
                )
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComingSoonScreen(docType: "QR Scan")),
            );
          },
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
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
