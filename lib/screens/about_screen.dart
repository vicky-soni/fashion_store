import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Fashion Store'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppTheme.primary),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'FASHION STORE',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Style, Your Identity.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 30),

            _section(
              'About the Application',
              'Fashion Store is a clothing e-commerce demo '
              'application developed as an academic project. '
              'Users can explore products, manage their cart, '
              'place demo orders and view order history.',
            ),

            const SizedBox(height: 16),

            _section(
              'Technology Used',
              'Flutter, Dart, SQLite, Provider, '
              'Shared Preferences and Material Design.',
            ),

            const SizedBox(height: 16),

            _section(
              'Developer Details',
              'Developer: Vicky Soni\n'
              'Course: Master of Computer Applications (MCA)\n'
              'Project: Fashion Store E-Commerce Application\n'
              'Project Type: Academic Project',
            ),

            const SizedBox(height: 25),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Made with Flutter',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              height: 1.6,
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}