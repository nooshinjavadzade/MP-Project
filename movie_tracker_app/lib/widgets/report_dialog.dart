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

  static const Map<ReportReason, String> _reasonLabels = {
    ReportReason.inappropriateContent: 'محتوای نامناسب',
    ReportReason.spam: 'اسپم',
    ReportReason.copyright: 'نقض کپی‌رایت',
    ReportReason.incorrectInfo: 'اطلاعات نادرست',
    ReportReason.other: 'سایر',
  };

  @override
  void initState() {
    super.initState();
    // 🔹 مطمئن می‌شیم هربار دیالوگ باز می‌شه، فرم پاک باشه (چون presenter مشترکه)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportPresenter>().resetReportForm();
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submitReport(ReportPresenter presenter) {
    if (!presenter.canSubmitReport) return;
    presenter.submitReport(
      mediaType: widget.mediaType,
      tmdbId: widget.tmdbId,
      reason: presenter.selectedReason!,
      description: presenter.selectedReason == ReportReason.other
          ? presenter.description.trim()
          : null,
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
          child: Consumer<ReportPresenter>(
            builder: (context, presenter, child) {
              return Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
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
                child: SingleChildScrollView(
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
                      const SizedBox(height: 20),
                      const Text(
                        'دلیل گزارش',
                        style: TextStyle(
                          color: Color(0xFFBCC9C8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 8),

                      ..._reasonLabels.entries.map((entry) {
                        final reason = entry.key;
                        final label = entry.value;
                        final isSelected = presenter.selectedReason == reason;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => presenter.selectReportReason(reason),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF08DA5).withOpacity(0.15)
                                    : const Color(0x80193846),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF08DA5)
                                      : const Color(0x4D3C4949),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    size: 18,
                                    color: isSelected ? const Color(0xFFF08DA5) : const Color(0xFFBCC9C8),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFF08DA5) : const Color(0xFFC7E7F8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      if (presenter.selectedReason == ReportReason.other) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'توضیحات',
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
                            maxLines: 4,
                            onChanged: presenter.updateReportDescription,
                            style: const TextStyle(
                              color: Color(0xFFC7E7F8),
                              fontSize: 16,
                              fontFamily: 'Manrope',
                            ),
                            decoration: InputDecoration(
                              hintText: 'لطفاً دلیل رو توضیح بده...',
                              hintStyle: TextStyle(
                                color: const Color(0xFFBCC9C8).withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],

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
                              onPressed: (presenter.canSubmitReport && !presenter.isLoading)
                                  ? () => _submitReport(presenter)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFFF08DA5),
                                disabledBackgroundColor: const Color(0xFFF08DA5).withOpacity(0.3),
                                elevation: 0,
                                shadowColor: const Color(0xFFF08DA5).withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: presenter.isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF3F0018),
                                      ),
                                    )
                                  : const Text(
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
              );
            },
          ),
        ),
      ),
    );
  }
}