import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart'
    show SupabaseService;

class SkillsManagementScreen extends StatefulWidget {
  const SkillsManagementScreen({super.key});

  @override
  State<SkillsManagementScreen> createState() => _SkillsManagementScreenState();
}

class _SkillsManagementScreenState extends State<SkillsManagementScreen> {
  late List<String> _skills;
  final SupabaseService supabaseService = SupabaseService();
  bool _isLoading = false;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    _skills = [];
    await _loadSkillsFromSupabase();
  }

  // جلب المهارات من Supabase
  Future<void> _loadSkillsFromSupabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // جلب المهارات من Supabase
      final skills = await supabaseService.getSkills();
      setState(() {
        _skills = skills;
      });
    } catch (e) {
      print('Error loading skills: $e');
      // في حالة الخطأ، نستخدم البيانات الافتراضية
      setState(() {
        _skills = [
          'Flutter',
          'Dart',
          'Firebase',
          'UI/UX Design',
          'Responsive Design',
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // إضافة مهارة جديدة
  Future<void> _addNewSkill(String skillName) async {
    if (skillName.isNotEmpty && !_skills.contains(skillName)) {
      try {
        setState(() {
          _isLoading = true;
        });

        // إنشاء قائمة جديدة تحتوي على المهارات الحالية + المهارة الجديدة
        final updatedSkills = [..._skills, skillName];

        // حفظ القائمة المحدثة في Supabase (سيتم استبدال جميع المهارات القديمة)
        await supabaseService.saveSkills(updatedSkills);

        // تحديث القائمة محليًا
        setState(() {
          _skills = updatedSkills;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding skill: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // حذف مهارة
  Future<void> _deleteSkill(String skillName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // إنشاء قائمة جديدة بدون المهارة المحذوفة
      final updatedSkills = _skills
          .where((skill) => skill != skillName)
          .toList();

      // حفظ القائمة المحدثة في Supabase (سيتم استبدال جميع المهارات القديمة)
      await supabaseService.saveSkills(updatedSkills);

      // تحديث القائمة محليًا
      setState(() {
        _skills = updatedSkills;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting skill: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Skills Management'),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildSkillsChips(),
            const SizedBox(height: 20),
            _buildSkillInputField(),
            const SizedBox(height: 10),
            _buildSaveButton('Save Skills', () {
              setState(() {});
              _addNewSkill(controller.text);
              controller.clear();
              // هذا الزر الآن غير مطلوب لأن الإضافة تحدث فورًا
            }),
          ],
        ),
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
            _deleteSkill(skill);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSkillInputField() {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Add New Skill',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onSubmitted: (value) {
        _addNewSkill(value);
        controller.clear();
      },
    );
  }

  Widget _buildSaveButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Text(label, style: GoogleFonts.poppins(fontSize: 16)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
