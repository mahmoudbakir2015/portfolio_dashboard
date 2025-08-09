import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart'
    show SupabaseService;

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  late String _userEmail;
  late String _userPhone;
  late String _userLocation;
  final SupabaseService supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _userEmail = 'mahmoudbakir2015@icloud.com';
    _userPhone = '+20 101 763 2363';
    _userLocation = 'Cairo, Egypt';
  }

  Future<void> _saveContactInfo() async {
    try {
      // يمكنك هنا إضافة منطق لحفظ معلومات الاتصال
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact information updated successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving contact info: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 20),
          _buildTextField('Email', _userEmail, (value) {
            setState(() {
              _userEmail = value;
            });
          }),
          const SizedBox(height: 15),
          _buildTextField('Phone', _userPhone, (value) {
            setState(() {
              _userPhone = value;
            });
          }),
          const SizedBox(height: 15),
          _buildTextField('Location', _userLocation, (value) {
            setState(() {
              _userLocation = value;
            });
          }),
          const SizedBox(height: 20),
          _buildSaveButton('Save Contact Information', _saveContactInfo),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    Function(String) onChanged, {
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 16)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
