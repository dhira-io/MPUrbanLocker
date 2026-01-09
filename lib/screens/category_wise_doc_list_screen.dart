import 'package:flutter/material.dart';

import '../components/common_appbar.dart';
import '../models/doc_service_config.dart';
import '../services/config_service.dart';
import 'CreateDocumentForm.dart';

class CategoryWiseDocListScreen extends StatefulWidget {
  const CategoryWiseDocListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryWiseDocListScreen> createState() => _CategoryWiseDocListScreenState();
}

class _CategoryWiseDocListScreenState extends State<CategoryWiseDocListScreen> {
  final List<Map<String, dynamic>> documentsList = [
    {
      "title": "Driving License",
      "subtitle": "Fetch or verify via DigiLocker",
      "icon": Icons.credit_card,
      "bgColor": const Color(0xFFEDE7F6),
      "iconColor": const Color(0xFF673AB7),
    },
    {
      "title": "PAN Card",
      "subtitle": "Fetch or verify via DigiLocker",
      "icon": Icons.account_balance_wallet,
      "bgColor": const Color(0xFFE0F2F1),
      "iconColor": const Color(0xFF009688),
    },
    {
      "title": "Vehicle Registration Certificate",
      "subtitle": "Fetch or verify via DigiLocker",
      "icon": Icons.directions_car,
      "bgColor": const Color(0xFFFFF3E0),
      "iconColor": const Color(0xFFFF9800),
    },
    {
      "title": "Marksheet / Certificates",
      "subtitle": "Fetch or verify via DigiLocker",
      "icon": Icons.school,
      "bgColor": const Color(0xFFE3F2FD),
      "iconColor": const Color(0xFF2196F3),
    },
    {
      "title": "Aadhaar-based Services",
      "subtitle": "Fetch or verify via DigiLocker",
      "icon": Icons.fingerprint,
      "bgColor": const Color(0xFFE8F5E9),
      "iconColor": const Color(0xFF4CAF50),
    },
  ];
  List<DocServiceConfig> _arrServices = [];
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getService();
    });
  }
  getService(){
  setState(() {
    _arrServices = ConfigService.docServices;
  });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16,right: 16),
              itemCount: _arrServices.length,
              itemBuilder: (context, index) {
                final item = _arrServices[index];
            
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: item.bgcolor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Image.asset(item.imagePath)
                      ),
                      title: Text(
                        item.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      // subtitle: Text(
                      //   item.serviceType,
                      //   style: const TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        // Handle navigation here
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateDocumentForm(docType: item.displayName),
                            ));
                            },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              "Documents",
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
