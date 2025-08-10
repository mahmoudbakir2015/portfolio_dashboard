import 'package:portfolio_dashboard/const/private_string.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  void initSupabase() {
    if (!_isInitialized) {
      _client = SupabaseClient(supabaseUrl, anonKey);
      _isInitialized = true;
    }
  }

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception(
        'SupabaseService not initialized. Call initSupabase() first.',
      );
    }
    return _client;
  }

  // --- User Data ---
  Future<void> saveUserData({
    required String name,
    required String profession,
    required String bio,
    required String email,
    required String phone,
    required String location,
    File? profileImage,
  }) async {
    try {
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await _uploadImage(profileImage, 'profile-images/');
      }

      final existingData = await _client
          .from('portfolio_data')
          .select('id')
          .limit(1);

      final data = {
        'name': name,
        'profession': profession,
        'bio': bio,
        'email': email,
        'phone': phone,
        'location': location,
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingData.isNotEmpty && existingData[0].containsKey('id')) {
        await _client
            .from('portfolio_data')
            .update(data)
            .eq('id', existingData[0]['id']);
      } else {
        await _client.from('portfolio_data').insert(data);
      }
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  Future<String?> _uploadImage(File imageFile, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = '$folder$fileName';

      await _client.storage
          .from('profile-images')
          .upload(
            filePath,
            imageFile,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              cacheControl: '3600',
            ),
          );

      return _client.storage.from('profile-images').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // --- Projects: Save with Images ---
  Future<void> saveProject({
    required String title,
    required String description,
    required List<String> technologies,
    String? githubUrl,
    String? liveUrl,
    File? mainImage,
    List<File> galleryImages = const [],
  }) async {
    try {
      String? mainImageUrl;
      List<String> galleryUrls = [];

      // رفع الصورة الرئيسية
      if (mainImage != null) {
        mainImageUrl = await _uploadImageToProjectBucket(mainImage, 'main');
      }

      // رفع صور المعرض
      for (var image in galleryImages) {
        final url = await _uploadImageToProjectBucket(image, 'gallery');
        galleryUrls.add(url);
      }

      await _client.from('projects').insert({
        'title': title,
        'description': description,
        'technologies': technologies,
        'github_url': githubUrl,
        'live_url': liveUrl,
        'main_image_url': mainImageUrl,
        'gallery_image_urls': galleryUrls, // مصفوفة من الروابط
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }

  // --- Projects: Update with Images ---
  Future<void> updateProject({
    required int id,
    required String title,
    required String description,
    required List<String> technologies,
    String? githubUrl,
    String? liveUrl,
    File? mainImage,
    List<File> galleryImages = const [],
    bool keepOldMainImage = false,
    bool keepOldGallery = false,
  }) async {
    try {
      // جلب البيانات الحالية
      final response = await _client
          .from('projects')
          .select('main_image_url, gallery_image_urls')
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) throw Exception('Project not found');

      final currentData = response[0];
      String? mainImageUrl = currentData['main_image_url'];
      List<String> galleryUrls = List<String>.from(
        currentData['gallery_image_urls'] ?? [],
      );

      // رفع صورة رئيسية جديدة إن وُجدت
      if (mainImage != null) {
        mainImageUrl = await _uploadImageToProjectBucket(mainImage, 'main');
      } else if (!keepOldMainImage) {
        mainImageUrl = null; // مسح إذا لم يتم الاحتفاظ
      }

      // رفع صور معرض جديدة
      if (galleryImages.isNotEmpty) {
        for (var image in galleryImages) {
          final url = await _uploadImageToProjectBucket(image, 'gallery');
          galleryUrls.add(url);
        }
      } else if (!keepOldGallery) {
        galleryUrls.clear(); // مسح كل الصور القديمة إذا لم يتم الاحتفاظ
      }

      await _client
          .from('projects')
          .update({
            'title': title,
            'description': description,
            'technologies': technologies,
            'github_url': githubUrl,
            'live_url': liveUrl,
            'main_image_url': mainImageUrl,
            'gallery_image_urls': galleryUrls,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  // --- Projects: Delete ---
  Future<void> deleteProject(int id) async {
    try {
      await _client.from('projects').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  // --- Projects: Fetch All ---
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      return await _client
          .from('projects')
          .select(
            'id, title, description, technologies, github_url, live_url, '
            'main_image_url, gallery_image_urls, created_at, updated_at',
          )
          .order('created_at', ascending: false);
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  // --- Image Upload Helper for Projects ---
  Future<String> _uploadImageToProjectBucket(
    File file,
    String subfolder,
  ) async {
    try {
      final fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final filePath = 'projects/$subfolder/$fileName';

      await _client.storage
          .from('project-images')
          .upload(filePath, file, fileOptions: FileOptions(upsert: true));

      return _client.storage.from('project-images').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload project image: $e');
    }
  }

  // --- User Data: Fetch ---
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final response = await _client
          .from('portfolio_data')
          .select('*')
          .limit(1);
      return response.isNotEmpty ? response[0] : null;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // --- Contact Messages ---
  Future<void> saveContactMessage({
    required String name,
    required String email,
    required String message,
    String? subject,
  }) async {
    try {
      await _client.from('contact_messages').insert({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save contact message: $e');
    }
  }

  // --- Skills ---
  Future<void> saveSkills(List<String> skills) async {
    try {
      await _client.from('skills').delete().neq('skill_name', '');

      if (skills.isNotEmpty) {
        final skillsData = skills
            .toSet()
            .map(
              (skill) => {
                'skill_name': skill,
                'created_at': DateTime.now().toIso8601String(),
              },
            )
            .toList();

        await _client.from('skills').insert(skillsData);
      }
    } catch (e) {
      throw Exception('Failed to save skills: $e');
    }
  }

  Future<List<String>> getSkills() async {
    try {
      final response = await _client
          .from('skills')
          .select('skill_name')
          .order('created_at', ascending: false);
      return response.map((skill) => skill['skill_name'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }
}
