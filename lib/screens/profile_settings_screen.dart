// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart'
    show SupabaseService;
import 'dart:io';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  String _userImage = '';
  XFile? _pickedImage;
  File? _selectedImageFile;

  String _selectedCountryCode = '+20';

  final SupabaseService supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    _userImage =
        'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?w=1480';

    try {
      final userData = await supabaseService.getUserData();

      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        _professionController.text = userData['profession'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _locationController.text = userData['location'] ?? '';
        _educationController.text = userData['education'] ?? '';

        final phone = userData['phone'] ?? '';
        if (phone.startsWith('+')) {
          final code = phone.split(RegExp(r'[0-9]')).first;
          if (code.isNotEmpty) {
            setState(() {
              _selectedCountryCode = code;
            });
          }
        }

        final profileImageUrl = userData['profile_image_url'];
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          _userImage = profileImageUrl;
        }
      } else {
        _educationController.text =
            'Bachelor\'s degree in Computer Engineering, Kafr-Elshiekh University, Egypt';
      }
    } catch (e) {
      log('Error loading user data: $e');
    } finally {
      if (_phoneController.text.isEmpty ||
          !_phoneController.text.startsWith(_selectedCountryCode)) {
        _phoneController.text = _selectedCountryCode;
      }
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length),
      );
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    try {
      final userData = await supabaseService.getUserData();

      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _professionController.text = userData['profession'] ?? '';
          _bioController.text = userData['bio'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _educationController.text = userData['education'] ?? '';

          final phone = userData['phone'] ?? '';
          if (phone.startsWith('+')) {
            final code = phone.split(RegExp(r'[0-9]')).first;
            if (code.isNotEmpty) {
              _selectedCountryCode = code;
            }
          }

          final profileImageUrl = userData['profile_image_url'];
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            _userImage = profileImageUrl; // تحديث رابط الصورة
            _pickedImage =
                null; // مسح أي صورة مختارة محليًا عشان يظهر رابط الـ Network
            _selectedImageFile = null;
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error refreshing data: $e')));
    }
  }

  Future<void> _saveProfileChanges() async {
    try {
      final String name = _nameController.text.trim();
      final String profession = _professionController.text.trim();
      final String bio = _bioController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String location = _locationController.text.trim();
      final String education = _educationController.text.trim();

      if (name.isEmpty ||
          profession.isEmpty ||
          bio.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          location.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')),
        );
        return;
      }

      await supabaseService.saveUserData(
        name: name,
        profession: profession,
        bio: bio,
        email: email,
        phone: phone,
        location: location,
        education: education,
        profileImage: _selectedImageFile,
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

  Future<void> _pickImageWithOptions() async {
    try {
      await _requestPermissions();
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
      log('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.camera.request();
    } else if (Platform.isIOS) {
      await Permission.photos.request();
      await Permission.camera.request();
    }
  }

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
        _selectedImageFile = File(image.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected from gallery!')),
      );
    }
  }

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
        _selectedImageFile = File(image.path);
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
            Text(
              'You should choose a profile image every time you open the app because it will be uploaded to Supabase:it save null if you do not choose an image.',

              style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 20),
            _buildTextField('Full Name', TextInputType.text, _nameController),
            const SizedBox(height: 15),
            _buildTextField(
              'Profession',
              TextInputType.text,
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
              'Education',
              TextInputType.text,
              _educationController,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              'Email',
              TextInputType.emailAddress,
              _emailController,
            ),
            const SizedBox(height: 15),
            _buildPhoneField(),
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
              child: _pickedImage != null
                  ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                  : _userImage.isNotEmpty
                  ? Image.network(_userImage, fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 80),
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
                decoration: const BoxDecoration(
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

  Widget _buildPhoneField() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (country) {
                setState(() {
                  _selectedCountryCode = '+${country.phoneCode}';
                  _phoneController.text = '+${country.phoneCode}';
                  _phoneController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _phoneController.text.length),
                  );
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[50],
            ),
            child: Text(
              _selectedCountryCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
      ],
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
    _nameController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _educationController.dispose();
    super.dispose();
  }
}
