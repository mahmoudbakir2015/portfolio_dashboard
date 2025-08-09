import 'package:portfolio_dashboard/const/private_string.dart';
import 'package:supabase/supabase.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  void initSupabase() {
    _client = SupabaseClient(
      supabaseUrl, // Project URL من الصورة
      anonKey,
    ); // Anon Key من الصورة);
  }

  SupabaseClient get client => _client;

  // حفظ بيانات المستخدم
  Future<void> saveUserData({
    required String name,
    required String profession,
    required String bio,
    required String email,
    required String phone,
    required String location,
  }) async {
    try {
      await _client.from('portfolio_data').upsert({
        'name': name,
        'profession': profession,
        'bio': bio,
        'email': email,
        'phone': phone,
        'location': location,
      });
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
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
      print('Error fetching user data: $e');
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
