import 'package:portfolio_dashboard/const/private_string.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  void initSupabase() {
    _client = SupabaseClient(
      supabaseUrl, // Project URL من الصورة
      anonKey, // Anon Key من الصورة
    );
  }

  SupabaseClient get client => _client;

  // حفظ بيانات المستخدم مع صورة
  Future<void> saveUserData({
    required String name,
    required String profession,
    required String bio,
    required String email,
    required String phone,
    required String location,
    File? profileImage, // إضافة صورة الملف الشخصي
  }) async {
    try {
      // إذا كانت هناك صورة، قم برفعها إلى Supabase Storage
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await _uploadImage(profileImage, 'profile-images/');
      }

      // أولاً، حاول البحث عن السجل الحالي
      final existingData = await _client
          .from('portfolio_data')
          .select('id')
          .limit(1);

      if (existingData.isNotEmpty && existingData[0].containsKey('id')) {
        // إذا كان هناك سجل، قم بالتحديث
        final id = existingData[0]['id'];
        await _client
            .from('portfolio_data')
            .update({
              'name': name,
              'profession': profession,
              'bio': bio,
              'email': email,
              'phone': phone,
              'location': location,
              'profile_image_url': imageUrl, // حفظ مسار الصورة
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id);
      } else {
        // إذا لم يكن هناك سجل، أضف سجل جديد
        await _client.from('portfolio_data').insert({
          'name': name,
          'profession': profession,
          'bio': bio,
          'email': email,
          'phone': phone,
          'location': location,
          'profile_image_url': imageUrl, // حفظ مسار الصورة
        });
      }

      print('User data saved successfully');
    } catch (e) {
      print('Error saving user  $e');
      rethrow;
    }
  }

  // رفع الصورة إلى Supabase Storage
  Future<String?> _uploadImage(File imageFile, String folder) async {
    try {
      // تحديد اسم الملف
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      print('Uploading file: $fileName to bucket: profile-images');

      // رفع الملف إلى Supabase Storage
      final response = await _client.storage
          .from('profile-images')
          .upload(
            '$folder$fileName',
            imageFile,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              cacheControl: '3600', // تخزين مؤقت لمدة ساعة
            ),
          );

      print('Upload response: $response');

      // التحقق من النجاح
      if (response != null) {
        // الحصول على URL العام للصورة
        final publicUrl = _client.storage
            .from('profile-images')
            .getPublicUrl('$folder$fileName');
        print('Public URL: $publicUrl');
        return publicUrl;
      }

      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // حفظ مشروع جديد
  Future<void> saveProject({
    required String title,
    required String description,
    required List<String> technologies,
    String? imageUrl,
    String? githubUrl,
    String? liveUrl,
  }) async {
    try {
      await _client.from('projects').insert({
        'title': title,
        'description': description,
        'technologies': technologies,
        'image_url': imageUrl,
        'github_url': githubUrl,
        'live_url': liveUrl,
      });
    } catch (e) {
      print('Error saving project: $e');
      rethrow;
    }
  }

  // تحديث مشروع
  Future<void> updateProject({
    required int id,
    required String title,
    required String description,
    required List<String> technologies,
    String? imageUrl,
    String? githubUrl,
    String? liveUrl,
  }) async {
    try {
      await _client
          .from('projects')
          .update({
            'title': title,
            'description': description,
            'technologies': technologies,
            'image_url': imageUrl,
            'github_url': githubUrl,
            'live_url': liveUrl,
          })
          .eq('id', id);
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  // حذف مشروع
  Future<void> deleteProject(int id) async {
    try {
      await _client.from('projects').delete().eq('id', id);
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  // جلب المشاريع
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await _client.from('projects').select('*');
      return response;
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  // جلب بيانات المستخدم
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final response = await _client
          .from('portfolio_data')
          .select('*')
          .limit(1);
      if (response.isNotEmpty) {
        return response[0];
      }
      return null;
    } catch (e) {
      print('Error fetching user  $e');
      return null;
    }
  }

  // حفظ رسالة اتصال
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
      });
    } catch (e) {
      print('Error saving contact message: $e');
      rethrow;
    }
  }
}
