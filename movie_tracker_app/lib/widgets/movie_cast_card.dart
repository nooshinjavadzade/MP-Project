import 'package:flutter/material.dart';
import 'dart:ui';

// یک مدل ساده برای کستینگ چون ممکنه ساختار دقیق رو نداشته باشیم
class CastMember {
  final String name;
  final String role;
  final String? imageUrl;
  final Color borderColor;

  CastMember({
    required this.name, 
    required this.role, 
    this.imageUrl,
    required this.borderColor,
  });
}

class MovieCastCard extends StatelessWidget {
  final List<CastMember> cast;

  const MovieCastCard({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return const SizedBox.shrink(); // نمایش هیچ چیزی در صورت خالی بودن لیست
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0x9900232F),
            border: Border.all(color: const Color(0x33869393)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFFF08DA5), // coral-pink
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Main Cast',
                  style: TextStyle(
                    color: Color(0xFFF08DA5),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: cast.map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: member.borderColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: member.imageUrl != null
                              ? Image.network(
                                  member.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                                )
                              : Container(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  color: Color(0xFFC7E7F8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              Text(
                                member.role,
                                style: const TextStyle(
                                  color: Color(0xFFBCC9C8),
                                  fontSize: 12,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


