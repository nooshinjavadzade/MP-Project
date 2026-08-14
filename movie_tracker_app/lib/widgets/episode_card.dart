import 'package:flutter/material.dart';

class EpisodeCard extends StatefulWidget {
  final int episodeNumber;
  final String title;
  final String? overview;
  final int? runtime;
  final String? imageUrl;
  final bool isWatched;
  final VoidCallback onToggleWatched;

  const EpisodeCard({
    super.key,
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.runtime,
    this.imageUrl,
    this.isWatched = false,
    required this.onToggleWatched,
  });

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0x9900232F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x4D3C4949)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 128,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x4D3C4949)),
                      image: widget.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(widget.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFF193846),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Icon(Icons.play_circle_outline, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قسمت ${widget.episodeNumber.toString().padLeft(2, '0')} • ${widget.title.toUpperCase()} • ${widget.runtime ?? 0} دقیقه',
                          style: TextStyle(
                            color: _isExpanded ? const Color(0xFFF08DA5) : const Color(0xFFBCC9C8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: widget.onToggleWatched,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isWatched ? const Color(0xFFF08DA5) : Colors.transparent,
                        border: Border.all(
                          color: widget.isWatched ? const Color(0xFFF08DA5) : const Color(0xFF3C4949),
                          width: 2,
                        ),
                      ),
                      child: widget.isWatched
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            
            if (widget.overview != null && widget.overview!.isNotEmpty)
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topLeft,
                  heightFactor: _isExpanded ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Text(
                      widget.overview!,
                      style: const TextStyle(
                        color: Color(0xFFBCC9C8),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}