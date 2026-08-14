import 'package:flutter/material.dart';
import 'dart:ui';

class DummyUser {
  final String name;
  final String email;
  final String? initials;
  final String? imageUrl;

  DummyUser({
    required this.name,
    required this.email,
    this.initials,
    this.imageUrl,
  });
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final List<DummyUser> _users = [
    DummyUser(
      name: 'Alex Rivers',
      email: 'alex.rivers@ocean-glow.com',
      initials: 'AR',
    ),
    DummyUser(
      name: 'Jordan Lee',
      email: 'jordan.l@ocean-glow.com',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDP9qnW0nJ2QBvmme7M-7BpsyjwKTg1WD5F5Jhn2U6oWWTwClBc2YWt6pyC9ZoXzC6X1_1lQU3-zvfTJSo98Yp-oeD98vCxSCz_pDJjmLbCrHw43iQxQgISiAriBLvJ0TqzpFrIPpXC5L2Qm4KNT2_9RiMTvBmUkjw8cbgUazv3oH6eV2lQWvJZ5lUXNpymsKtxL6xrD9ITSaC4S3H5cFTjfSxh7mcqTK3lmFoIrDU2BzYO0hu7qZE3fw',
    ),
    DummyUser(
      name: 'Sam Waverly',
      email: 'sam.w@ocean-glow.com',
      initials: 'SW',
    ),
    DummyUser(
      name: 'Casey Morgan',
      email: 'casey.morgan@ocean-glow.com',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCo0NQWEq6rBp2D3dNDS3oRI_xxF1u3NvgN3Ao1J2KkvSCX3gSklZy5DdX-A3wAJkJeJ-tuSV2fySnB9_kxYwLhuZSHTe1a6UvAE4X6lcmQQbFvPun0FLETcy2OYBMCi1ywJ062eCgyN2hZ1WFxRS_nvTU0yQBYKfBwak12f0SFfGfjRES2_P7iQdKQlhzN8dQnhKSi-jOzTkbvghtaLCH2mj2dw1YAXLzBcVLa5SNxuDIy5Sob2i46qg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: const Color(0x99193846),
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFBCC9C8)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'User Management',
                style: TextStyle(
                  color: Color(0xFF5AD9D9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: const Color(0x333C4949),
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF001F2A),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0x335AD9D9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const TextField(
                  style: TextStyle(color: Color(0xFFC7E7F8), fontFamily: 'Manrope'),
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    hintStyle: TextStyle(color: Color(0xFFBCC9C8), fontFamily: 'Manrope'),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF5AD9D9)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // User List
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return _buildUserCard(user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(DummyUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(15, 95, 102, 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x335AD9D9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 30,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF193846),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x4D5AD9D9)),
                  ),
                  child: ClipOval(
                    child: user.imageUrl != null
                        ? Image.network(
                            user.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFF5AD9D9)),
                          )
                        : Center(
                            child: Text(
                              user.initials ?? '',
                              style: const TextStyle(
                                color: Color(0xFF5AD9D9),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Color(0xFF5AD9D9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Color(0xCCBCC9C8), // 80% opacity of on-surface-variant
                          fontSize: 14,
                          fontFamily: 'Manrope',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(
                      icon: Icons.admin_panel_settings,
                      color: const Color(0xFF5AD9D9),
                      backgroundColor: const Color(0x3329B5B5),
                      glow: true,
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('${user.name} is now an admin.')),
                         );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      icon: Icons.delete,
                      color: const Color(0xFFFFB1C2), // tertiary
                      backgroundColor: const Color(0x33FFB1C2), // tertiary / 20
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Deleted ${user.name}.')),
                         );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    bool glow = false,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
