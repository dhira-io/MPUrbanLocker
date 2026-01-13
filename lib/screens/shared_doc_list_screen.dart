import 'package:digilocker_flutter/providers/shared_doc_list_provider.dart';
import 'package:digilocker_flutter/screens/editdoc_share_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../components/common_appbar.dart';
import '../utils/color_utils.dart';

class SharedDocListScreen extends StatelessWidget {
  const SharedDocListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SharedDocListProvider()..apicall_GetAllShareDocList(context),
      child: const _SharedDocumentListsView(),
    );
  }
}

class _SharedDocumentListsView extends StatelessWidget {
  const _SharedDocumentListsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedDocListProvider>();

    return Scaffold(
      backgroundColor: ColorUtils.fromHex("#F9FAFB"),
      appBar: CustomAppBar(),
      endDrawer: customEndDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _header(context),
            _searchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.documents.length,
                itemBuilder: (context, index) {
                  return _documentItem(context, provider, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            "Shared Documents",
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for Documents",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: const Icon(Icons.mic),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _documentItem(
    BuildContext context,
    SharedDocListProvider provider,
    int index,
  ) {
    final SharedDocModel doc = provider.documents[index];
    final isExpanded = provider.isExpanded(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEDE7FF),
              child: Image.asset(
                'assets/services/trade_license_certificate.png',
              ),
            ),
            title: Text(doc.documentName),
            subtitle: Text("Shared with ${doc.sharedWithName}"),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () => provider.toggleExpanded(index),
          ),
          if (isExpanded) _expandedContent(doc, context, provider),
        ],
      ),
    );
  }

  String formatDate(DateTime isoDate) {
    final localDate = isoDate.toLocal(); // IST
    return DateFormat("dd MMM yyyy . hh:mm a").format(localDate);
  }

  Widget _expandedContent(
    SharedDocModel doc,
    BuildContext context,
    SharedDocListProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          _summaryRow("Document", doc.documentName),
          _summaryRowWithIcon("Method", Icons.link, doc.shareMethod),
          _summaryRowWithIcon("Protection", Icons.lock, doc.protectionType),
          _summaryRow("PIN", doc.pin ?? ''),
          _summaryRow(
            "Permission",
            doc.canDownload == true ? "View & Download" : "View",
          ),
          _summaryRow("Expires On", formatDate(doc.expiresAt)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditShareDetailsScreen(document: doc),
                      ),
                    ).then((_) {
                      print("refresh call");
                      context
                          .read<SharedDocListProvider>()
                          .apicall_GetAllShareDocList(context);
                    });
                  },
                  style: _outlinedStyle(Colors.deepPurple),
                  child: const Text("Edit Details"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.apicall_DeleteSharedDoc(context, doc.id);
                  },
                  style: _outlinedStyle(Colors.red),
                  child: const Text("Revoke Link"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  softWrap: true,
                  textAlign: TextAlign.right,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRowWithIcon(String label, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _outlinedStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
