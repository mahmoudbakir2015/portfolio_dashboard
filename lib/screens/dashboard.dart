import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:portfolio_dashboard/screens/language_screen.dart';
import 'package:portfolio_dashboard/screens/profile_settings_screen.dart';
import 'package:portfolio_dashboard/screens/projects_management_screen.dart';
import 'package:portfolio_dashboard/screens/skills_management_screen.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart';

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

  // قائمة المشاريع

  // قائمة المهارات

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

    // قائمة المشاريع الافتراضية

    // قائمة المهارات الافتراضية
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
        setState(() {});
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

  // ==================== بناء الواجهة ====================
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
            icon: Icons.settings,
            title: 'Languages',
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const ProfileSettingsScreen();
      case 1:
        return const ProjectsManagementScreen();
      case 2:
        return const SkillsManagementScreen();
      case 3:
        return const SpokenLanguagesScreen();

      default:
        return const ProfileSettingsScreen();
    }
  }
}
