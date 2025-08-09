import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('General Settings'),
          const SizedBox(height: 20),
          _buildPrivacySettings(),
          const SizedBox(height: 20),
          _buildNotificationSettings(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Privacy',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(
                'Make Portfolio Public',
                style: GoogleFonts.poppins(),
              ),
              value: true,
              onChanged: (value) {
                // تغيير حالة النشر
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text('Email Notifications', style: GoogleFonts.poppins()),
              value: true,
              onChanged: (value) {
                // تغيير إعدادات الإشعارات
              },
            ),
            SwitchListTile(
              title: Text('Push Notifications', style: GoogleFonts.poppins()),
              value: false,
              onChanged: (value) {
                // تغيير إعدادات الإشعارات
              },
            ),
          ],
        ),
      ),
    );
  }
}
