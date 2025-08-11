import 'package:flutter/material.dart';
import 'package:portfolio_dashboard/screens/dashboard.dart';
import 'package:portfolio_dashboard/utils/supbase_services.dart';

void main() {
  // Initialize Supabase
  SupabaseService().initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahmoud Bakir Portfolio Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DashboardScreen(),
    );
  }
}
