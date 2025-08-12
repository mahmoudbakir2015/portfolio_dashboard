import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart';
import 'package:url_launcher/url_launcher.dart'; // غير المسار حسب مشروعك

class CvManagementPage extends StatefulWidget {
  const CvManagementPage({super.key});

  @override
  State<CvManagementPage> createState() => _CvManagementPageState();
}

class _CvManagementPageState extends State<CvManagementPage> {
  String? _cvUrl;
  String? _fileName;
  DateTime? _uploadedAt;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCv();
  }

  Future<void> _loadCv() async {
    setState(() {
      _loading = true;
    });

    try {
      final cvData = await SupabaseService().getLatestCv();
      if (cvData != null) {
        setState(() {
          _cvUrl = cvData['file_url'];
          _fileName = cvData['file_name'];
          _uploadedAt = DateTime.tryParse(cvData['uploaded_at']);
        });
      } else {
        setState(() {
          _cvUrl = null;
          _fileName = null;
          _uploadedAt = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في جلب البيانات: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _uploadNewCv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return; // لو المستخدم رجع من غير اختيار

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    setState(() {
      _loading = true;
    });

    try {
      await SupabaseService().uploadAndReplaceCv(file);

      // بعد الرفع، حمل البيانات من جديد
      await _loadCv();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم رفع السيرة الذاتية بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل في الرفع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _openPdf() async {
    if (_cvUrl == null) return;

    final uri = Uri.parse(_cvUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الملف')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة السيرة الذاتية'),
        centerTitle: true,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // أيقونة PDF
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 100,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),

                  // حالة: في CV
                  if (_cvUrl != null)
                    Column(
                      children: [
                        Text(
                          'الملف: $_fileName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'آخر تحديث: ${_uploadedAt?.formatDate() ?? ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        // زر عرض
                        ElevatedButton.icon(
                          onPressed: _openPdf,
                          icon: const Icon(Icons.visibility),
                          label: const Text('عرض السيرة الذاتية'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // زر تحديث
                        OutlinedButton.icon(
                          onPressed: _uploadNewCv,
                          icon: const Icon(Icons.refresh),
                          label: const Text('تحديث الملف'),
                        ),
                      ],
                    )
                  else
                    // حالة: ما فيش CV
                    Column(
                      children: [
                        const Text(
                          'لم يتم رفع سيرة ذاتية بعد',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _uploadNewCv,
                          icon: const Icon(Icons.upload),
                          label: const Text('رفع سيرة ذاتية'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 40),
                  const Text(
                    'ملاحظة: يتم حذف النسخة القديمة تلقائيًا عند رفع ملف جديد.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

// مساعدة: تنسيق التاريخ
extension on DateTime {
  String formatDate() {
    final now = this;
    return '${now.day}/${now.month}/${now.year} في ${now.hour}:${now.minute}';
  }
}
