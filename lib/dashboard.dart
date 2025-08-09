import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_dashboard/supbase_services.dart' show SupabaseService;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // بيانات المستخدم
  late String _userName;
  late String _userProfession;
  late String _userBio;
  late String _userEmail;
  late String _userPhone;
  late String _userLocation;
  late String _userImage;

  // قائمة المشاريع
  late List<Map<String, dynamic>> _projects;

  // قائمة المهارات
  late List<String> _skills;

  // عرض القائمة
  int _selectedIndex = 0;

  // تهيئة Supabase
  final SupabaseService supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initializeData();
    // تهيئة Supabase
    supabaseService.initSupabase();
    // جلب البيانات من Supabase
    _loadDataFromSupabase();
  }

  void _initializeData() {
    // بيانات المستخدم الافتراضية
    _userName = 'Mahmoud Bakir';
    _userProfession = 'Flutter Developer & UI/UX Designer';
    _userBio =
        'Passionate Flutter developer with 3+ years of experience creating innovative mobile applications. Specialized in building responsive, scalable, and user-friendly interfaces.';
    _userEmail = 'mahmoudbakir2015@icloud.com';
    _userPhone = '+20 101 763 2363';
    _userLocation = 'Cairo, Egypt';
    _userImage = 'assets/images/profile.jpg';

    // قائمة المشاريع الافتراضية
    _projects = [
      {
        'id': 1,
        'title': 'E-commerce App',
        'description':
            'Full-featured e-commerce application with payment integration',
        'image': 'assets/images/project1.jpg',
        'technologies': ['Flutter', 'Firebase', 'Stripe'],
        'githubUrl': 'https://github.com/example/ecommerce  ',
        'liveUrl': 'https://example.com/ecommerce  ',
      },
      {
        'id': 2,
        'title': 'Task Management App',
        'description': 'Productivity app for managing tasks and projects',
        'image': 'assets/images/project2.jpg',
        'technologies': ['Flutter', 'Firestore', 'Provider'],
        'githubUrl': 'https://github.com/example/taskmanager  ',
        'liveUrl': 'https://example.com/taskmanager  ',
      },
    ];

    // قائمة المهارات الافتراضية
    _skills = [
      'Flutter',
      'Dart',
      'Firebase',
      'UI/UX Design',
      'Responsive Design',
    ];
  }

  // جلب البيانات من Supabase
  Future<void> _loadDataFromSupabase() async {
    try {
      // جلب بيانات المستخدم
      final userData = await supabaseService.getUserData();
      if (userData != null) {
        setState(() {
          _userName = userData['name'] ?? _userName;
          _userProfession = userData['profession'] ?? _userProfession;
          _userBio = userData['bio'] ?? _userBio;
          _userEmail = userData['email'] ?? _userEmail;
          _userPhone = userData['phone'] ?? _userPhone;
          _userLocation = userData['location'] ?? _userLocation;
        });
      }

      // جلب المشاريع
      final projects = await supabaseService.getProjects();
      if (projects.isNotEmpty) {
        setState(() {
          _projects = projects;
        });
      }
    } catch (e) {
      print('Error loading data from Supabase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildContent(),
    );
  }

  // بناء شريط العنوان
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Portfolio Dashboard',
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // هنا يمكنك إضافة خاصية تسجيل الخروج
          },
        ),
      ],
    );
  }

  // بناء القائمة الجانبية
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              'Dashboard Menu',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile Settings',
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.code,
            title: 'Projects Management',
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.star,
            title: 'Skills Management',
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.contact_page,
            title: 'Contact Info',
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'General Settings',
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // بناء عنصر القائمة الجانبية
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }

  // بناء المحتوى حسب التحديد
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildProfileSettings();
      case 1:
        return _buildProjectsManagement();
      case 2:
        return _buildSkillsManagement();
      case 3:
        return _buildContactInfo();
      case 4:
        return _buildGeneralSettings();
      default:
        return _buildProfileSettings();
    }
  }

  // صفحة إعدادات الملف الشخصي
  Widget _buildProfileSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Profile Settings'),
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 20),
          _buildTextField('Full Name', _userName, (value) {
            setState(() {
              _userName = value;
            });
          }),
          const SizedBox(height: 15),
          _buildTextField('Profession', _userProfession, (value) {
            setState(() {
              _userProfession = value;
            });
          }),
          const SizedBox(height: 15),
          _buildTextField('Bio', _userBio, (value) {
            setState(() {
              _userBio = value;
            });
          }, maxLines: 4),
          const SizedBox(height: 20),
          _buildSaveButton('Save Profile Changes', _saveProfileChanges),
        ],
      ),
    );
  }

  // حفظ بيانات الملف الشخصي
  Future<void> _saveProfileChanges() async {
    try {
      await supabaseService.saveUserData(
        name: _userName,
        profession: _userProfession,
        bio: _userBio,
        email: _userEmail,
        phone: _userPhone,
        location: _userLocation,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    }
  }

  // صورة الملف الشخصي
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: ClipOval(child: Image.asset(_userImage, fit: BoxFit.cover)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // صفحة إدارة المشاريع
  Widget _buildProjectsManagement() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Projects Management'),
              _buildFloatingActionButton(
                icon: Icons.add,
                onPressed: _addNewProject,
                label: 'Add Project',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 3,
              ),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(_projects[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة المشروع
  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                    project['image'] ?? 'assets/images/project_default.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    project['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    project['description'].substring(0, 50) + '...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _editProject(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () => _deleteProject(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // صفحة إدارة المهارات
  Widget _buildSkillsManagement() {
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
          _buildSaveButton('Save Skills', _saveSkills),
        ],
      ),
    );
  }

  // حفظ المهارات
  Future<void> _saveSkills() async {
    try {
      // يمكنك هنا إضافة منطق لحفظ المهارات في Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skills saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving skills: $e')));
    }
  }

  // عرض المهارات كـ Chips
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

  // حقل إدخال المهارة الجديدة
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

  // صفحة معلومات الاتصال
  Widget _buildContactInfo() {
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

  // حفظ معلومات الاتصال
  Future<void> _saveContactInfo() async {
    try {
      await supabaseService.saveUserData(
        name: _userName,
        profession: _userProfession,
        bio: _userBio,
        email: _userEmail,
        phone: _userPhone,
        location: _userLocation,
      );

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

  // صفحة الإعدادات العامة
  Widget _buildGeneralSettings() {
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

  // إعدادات الخصوصية
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

  // إعدادات الإشعارات
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

  // حقل إدخال نصي
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

  // زر الحفظ
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

  // زر إضافة جديد
  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
      label: Text(label, style: GoogleFonts.poppins()),
    );
  }

  // عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  // إضافة مشروع جديد
  void _addNewProject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        final TextEditingController technologiesController =
            TextEditingController();

        return AlertDialog(
          title: Text(
            'Add New Project',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Project Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Technologies (comma separated)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();
                final String technologies = technologiesController.text.trim();

                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    await supabaseService.saveProject(
                      title: title,
                      description: description,
                      technologies: technologies
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                    );

                    // تحديث القائمة بعد الإضافة
                    final newProjects = await supabaseService.getProjects();
                    setState(() {
                      _projects = newProjects;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project added successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding project: $e')),
                    );
                  }
                }
              },
              child: Text('Add', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  // تعديل مشروع
  void _editProject(int index) {
    final project = _projects[index];
    final TextEditingController titleController = TextEditingController(
      text: project['title'],
    );
    final TextEditingController descriptionController = TextEditingController(
      text: project['description'],
    );
    final TextEditingController technologiesController = TextEditingController(
      text: project['technologies'].join(', '),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Project',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Project Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Technologies (comma separated)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();
                final String technologies = technologiesController.text.trim();

                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    await supabaseService.updateProject(
                      id: project['id'],
                      title: title,
                      description: description,
                      technologies: technologies
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                    );

                    // تحديث القائمة بعد التعديل
                    final updatedProjects = await supabaseService.getProjects();
                    setState(() {
                      _projects = updatedProjects;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project updated successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating project: $e')),
                    );
                  }
                }
              },
              child: Text('Update', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  // حذف مشروع
  void _deleteProject(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Project',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this project?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await supabaseService.deleteProject(_projects[index]['id']);

                  // تحديث القائمة بعد الحذف
                  final remainingProjects = await supabaseService.getProjects();
                  setState(() {
                    _projects = remainingProjects;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project deleted successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting project: $e')),
                  );
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
