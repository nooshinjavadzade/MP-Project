import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/auth/auth_presenter.dart';
import '../../models/auth/user.dart';
import 'login_screen.dart';
import '../widgets/edit_profile_dialog.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthPresenter>(
      builder: (context, presenter, _) {
        final user = presenter.authResponse?.user;
        
        // GUEST VIEW (Just a login button as requested)
        if (user == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF00161F),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF08DA5),
                  foregroundColor: const Color(0xFF3F0018),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Log In / Sign Up',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        // LOGGED IN USER VIEW
        return Scaffold(
          backgroundColor: const Color(0xFF00161F),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 64, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // Profile Header Section
                    _buildProfileHeader(context, user),
                    const SizedBox(height: 40),
                    
                    // Stats Grid Section
                    _buildStatsGrid(),
                    const SizedBox(height: 40),
                    
                    // Settings Toggles (Biometric + Admin)
                    _buildSettings(context, user, presenter),
                    const SizedBox(height: 40),

                    // Watching Section
                    _buildSectionTitle('Watching'),
                    const SizedBox(height: 16),
                    _buildWatchingList(),
                    const SizedBox(height: 40),

                    // Recently Watched Section
                    _buildSectionTitle('Recently Watched'),
                    const SizedBox(height: 16),
                    _buildRecentlyWatchedList(),
                    const SizedBox(height: 40),

                    // Favorite Items Section
                    _buildSectionTitle('Favorite Discoveries'),
                    const SizedBox(height: 20),
                    _buildFavoritesGrid(),

                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFF00232F),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6C5FA6).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5FA6).withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF8DE6E3),
              ),
            ),
            GestureDetector(
              onTap: () => _showEditProfileDialog(context, user),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF08DA5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color(0xFF3F0018),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          (user.fullName != null && user.fullName!.isNotEmpty) ? user.fullName! : user.username,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8DE6E3),
            letterSpacing: -1,
          ),
        ),
        Text(
          user.email,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            color: Color(0xFFBCC9C8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF8DE6E3),
          ),
        ),
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '"${user.bio}"',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFBCC9C8).withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('124', 'Movies Watched')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('42', 'Series Watched')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8DE6E3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFFBCC9C8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, User user, AuthPresenter presenter) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Authentication',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8DE6E3),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Enable fingerprint or face recognition',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: Color(0xFFBCC9C8),
                    ),
                  ),
                ],
              ),
              Switch(
                value: presenter.isBiometricEnabled,
                onChanged: (val) => presenter.setBiometricEnabled(val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF29B5B5),
                inactiveThumbColor: const Color(0xFF869393),
                inactiveTrackColor: const Color(0xFF193846),
              ),
            ],
          ),
        ),
        if (user.isAdmin) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _glassDecoration().copyWith(
                border: Border.all(color: const Color(0xFFF08DA5).withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Administration',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF08DA5),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage platform and users',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: Color(0xFFBCC9C8),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.admin_panel_settings, color: Color(0xFFF08DA5)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        InkWell(
          onTap: () => presenter.logout(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _glassDecoration(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Color(0xFFBCC9C8)),
                SizedBox(width: 8),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBCC9C8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8DE6E3),
        ),
      ),
    );
  }

  Widget _buildWatchingList() {
    final items = [
      {'title': 'The Expanse', 'progress': 0.65},
      {'title': 'Foundation', 'progress': 0.20},
      {'title': 'Dark', 'progress': 0.90},
    ];

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 128,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 192,
                  decoration: _glassDecoration(),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Container(
                        color: const Color(0xFF0C2E3B),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 40,
                            color: const Color(0xFF6C5FA6).withOpacity(0.4),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 4,
                        child: Container(
                          color: const Color(0xFF00232F),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: item['progress'] as double,
                            child: Container(color: const Color(0xFFF08DA5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC7E7F8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentlyWatchedList() {
    final items = ['Inception', 'Interstellar', 'Arrival', 'Dune'];

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 144,
                  decoration: _glassDecoration(),
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    color: const Color(0xFF0C2E3B),
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 24,
                        color: const Color(0xFF6C5FA6).withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  items[index],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFBCC9C8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    final items = [
      {'title': 'Midnight Echo', 'genre': 'Sci-Fi Thriller'},
      {'title': 'Abyssal Dreams', 'genre': 'Documentary'},
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2 / 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: _glassDecoration(),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color(0xFF0C2E3B),
                child: Center(
                  child: Icon(
                    Icons.movie_outlined,
                    size: 60,
                    color: const Color(0xFF6C5FA6).withOpacity(0.4),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF00161F), Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8DE6E3),
                        ),
                      ),
                      Text(
                        item['genre']!,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          color: Color(0xFFBCC9C8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0C2E3B).withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF8DE6E3).withOpacity(0.1),
      ),
    );
  }
}

