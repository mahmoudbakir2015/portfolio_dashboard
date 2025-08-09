import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart'
    show SupabaseService;

class ProjectsManagementScreen extends StatefulWidget {
  const ProjectsManagementScreen({super.key});

  @override
  State<ProjectsManagementScreen> createState() =>
      _ProjectsManagementScreenState();
}

class _ProjectsManagementScreenState extends State<ProjectsManagementScreen> {
  late List<Map<String, dynamic>> _projects;
  final SupabaseService supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _projects = [
      {
        'id': 1,
        'title': 'E-commerce App',
        'description':
            'Full-featured e-commerce application with payment integration',
        'image': 'assets/images/project1.jpg',
        'technologies': ['Flutter', 'Firebase', 'Stripe'],
        'githubUrl': 'https://github.com/example/ecommerce    ',
        'liveUrl': 'https://example.com/ecommerce    ',
      },
      {
        'id': 2,
        'title': 'Task Management App',
        'description': 'Productivity app for managing tasks and projects',
        'image': 'assets/images/project2.jpg',
        'technologies': ['Flutter', 'Firestore', 'Provider'],
        'githubUrl': 'https://github.com/example/taskmanager    ',
        'liveUrl': 'https://example.com/taskmanager    ',
      },
    ];
  }

  void _addNewProject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        final TextEditingController technologiesController =
            TextEditingController();

        return AlertDialog(
          title: Text(
            'Add New Project',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Project Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Technologies (comma separated)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();
                final String technologies = technologiesController.text.trim();

                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    await supabaseService.saveProject(
                      title: title,
                      description: description,
                      technologies: technologies
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project added successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding project: $e')),
                    );
                  }
                }
              },
              child: Text('Add', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Projects Management'),
              _buildFloatingActionButton(
                icon: Icons.add,
                onPressed: _addNewProject,
                label: 'Add Project',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 3,
              ),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(_projects[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                    project['image'] ?? 'assets/images/project_default.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    project['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    project['description'].substring(0, 50) + '...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () {
                          // Edit project functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () {
                          // Delete project functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
      label: Text(label, style: GoogleFonts.poppins()),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
