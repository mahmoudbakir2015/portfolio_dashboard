import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart';

class SpokenLanguagesScreen extends StatefulWidget {
  const SpokenLanguagesScreen({super.key});

  @override
  State<SpokenLanguagesScreen> createState() => _SpokenLanguagesScreenState();
}

class _SpokenLanguagesScreenState extends State<SpokenLanguagesScreen> {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> _languages = [];
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();
  double _selectedProficiency = 50;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguages() async {
    try {
      setState(() => _isLoading = true);
      final languages = await _supabase.getSpokenLanguages();
      setState(() {
        _languages = languages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load languages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spoken Languages'),
        actions: [
          if (_languages.any((lang) => lang['isSelected']))
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteSelectedLanguages,
              tooltip: 'Delete selected',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAddLanguageCard(),
                    const SizedBox(height: 20),
                    _buildLanguagesList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAddLanguageCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Spoken Language',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languageController,
                decoration: InputDecoration(
                  labelText: 'Language',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.language),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _languageController.clear(),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a language';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proficiency: ${_selectedProficiency.round()}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: _selectedProficiency,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: '${_selectedProficiency.round()}%',
                    onChanged: (value) {
                      setState(() {
                        _selectedProficiency = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addLanguage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('ADD LANGUAGE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagesList() {
    if (_languages.isEmpty) {
      return const Center(child: Text('No languages added yet'));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'My Languages',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_languages.where((lang) => lang['isSelected']).length} selected',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return _buildLanguageTile(language, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, dynamic> language, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                language['icon'],
                color: Theme.of(context).primaryColor,
              ),
              title: Text(language['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteLanguage(index),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${language['proficiency'].round()}%'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: language['proficiency'] / 100,
                    backgroundColor: Colors.grey[300],
                    color: Theme.of(context).primaryColor,
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addLanguage() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        final newLanguage = {
          'name': _languageController.text,
          'proficiency': _selectedProficiency.toInt(), // تحويل إلى integer
          'icon': _getLanguageIcon(_languageController.text),
          'isSelected': true,
        };

        await _supabase.saveSpokenLanguages([..._languages, newLanguage]);

        setState(() {
          _languages.add(newLanguage);
          _languageController.clear();
          _selectedProficiency = 50;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Failed to add language: $e');
      }
    }
  }

  Future<void> _deleteLanguage(int index) async {
    final languageName = _languages[index]['name'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete $languageName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        _languages.removeAt(index);
        await _supabase.saveSpokenLanguages(_languages);
        setState(() => _isLoading = false);
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Failed to delete language: $e');
      }
    }
  }

  Future<void> _deleteSelectedLanguages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Delete all selected languages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        _languages.removeWhere((lang) => lang['isSelected']);
        await _supabase.saveSpokenLanguages(_languages);
        setState(() => _isLoading = false);
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Failed to delete languages: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  IconData _getLanguageIcon(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'arabic':
        return Icons.language;
      case 'english':
        return Icons.translate;
      case 'french':
        return Icons.flag;
      case 'spanish':
        return Icons.flag_outlined;
      case 'german':
        return Icons.language_outlined;
      default:
        return Icons.language;
    }
  }
}
