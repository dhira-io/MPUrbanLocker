import 'package:digilocker_flutter/components/common_appbar.dart';
import 'package:flutter/material.dart';

class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns arrow to the top
                children: [
                  IconButton(
                    // Using arrow_back instead of arrow_back_ios for a cleaner Material look
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded( // <--- Crucial: Prevents overflow and allows text wrapping
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stand-Up India',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2, // Improves spacing between lines
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ministry of Finance, Government of India',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tags Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8, // Handles wrapping if tags are too long
                          children: [
                            _buildTag('Business', Colors.blue),
                            _buildTag('Entrepreneur', Colors.orange),
                            _buildTag('Finance', Colors.deepPurple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 1),

            // 2. Accordion Sections
            _buildExpansionTile(
              title: 'Details',
              content: 'A scheme by Ministry of Finance for financing SC/ST and/or Women Entrepreneurs by facilitating bank loans for setting up a greenfield project enterprise in manufacturing, services, trading sector and activities allied to agriculture. The objective of this scheme is to facilitate bank loans between Rs. 10 lakh and Rs. 1 Crore to at least one Scheduled Caste (SC) or Scheduled Tribe (ST) borrower and at least one woman borrower per bank branch for setting up a greenfield enterprise. In case of non-individual enterprises, at least 51% of the shareholding and controlling stake should be held by either an SC/ST or Woman entrepreneur..',
              isExpanded: true, // "Before" state
            ),
            _buildExpansionTile(
              title: 'Benefits',
              content: '• Facilitation of composite loan (inclusive of term loan and working capital) between ₹10 Lakhs and ₹100 Lakhs. Rupay debit card to be issued for convenience of the borrower.\n• The web portal by SIDBI provides hand-holding support through a network of agencies engaged in training, skill development, mentoring, project report preparation, application filling, work shed / utility support services, subsidy schemes etc.',
            ),
            _buildExpansionTile(
              title: 'Eligibility',
              content: '• Finance is provided for Greenfield Enterprises.\n• If the applicant is a male, he must be from SC / ST category.\n• The age of the applicant must be at least 18 years.\n• The applicant must not be in default to any bank/financial institution.',
            ),
            _buildExpansionTile(
              title: 'Application Process',
              content: "Either approach your nearest bank branch to apply (locate your nearest bank here - https://www.rbi.org.in/Scripts/query.aspx )Or Through the Lead District Manager (LDM) (find the address and the email of the LDM of your district here - https://www.standupmitra.in/LDMS#NoBack)Or Apply Through Portal: www.standupmitra.in \n Process: \n• The first step is to visit the official portal of StandUp India at: https://www.standupmitra.in/Login/Register\n• Enter the full details of the business location.\n• Select the category between SC, ST, Woman, and whether the stake held is 51% or higher.\n• Select the nature of the proposed business; the loan amount desired description of the business, the details of the premises, etc.\n• Populate the fields with past business experience, including tenure.\n• Select the need for hand-holding is required.\n• Enter all the personal details sought, which include the name of the enterprise and the constitution.\n• The last step is to select the register button to complete the process.\nOnce you have completed registration, you are eligible to initiate the StandUp India Loan Application process with the respective financial institution for the officials to contact you for completing the StandUp India Loan Process and requisite formalities.",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      // Optional Bottom Action Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6236FF),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Apply for Scheme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Helper to build consistent tags
  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Custom styled ExpansionTile to match the app UI
  Widget _buildExpansionTile({required String title, required String content, bool isExpanded = false}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xff1F2937),
          ),
        ),
        iconColor: Colors.grey,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff4B5563),
              height: 1.5,
              fontWeight: FontWeight.w400
            ),
          ),
        ],
      ),
    );
  }
}