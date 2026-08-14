import 'package:flutter/material.dart';
import 'manage_cache_screen.dart';
import 'manage_reports_screen.dart';
import 'manage_reviews_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00161F).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFBCC9C8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF29B5B5),
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          _AdminCard(
            title: 'Users',
            subtitle: 'Manage user accounts and permissions',
            icon: Icons.group,
            iconColor: const Color(0xFF29B5B5),
            onTap: () {
              // TODO: Navigate to Users Management
            },
          ),
          const SizedBox(height: 16),
          _AdminCard(
            title: 'Cache Media',
            subtitle: 'Update titles, metadata, and posters',
            icon: Icons.movie,
            iconColor: const Color(0xFFF08DA5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageCacheScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _AdminCard(
            title: 'Reports',
            subtitle: 'View analytics and user activity logs',
            icon: Icons.analytics,
            iconColor: const Color(0xFFF08DA5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageReportsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _AdminCard(
            title: 'Reviews',
            subtitle: 'Moderate user comments and ratings',
            icon: Icons.rate_review,
            iconColor: const Color(0xFF29B5B5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageReviewsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF00232F).withOpacity(0.6), // surface-container
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF29B5B5).withOpacity(0.2), // primary border
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC7E7F8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Color(0xFFBCC9C8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
