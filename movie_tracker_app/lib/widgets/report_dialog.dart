import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../../presenters/report/report_presenter.dart';
import '../../../../models/report.dart';

class ReportDialog extends StatefulWidget {
  final int tmdbId;
  final String mediaType;

  const ReportDialog({
    super.key,
    required this.tmdbId,
    required this.mediaType,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submitReport() {
    context.read<ReportPresenter>().submitReport(
      mediaType: widget.mediaType,
      tmdbId: widget.tmdbId,
      reason: ReportReason.spam,
      description: _detailsController.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xCC00232F),
              border: Border.all(color: const Color(0x335AD9D9)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5AD9D9).withOpacity(0.15),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'گزارش محتوا',
                  style: TextStyle(
                    color: Color(0xFF5AD9D9),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'جزئیات بیشتر',
                  style: TextStyle(
                    color: Color(0xFFBCC9C8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x80193846),
                    border: Border.all(color: const Color(0x4D3C4949)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _detailsController,
                    maxLines: 5,
                    style: const TextStyle(
                      color: Color(0xFFC7E7F8),
                      fontSize: 16,
                      fontFamily: 'Manrope',
                    ),
                    decoration: InputDecoration(
                      hintText: 'جزئیات بیشتر (اختیاری)...',
                      hintStyle: TextStyle(
                        color: const Color(0xFFBCC9C8).withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0x66193846),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0x4D3C4949)),
                          ),
                        ),
                        child: const Text(
                          'انصراف',
                          style: TextStyle(
                            color: Color(0xFFBCC9C8),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF08DA5),
                          elevation: 0,
                          shadowColor: const Color(0xFFF08DA5).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ارسال گزارش',
                          style: TextStyle(
                            color: Color(0xFF3F0018),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
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
}