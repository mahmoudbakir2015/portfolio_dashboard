// ignore_for_file: use_build_context_synchronously

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

  // متغيرات جديدة لتحسين التحكم
  String _userImage = '';
  bool _isLoadingImage = false;
  final SupabaseService supabaseService = SupabaseService();
  XFile? _pickedImage;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    // تعيين قيمة افتراضية أولية
    _userImage =
        'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480';

    // حاول الحصول على بيانات المستخدم من Supabase
    final userData = await supabaseService.getUserData();

    if (userData != null) {
      // إذا كانت هناك بيانات، تعبئة الحقول
      _nameController.text = userData['name'] ?? '';
      _professionController.text = userData['profession'] ?? '';
      _bioController.text = userData['bio'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
      _locationController.text = userData['location'] ?? '';

      // تعيين صورة المستخدم إذا كانت موجودة
      final profileImageUrl = userData['profile_image_url'];
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        _userImage = profileImageUrl;
      } else {
        _userImage =
            'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480';
      }
    } else {
      // إذا لم تكن هناك بيانات، تعيين القيم الافتراضية
      _nameController.text = '';
      _professionController.text = '';
      _bioController.text = '';
      _emailController.text = '';
      _phoneController.text = '';
      _locationController.text = '';
      _userImage =
          'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480';
    }
  }

  // دالة تحديث البيانات
  Future<void> _refreshData() async {
    setState(() {});

    try {
      // حاول الحصول على بيانات المستخدم من Supabase
      final userData = await supabaseService.getUserData();

      if (userData != null) {
        // إذا كانت هناك بيانات، تعبئة الحقول
        _nameController.text = userData['name'] ?? '';
        _professionController.text = userData['profession'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _locationController.text = userData['location'] ?? '';

        // تعيين صورة المستخدم إذا كانت موجودة
        final profileImageUrl = userData['profile_image_url'];
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          _userImage = profileImageUrl;
        } else {
          _userImage =
              'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480';
        }
      } else {
        // إذا لم تكن هناك بيانات، تعيين القيم الافتراضية
        _nameController.text = '';
        _professionController.text = '';
        _bioController.text = '';
        _emailController.text = '';
        _phoneController.text = '';
        _locationController.text = '';
        _userImage =
            'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error refreshing data: $e')));
    } finally {
      setState(() {});
    }
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

      // التحقق من أن جميع الحقول ملؤها
      if (name.isEmpty ||
          profession.isEmpty ||
          bio.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          location.isEmpty ||
          _selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields and select an image.'),
          ),
        );
        return; // لا نرسل البيانات إذا كانت هناك حقول فارغة أو لم يتم اختيار صورة
      }

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
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Profile Settings'),
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 20),
            _buildTextField('Full Name', TextInputType.text, _nameController),
            const SizedBox(height: 15),
            _buildTextField(
              'Profession',
              TextInputType.multiline,
              _professionController,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              'Bio',
              TextInputType.multiline,
              _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              'Email',
              TextInputType.emailAddress,
              _emailController,
            ),
            const SizedBox(height: 15),
            _buildTextField('Phone', TextInputType.number, _phoneController),
            const SizedBox(height: 15),
            _buildTextField(
              'Location',
              TextInputType.streetAddress,
              _locationController,
            ),
            const SizedBox(height: 20),
            _buildSaveButton('Save Profile Changes', _saveProfileChanges),
          ],
        ),
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
              child: _isLoadingImage
                  ? const CircularProgressIndicator()
                  : _pickedImage != null
                  ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                  : _userImage.isNotEmpty
                  ? Image.network(
                      _userImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.network(
                      'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?t=st=1754780414~exp=1754784014~hmac=bd64b4855057a199653a9d978b1ec6b912d5888c56d6740cb196670bf6c2a6e9&w=1480',
                      fit: BoxFit.cover,
                    ),
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
    TextInputType keyboardType,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      keyboardType: keyboardType,
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
