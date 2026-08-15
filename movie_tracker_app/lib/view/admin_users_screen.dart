import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 👇 ایمپورت‌های پروژه خود را چک کنید
import '../../models/admin.dart'; 
import '../presenters/admin/admin_presenter.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    // دریافت اولیه لیست کاربران
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPresenter>().getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final presenter = context.watch<AdminPresenter>();

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: _buildBodyContent(presenter),
        ),
      ),
    );
  }

  Widget _buildBodyContent(AdminPresenter presenter) {
    if (presenter.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5AD9D9)),
      );
    }

    if (presenter.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              presenter.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontFamily: 'Manrope'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AD9D9),
                foregroundColor: const Color(0xFF00161F),
              ),
              onPressed: () => context.read<AdminPresenter>().getUsers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = presenter.userListResponse?.items ?? [];

    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
          style: TextStyle(color: Color(0xFFBCC9C8), fontFamily: 'Manrope'),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(AdminUserResponse user) {
    final String displayName = (user.fullName != null && user.fullName!.isNotEmpty)
        ? user.fullName!
        : user.username;

    final String initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF001F2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A5AD9D9)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0x3329B5B5),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Color(0xFF5AD9D9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
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
                  displayName,
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
                    color: Color(0xCCBCC9C8),
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
              // دکمه تغییر وضعیت ادمین
              _buildIconButton(
                icon: Icons.admin_panel_settings,
                color: user.isAdmin ? const Color(0xFF5AD9D9) : Colors.grey,
                backgroundColor: const Color(0x3329B5B5),
                glow: user.isAdmin,
                onTap: () async {
                  final presenter = context.read<AdminPresenter>();
                  // ارسال درخواست به‌روزرسانی با معکوس کردن وضعیت ادمین
                  final updateRequest = AdminUserUpdate(isAdmin: !user.isAdmin);
                  
                  await presenter.updateUser(user.id, updateRequest);
                  
                  if (mounted) {
                    if (presenter.errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            user.isAdmin
                                ? '${user.username} is no longer an admin.'
                                : '${user.username} is now an admin.',
                          ),
                        ),
                      );
                      // به‌روزرسانی لیست برای نمایش آخرین تغییرات
                      presenter.getUsers();
                    }
                  }
                },
              ),
              const SizedBox(width: 8),

              // دکمه حذف کاربر
              _buildIconButton(
                icon: Icons.delete,
                color: const Color(0xFFFFB1C2),
                backgroundColor: const Color(0x33FFB1C2),
                onTap: () async {
                  final presenter = context.read<AdminPresenter>();
                  
                  await presenter.deleteUser(user.id);
                  
                  if (mounted) {
                    if (presenter.errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted ${user.username}.')),
                      );
                      // فراخوانی مجدد لیست پس از حذف موفق
                      presenter.getUsers();
                    }
                  }
                },
              ),
            ],
          ),
        ],
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