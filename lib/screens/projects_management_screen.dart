import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsManagementScreen extends StatefulWidget {
  const ProjectsManagementScreen({super.key});

  @override
  State<ProjectsManagementScreen> createState() =>
      _ProjectsManagementScreenState();
}

class _ProjectsManagementScreenState extends State<ProjectsManagementScreen> {
  List<Map<String, dynamic>> _projects = [];
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  // متغيرات الصور
  File? _mainImage;
  final List<File> _newGalleryImages = [];
  List<String> _existingGalleryUrls = [];
  UniqueKey _galleryListKey = UniqueKey();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _supabaseService.getProjects();
      setState(() => _projects = projects);
    } catch (e) {
      _showErrorSnackbar('فشل تحميل المشاريع: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMainImage() async {
    try {
      final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        final file = File(xFile.path);
        if (await file.exists()) {
          // إنشاء اسم ملف جديد باستخدام الوقت لتجنب التكرار وإزالة الأحرف غير الإنجليزية
          String newFileName =
              "img_${DateTime.now().millisecondsSinceEpoch}.jpg";
          final newFile = await file.rename(
            file.parent.path + '/' + newFileName,
          );

          setState(() {
            _mainImage = newFile;
            log('تم اختيار الصورة الرئيسية: ${newFile.path}');
          });
        } else {
          _showErrorSnackbar('الملف غير موجود');
        }
      }
    } catch (e) {
      _showErrorSnackbar('خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      setState(() => _isLoading = true);
      final List<XFile>? xFiles = await _picker.pickMultiImage();

      if (xFiles != null && xFiles.isNotEmpty) {
        final files = <File>[];

        for (final xFile in xFiles) {
          final file = File(xFile.path);
          if (await file.exists()) {
            // إنشاء اسم ملف جديد لكل صورة
            String newFileName =
                "img_${DateTime.now().millisecondsSinceEpoch}_${files.length}.jpg";
            final newFile = await file.rename(
              file.parent.path + '/' + newFileName,
            );
            files.add(newFile);
          } else {
            log('الملف غير موجود: ${xFile.path}');
          }
        }

        setState(() {
          _newGalleryImages.addAll(files);
          _galleryListKey = UniqueKey();
          log('تم اختيار ${files.length} صورة للمعرض');
        });
      }
    } catch (e) {
      _showErrorSnackbar('خطأ في اختيار صور المعرض: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview(
    File file,
    StateSetter setState, {
    required bool isMain,
    int? index,
  }) {
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return Container(
            width: isMain ? 150 : 100,
            height: isMain ? 150 : 100,
            color: Colors.grey[300],
            child: const Icon(Icons.error_outline, color: Colors.red),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  width: isMain ? 150 : 100,
                  height: isMain ? 150 : 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      if (isMain) {
                        _mainImage = null;
                      } else {
                        _newGalleryImages.removeAt(index!);
                        _galleryListKey = UniqueKey();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkImagePreview(
    String url,
    StateSetter setState, {
    required bool isMain,
    int? index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: isMain ? 150 : 100,
              height: isMain ? 150 : 100,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          if (!isMain)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                onPressed: () {
                  setState(() {
                    _existingGalleryUrls.removeAt(index!);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryImagesPreview(StateSetter setStateDialog) {
    if (_newGalleryImages.isEmpty && _existingGalleryUrls.isEmpty) {
      return const SizedBox();
    }

    final total = _newGalleryImages.length + _existingGalleryUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // مهم داخل Dialog
      children: [
        const SizedBox(height: 8),
        const Text(
          'صور المعرض:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // قيد الارتفاع بواسطة SizedBox، واستخدم SingleChildScrollView + Row
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            key: _galleryListKey,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(total, (index) {
                if (index < _newGalleryImages.length) {
                  final file = _newGalleryImages[index];
                  return _buildImagePreview(
                    file,
                    setStateDialog,
                    isMain: false,
                    index: index,
                  );
                } else {
                  final urlIndex = index - _newGalleryImages.length;
                  final url = _existingGalleryUrls[urlIndex];
                  return _buildNetworkImagePreview(
                    url,
                    setStateDialog,
                    isMain: false,
                    index: urlIndex,
                  );
                }
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _addNewProject() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final technologiesController = TextEditingController();
    final githubUrlController = TextEditingController();
    final liveUrlController = TextEditingController();

    _mainImage = null;
    _newGalleryImages.clear();
    _existingGalleryUrls.clear();
    _galleryListKey = UniqueKey();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              'إضافة مشروع جديد',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف*',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: technologiesController,
                    decoration: const InputDecoration(
                      labelText: 'التقنيات (مفصولة بفواصل)*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: githubUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط GitHub',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: liveUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الموقع',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickMainImage();
                      setStateDialog(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: Text(
                      _mainImage != null
                          ? 'تغيير الصورة'
                          : 'اختر الصورة الرئيسية',
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_mainImage != null)
                    _buildImagePreview(
                      _mainImage!,
                      setStateDialog,
                      isMain: true,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickGalleryImages();
                      setStateDialog(() {});
                    },
                    icon: const Icon(Icons.collections),
                    label: const Text('اختر صور المعرض'),
                  ),
                  _buildGalleryImagesPreview(setStateDialog),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      technologiesController.text.isEmpty) {
                    _showErrorSnackbar('املأ جميع الحقول المطلوبة');
                    return;
                  }

                  try {
                    setState(() => _isLoading = true);

                    await _supabaseService.saveProject(
                      title: titleController.text,
                      description: descriptionController.text,
                      technologies: technologiesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      githubUrl: githubUrlController.text,
                      liveUrl: liveUrlController.text,
                      mainImage: _mainImage,
                      galleryImages: _newGalleryImages,
                    );

                    await _loadProjects();
                    if (mounted) Navigator.pop(context);
                    _showSuccessSnackbar('تم الإضافة بنجاح!');
                  } catch (e) {
                    _showErrorSnackbar('خطأ: $e');
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editProject(Map<String, dynamic> project) {
    final titleController = TextEditingController(text: project['title']);
    final descriptionController = TextEditingController(
      text: project['description'],
    );
    final technologiesController = TextEditingController(
      text: (project['technologies'] as List).join(', '),
    );
    final githubUrlController = TextEditingController(
      text: project['github_url'] ?? '',
    );
    final liveUrlController = TextEditingController(
      text: project['live_url'] ?? '',
    );

    _mainImage = null;
    _newGalleryImages.clear();
    _existingGalleryUrls = List<String>.from(
      project['gallery_image_urls'] ?? [],
    );
    _galleryListKey = UniqueKey();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              'تعديل المشروع',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف*',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: technologiesController,
                    decoration: const InputDecoration(
                      labelText: 'التقنيات (مفصولة بفواصل)*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: githubUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط GitHub',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: liveUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الموقع',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickMainImage();
                      setStateDialog(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: Text(
                      _mainImage != null
                          ? 'تغيير الصورة'
                          : 'اختر الصورة الرئيسية',
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_mainImage != null)
                    _buildImagePreview(
                      _mainImage!,
                      setStateDialog,
                      isMain: true,
                    )
                  else if (project['main_image_url'] != null)
                    _buildNetworkImagePreview(
                      project['main_image_url'],
                      setStateDialog,
                      isMain: true,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickGalleryImages();
                      setStateDialog(() {});
                    },
                    icon: const Icon(Icons.collections),
                    label: const Text('إضافة صور جديدة'),
                  ),
                  _buildGalleryImagesPreview(setStateDialog),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      technologiesController.text.isEmpty) {
                    _showErrorSnackbar('املأ جميع الحقول');
                    return;
                  }

                  try {
                    log('بدء تحديث المشروع');
                    setState(() => _isLoading = true);

                    await _supabaseService.updateProject(
                      id: project['id'],
                      title: titleController.text,
                      description: descriptionController.text,
                      technologies: technologiesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      githubUrl: githubUrlController.text,
                      liveUrl: liveUrlController.text,
                      mainImage: _mainImage,
                      galleryImages: _newGalleryImages,
                      keepOldMainImage: _mainImage == null,
                      keepOldGallery: _newGalleryImages.isEmpty,
                    );

                    await _loadProjects();
                    if (mounted) Navigator.pop(context);
                    _showSuccessSnackbar('تم التحديث!');
                  } catch (e) {
                    log('خطأ في تحديث المشروع: $e');
                    _showErrorSnackbar('خطأ: $e');
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteProject(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _supabaseService.deleteProject(id);
        await _loadProjects();
        _showSuccessSnackbar('تم الحذف');
      } catch (e) {
        _showErrorSnackbar('خطأ: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showGallery(Map<String, dynamic> project) {
    final List<String> allImages = [
      if (project['main_image_url'] != null) project['main_image_url'],
      ...(project['gallery_image_urls'] ?? []),
    ];

    if (allImages.isEmpty) {
      _showErrorSnackbar('لا توجد صور');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project['title']),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        allImages[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          return progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${allImages.length} صورة',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar('لا يمكن فتح الرابط');
      }
    } catch (e) {
      _showErrorSnackbar('خطأ: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: project['main_image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(project['main_image_url']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: project['main_image_url'] == null
                      ? const Icon(Icons.image)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  // Wrap the column with Expanded to constrain its width
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['title'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis, // Ensure text truncation
                        project['description'] ?? 'لا يوجد وصف',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 127, 127, 127),
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, // Add spacing between chips
              runSpacing: 8, // Add spacing between rows of chips
              children:
                  (project['technologies'] as List?)
                      ?.take(3)
                      .map((t) => Chip(label: Text(t)))
                      .toList() ??
                  [],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (project['github_url'] != null)
                      IconButton(
                        icon: const Icon(Icons.code),
                        onPressed: () => _launchUrl(project['github_url']),
                      ),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () => _showGallery(project),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editProject(project),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProject(project['id']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المشاريع'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addNewProject),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? const Center(child: Text('لا توجد مشاريع'))
          : RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _projects.length,
                itemBuilder: (context, index) =>
                    _buildProjectCard(_projects[index]),
              ),
            ),
    );
  }
}
