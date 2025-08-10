import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpokenLanguagesScreen extends StatefulWidget {
  const SpokenLanguagesScreen({super.key});

  @override
  State<SpokenLanguagesScreen> createState() => _SpokenLanguagesScreenState();
}

class _SpokenLanguagesScreenState extends State<SpokenLanguagesScreen> {
  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'Arabic',
      'proficiency': 100,
      'icon': Icons.language,
      'isSelected': true,
    },
    {
      'name': 'English',
      'proficiency': 85,
      'icon': Icons.translate,
      'isSelected': true,
    },
  ];

  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();
  double _selectedProficiency = 50;

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
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
      body: Padding(
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

  void _addLanguage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _languages.add({
          'name': _languageController.text,
          'proficiency': _selectedProficiency,
          'icon': _getLanguageIcon(_languageController.text),
          'isSelected': true,
        });
        _languageController.clear();
        _selectedProficiency = 50;
      });
    }
  }

  void _deleteLanguage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${_languages[index]['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _languages.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedLanguages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Delete all selected languages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _languages.removeWhere((lang) => lang['isSelected']);
              });
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
