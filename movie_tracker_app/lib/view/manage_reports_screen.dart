import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/admin/admin_presenter.dart';

class ManageReportsScreen extends StatefulWidget {
  const ManageReportsScreen({super.key});

  @override
  State<ManageReportsScreen> createState() => _ManageReportsScreenState();
}

class _ManageReportsScreenState extends State<ManageReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPresenter>().getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF00161F),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF00161F).withOpacity(0.95),
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              height: 1,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Manage Reports',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3DE4E5),
            ),
          ),
          centerTitle: false,
        ),
        body: Consumer<AdminPresenter>(
          builder: (context, presenter, child) {
            if (presenter.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3DE4E5)));
            }
            
            final items = presenter.reportListResponse?.items ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 32.0),
              children: [
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No reports found.',
                        style: TextStyle(color: Color(0xFFA5B4BB)),
                      ),
                    ),
                  )
                else
                  ...items.map((report) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _ReportCard(
                        userName: report.user.username,
                        email: report.user.email,
                        reportedType: report.media.title ?? report.media.mediaType?.toString() ?? 'Media Item',
                        reason: report.description ?? report.reason.value,
                        onDelete: () => presenter.deleteReport(report.id),
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

class _ReportCard extends StatelessWidget {
  final String userName;
  final String email;
  final String reportedType;
  final String reason;
  final VoidCallback onDelete;

  const _ReportCard({
    required this.userName,
    required this.email,
    required this.reportedType,
    required this.reason,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A323D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3DE4E5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: Color(0xFFA5B4BB),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            reportedType.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'Reason: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                TextSpan(text: reason),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'DELETE',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF08DA5),
                side: const BorderSide(color: Color(0xFFF08DA5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
