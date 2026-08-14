import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/admin/admin_presenter.dart';
import '../../models/admin.dart';

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

  void _showResolveDialog(BuildContext context, AdminPresenter presenter, AdminReportResponse report) {
    final TextEditingController noteController = TextEditingController(text: report.adminNote);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A323D),
          title: const Text(
            'Update Report',
            style: TextStyle(color: Color(0xFF3DE4E5), fontFamily: 'Plus Jakarta Sans'),
          ),
          content: TextField(
            controller: noteController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
            decoration: InputDecoration(
              hintText: 'Enter resolution note...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3DE4E5)),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final note = noteController.text.trim();
                Navigator.pop(context);
                
                await presenter.updateReport(
                  report.id,
                  AdminReportUpdate(
                    status: ReportStatus.resolved,
                    adminNote: note.isNotEmpty ? note : null,
                  ),
                );
                // Refresh list after update
                presenter.getReports();
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFF3DE4E5), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
                        adminNote: report.adminNote,
                        status: report.status.value,
                        onTap: () => _showResolveDialog(context, presenter, report),
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
  final String? adminNote;
  final String status;
  final VoidCallback onTap;

  const _ReportCard({
    required this.userName,
    required this.email,
    required this.reportedType,
    required this.reason,
    this.adminNote,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = status == 'resolved';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3DE4E5),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isResolved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isResolved ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isResolved ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
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
              if (adminNote != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Note:',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3DE4E5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adminNote!,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
