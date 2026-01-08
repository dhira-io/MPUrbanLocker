import 'package:digilocker_flutter/models/NotificationModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_utils.dart';

class NotificationScreen extends StatelessWidget {
  // final List<NotificationModel> notifications;
  // final VoidCallback onBackClick;
  //
  // const NotificationScreen({
  //   Key? key,
  //   required this.notifications,
  //   required this.onBackClick,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: //notifications.isEmpty ?
           _buildEmptyState()
        //   : Padding(
        // padding: const EdgeInsets.all(16.0),
        // child: ListView.separated(
        //   itemCount: notifications.length,
        //   separatorBuilder: (context, index) => SizedBox(height: 12),
        //   itemBuilder: (context, index) {
        //     final notification = notifications[index];
        //     return NotificationCard(notification: notification);
        //   },
        // ),
     // ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorUtils.fromHex("#EFF6FF"),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      color: ColorUtils.fromHex("#613AF5"),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'There’s Nothing Yet!',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.fromHex("#613AF5"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You'll see updates here when there are document alerts, expiry reminders, or important messages.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorUtils.fromHex("#4B5563"),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("You'll be notified about:",
                      style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorUtils.fromHex("#4B5563"),
                     ),
                   ),
                  ),
                  NotificationTile(
                    icon: Icons.calendar_month,
                    label: "Document expiry alerts",
                    iconColor: ColorUtils.fromHex("#6D28D9"),
                  ),
                  NotificationTile(
                    icon: Icons.share,
                    label: "Share requests",
                    iconColor: ColorUtils.fromHex("#6D28D9"),
                  ),
                  NotificationTile(
                    icon: Icons.message,
                    label: "Admin messages",
                    iconColor: ColorUtils.fromHex("#6D28D9"),
                  ),
                  NotificationTile(
                    icon: Icons.question_mark_rounded,
                    label: "New documents added",
                    iconColor: ColorUtils.fromHex("#6D28D9"),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const NotificationTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style:  GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorUtils.fromHex("#4B5563"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.grey : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    notification.timestamp,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
