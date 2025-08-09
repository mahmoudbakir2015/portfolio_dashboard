import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillsManagementScreen extends StatefulWidget {
  const SkillsManagementScreen({super.key});

  @override
  State<SkillsManagementScreen> createState() => _SkillsManagementScreenState();
}

class _SkillsManagementScreenState extends State<SkillsManagementScreen> {
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _skills = [
      'Flutter',
      'Dart',
      'Firebase',
      'UI/UX Design',
      'Responsive Design',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Skills Management'),
          const SizedBox(height: 20),
          _buildSkillsChips(),
          const SizedBox(height: 20),
          _buildSkillInputField(),
          const SizedBox(height: 10),
          _buildSaveButton('Save Skills', () {
            // Save skills functionality
          }),
        ],
      ),
    );
  }

  Widget _buildSkillsChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _skills.map((skill) {
        return Chip(
          label: Text(skill),
          onDeleted: () {
            setState(() {
              _skills.remove(skill);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSkillInputField() {
    final TextEditingController controller = TextEditingController();

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Add New Skill',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty && !_skills.contains(value)) {
          setState(() {
            _skills.add(value);
          });
          controller.clear();
        }
      },
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
