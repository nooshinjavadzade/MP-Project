import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_content.dart';
import '../../../models/common/media_type.dart';
import '../../../presenters/progress/progress_presenter.dart';
import '../../../services/local/local_storage_service.dart';

class WatchlistCard extends StatefulWidget {
  final PersonalListItemResponse item;
  final VoidCallback? onTap;

  const WatchlistCard({super.key, required this.item, this.onTap});

  @override
  State<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<WatchlistCard> {
  late final LocalStorageService _localStorageService;

  SeriesProgressResponse? _seriesProgress;
  bool _isLoadingProgress = false;
  bool _isDropped = false;

  bool get _isSeries => widget.item.media.mediaType != MediaType.movie;
  int get _tmdbId => int.tryParse(widget.item.media.tmdbId) ?? widget.item.media.id;

  @override
  void initState() {
    super.initState();
    _localStorageService = context.read<LocalStorageService>();
    if (_isSeries) {
      _loadSeriesProgress();
    }
  }

  Future<void> _loadSeriesProgress() async {
    setState(() => _isLoadingProgress = true);
    try {
      final presenter = context.read<ProgressPresenter>();
      final result = await presenter.getSeriesProgress(_tmdbId);
      
      String? cachedStatus;
      try {
        cachedStatus = _localStorageService.getMediaWatchStatus(_tmdbId.toString());
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        if (result != null) {
          _seriesProgress = result;
        }
        _isDropped = cachedStatus == WatchStatus.dropped.value;
      });
    } catch (e) {
      if (!mounted) return;
      String? cachedStatus;
      List<String> cachedWatched = const [];
      try {
        cachedStatus = _localStorageService.getMediaWatchStatus(_tmdbId.toString());
        cachedWatched = _localStorageService.getWatchedEpisodes(_tmdbId.toString());
      } catch (_) {}

      setState(() {
        _seriesProgress = SeriesProgressResponse(
          mediaId: _tmdbId,
          title: '',
          totalEpisodes: 0,
          watchedEpisodes: cachedWatched.length,
          completionPct: 0.0,
          status: cachedStatus != null
              ? WatchStatusExtension.fromString(cachedStatus)
              : WatchStatus.watching,
        );
        _isDropped = cachedStatus == WatchStatus.dropped.value;
      });
    } finally {
      if (mounted) setState(() => _isLoadingProgress = false);
    }
  }

  double get _progressPercent {
    final progress = _seriesProgress;
    if (progress == null || progress.totalEpisodes <= 0) return 0.0;
    return (progress.watchedEpisodes / progress.totalEpisodes).clamp(0.0, 1.0);
  }

  bool get _isCompleted => _progressPercent >= 1.0 && (_seriesProgress?.totalEpisodes ?? 0) > 0;
  bool get _hasStarted => _progressPercent > 0.0;

  Color get _progressColor {
    if (!_hasStarted) return const Color(0xFFBCC9C8).withOpacity(0.3); // طوسی اگر شروع نشده
    if (_isCompleted) return const Color(0xFF4CAF50); // سبز اگر تکمیل شده
    if (_isDropped) return const Color(0xFFE53935); // قرمز اگر متوقف شده
    return const Color(0xFFFFB300); // زرد اگر در حال تماشا است
  }

  String get _progressLabel {
    if (!_hasStarted) return 'شروع نشده';
    if (_isCompleted) return 'تکمیل شده';
    if (_isDropped) return 'متوقف شده';
    return 'در حال تماشا';
  }

  Future<void> _toggleDropped() async {
    final newValue = !_isDropped;
    setState(() => _isDropped = newValue);
    try {
      await _localStorageService.setMediaWatchStatus(
        _tmdbId.toString(),
        newValue ? WatchStatus.dropped.value : WatchStatus.watching.value,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isSeries) {
      // گوش دادن به تغییرات Presenter تا اگر در صفحه جزییات قسمتی علامت‌گذاری شد، این کارت آپدیت شود.
      context.watch<ProgressPresenter>();
      
      // تلاش برای خواندن دیتای جدید از LocalStorage به صورت آنی
      try {
        final cachedWatched = _localStorageService.getWatchedEpisodes(_tmdbId.toString());
        if (_seriesProgress != null && _seriesProgress!.watchedEpisodes != cachedWatched.length && cachedWatched.isNotEmpty) {
           _seriesProgress = SeriesProgressResponse(
             mediaId: _seriesProgress!.mediaId,
             title: _seriesProgress!.title,
             totalEpisodes: _seriesProgress!.totalEpisodes,
             watchedEpisodes: cachedWatched.length,
             completionPct: _seriesProgress!.totalEpisodes > 0 ? (cachedWatched.length / _seriesProgress!.totalEpisodes) : 0.0,
             status: _seriesProgress!.status,
           );
        }
      } catch (_) {}
    }

    final item = widget.item;
    final String title = item.media.title.isNotEmpty ? item.media.title : 'عنوان ناشناخته';
    final String subtitle =
        'افزوده شده در: ${item.addedAt.year}-${item.addedAt.month.toString().padLeft(2, '0')}-${item.addedAt.day.toString().padLeft(2, '0')}';
    final String? imageUrl = item.media.posterUrl;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C2E3B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8DE6E3).withOpacity(0.1),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF00161F),
                            child: const Icon(Icons.broken_image, color: Colors.white30, size: 40),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF00161F),
                          child: const Icon(Icons.image_not_supported, color: Colors.white30, size: 40),
                        ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF00161F).withOpacity(0.9),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),
                  ),
                  if (_isSeries && _isCompleted)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'تکمیل شده',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  
                  // نوار پیشرفت (اکنون برای تمام سریال‌ها نمایش داده می‌شود)
                  if (_isSeries && !_isLoadingProgress)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        color: const Color(0xFF001018), 
                        alignment: Alignment.centerRight, 
                        child: FractionallySizedBox(
                          widthFactor: _progressPercent > 0 ? _progressPercent : 0.02, // حتی اگر 0 درصد باشد یک نوار کوچک طوسی می اندازد
                          child: Container(
                            decoration: BoxDecoration(
                              color: _progressColor,
                              boxShadow: [
                                BoxShadow(
                                  color: _progressColor.withOpacity(0.5),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC7E7F8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: Color(0xFFBCC9C8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (_isSeries) ...[
                    const SizedBox(height: 12),
                    if (_isLoadingProgress)
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(9999)),
                        child: SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            backgroundColor: Color(0xFF001018),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29B5B5)),
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _progressLabel.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _hasStarted ? _progressColor : const Color(0xFFBCC9C8).withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '${(_progressPercent * 100).toInt()}%',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _hasStarted ? _progressColor : const Color(0xFFBCC9C8).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      
                      // دکمه توقف تماشا اکنون برای تمام سریال‌های ناتمام نمایش داده می‌شود
                      if (!_isCompleted) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleDropped,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isDropped ? Icons.refresh : Icons.pause_circle_outline,
                                size: 14,
                                color: _isDropped ? const Color(0xFFE53935) : const Color(0xFFBCC9C8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isDropped ? 'ازسرگیری تماشا' : 'توقف تماشا',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  color: _isDropped ? const Color(0xFFE53935) : const Color(0xFFBCC9C8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}