import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/admin/admin_presenter.dart';

class ManageCacheScreen extends StatefulWidget {
  const ManageCacheScreen({super.key});

  @override
  State<ManageCacheScreen> createState() => _ManageCacheScreenState();
}

class _ManageCacheScreenState extends State<ManageCacheScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPresenter>().getCachedMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF00161F),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF00232F).withOpacity(0.6),
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5AD9D9)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Manage Cache',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AD9D9),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
        ),
        body: Consumer<AdminPresenter>(
          builder: (context, presenter, child) {
            if (presenter.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF5AD9D9)));
            }

            final items = presenter.cachedMediaListResponse?.items ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 32.0),
              children: [
                const Text(
                  'Cached Items',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC7E7F8),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review and clear temporary files.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: Color(0xFFBCC9C8),
                  ),
                ),
                const SizedBox(height: 24),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No cached items found.',
                        style: TextStyle(color: Color(0xFFBCC9C8)),
                      ),
                    ),
                  )
                else
                  ...items.map((item) {
                    IconData iconData = Icons.movie;
                    if (item.mediaType.toLowerCase() == 'tv') iconData = Icons.tv;
                    if (item.mediaType.toLowerCase() == 'person') iconData = Icons.person;
                    
                    final dateStr = "\${item.lastFetchedAt.year}-\${item.lastFetchedAt.month.toString().padLeft(2, '0')}-\${item.lastFetchedAt.day.toString().padLeft(2, '0')}";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _CacheItemCard(
                        title: item.title,
                        size: item.mediaType.toUpperCase(),
                        date: dateStr,
                        icon: iconData,
                        onDelete: () => presenter.deleteCachedMedia(item.id),
                      ),
                    );
                  }).toList(),
              ],
            );
          },
        ),
    );
  }
}

class _CacheItemCard extends StatelessWidget {
  final String title;
  final String size;
  final String date;
  final IconData icon;
  final VoidCallback onDelete;

  const _CacheItemCard({
    required this.title,
    required this.size,
    required this.date,
    required this.icon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F5F66).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5AD9D9).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0C2E3B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF5AD9D9), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    color: Color(0xFFC7E7F8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      size.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFFBCC9C8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3C4949),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFFBCC9C8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF93000A).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete, color: Color(0xFFFFB4AB), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
