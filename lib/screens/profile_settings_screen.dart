import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart'
    show SupabaseService;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // تحكمات النصوص
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late String _userImage;
  final SupabaseService supabaseService = SupabaseService();
  XFile? _pickedImage;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = 'Mahmoud Bakir';
    _professionController.text = 'Flutter Developer & UI/UX Designer';
    _bioController.text =
        'Passionate Flutter developer with 3+ years of experience creating innovative mobile applications. Specialized in building responsive, scalable, and user-friendly interfaces.';
    _emailController.text = 'mahmoudbakir2015@icloud.com';
    _phoneController.text = '+20 101 763 2363';
    _locationController.text = 'Cairo, Egypt';
    _userImage = 'assets/images/profile.jpg';
  }

  Future<void> _saveProfileChanges() async {
    try {
      // استخراج القيم من الحقول
      final String name = _nameController.text.trim();
      final String profession = _professionController.text.trim();
      final String bio = _bioController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String location = _locationController.text.trim();

      // إرسال البيانات مع الصورة إذا تم اختيارها
      await supabaseService.saveUserData(
        name: name,
        profession: profession,
        bio: bio,
        email: email,
        phone: phone,
        location: location,
        profileImage: _selectedImageFile, // إرسال الصورة
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

  // دالة لاختيار الصورة من المعرض أو الكاميرا
  Future<void> _pickImageWithOptions() async {
    try {
      // طلب الإذن
      await _requestPermissions();

      // عرض نافذة اختيار
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromCamera();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  // طلب الأذونات
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.camera.request();
    } else if (Platform.isIOS) {
      await Permission.photos.request();
      await Permission.camera.request();
    }
  }

  // اختيار من المعرض
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
        _userImage = image.path;
        _selectedImageFile = File(image.path); // حفظ الملف للاستخدام لاحقاً
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected from gallery!')),
      );
    }
  }

  // اختيار من الكاميرا
  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
        _userImage = image.path;
        _selectedImageFile = File(image.path); // حفظ الملف للاستخدام لاحقاً
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo taken successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Profile Settings'),
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 20),
          _buildTextField('Full Name', _nameController),
          const SizedBox(height: 15),
          _buildTextField('Profession', _professionController),
          const SizedBox(height: 15),
          _buildTextField('Bio', _bioController, maxLines: 4),
          const SizedBox(height: 15),
          _buildTextField('Email', _emailController),
          const SizedBox(height: 15),
          _buildTextField('Phone', _phoneController),
          const SizedBox(height: 15),
          _buildTextField('Location', _locationController),
          const SizedBox(height: 20),
          _buildSaveButton('Save Profile Changes', _saveProfileChanges),
        ],
      ),
    );
  }

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
            child: ClipOval(
              child: _pickedImage != null
                  ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                  : Image.asset(_userImage, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImageWithOptions,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
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

  @override
  void dispose() {
    // تحرير الذاكرة عند إغلاق الشاشة
    _nameController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
