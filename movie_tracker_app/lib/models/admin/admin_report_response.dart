import '../common/media_base.dart';
import '../common/pagination.dart';
import '../auth/user.dart';

enum ReportReason {
  inappropriateContent('inappropriate_content'),
  spam('spam'),
  copyright('copyright'),
  incorrectInfo('incorrect_info'),
  other('other');

  const ReportReason(this.value);
  final String value;

  static ReportReason fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inappropriate_content':
        return ReportReason.inappropriateContent;
      case 'spam':
        return ReportReason.spam;
      case 'copyright':
        return ReportReason.copyright;
      case 'incorrect_info':
        return ReportReason.incorrectInfo;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }
}

enum ReportStatus {
  pending('pending'),
  resolved('resolved'),
  dismissed('dismissed');

  const ReportStatus(this.value);
  final String value;

  static ReportStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}

class AdminReportResponse {
  final int id;
  final int mediaId;
  final int userId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final User? user;
  final MediaBase? media;

  const AdminReportResponse({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.reason,
    this.description,
    required this.status,
    this.adminNote,
    required this.createdAt,
    this.resolvedAt,
    this.user,
    this.media,
  });

  String get userName => user?.fullName ?? user?.username ?? 'کاربر #$userId';
  String get userEmail => user?.email ?? 'بدون ایمیل';
  String get mediaTitle => media?.title ?? 'مدیا #$mediaId';

  factory AdminReportResponse.fromJson(Map<String, dynamic> json) {
    return AdminReportResponse(
      id: json['id'],
      mediaId: json['media_id'],
      userId: json['user_id'],
      reason: ReportReason.fromString(json['reason']),
      description: json['description'],
      status: ReportStatus.fromString(json['status']),
      adminNote: json['admin_note'],
      createdAt: DateTime.parse(json['created_at']),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      media: json['media'] != null ? MediaBase.fromJson(json['media']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'media_id': mediaId,
    'user_id': userId,
    'reason': reason.value,
    'description': description,
    'status': status.value,
    'admin_note': adminNote,
    'created_at': createdAt.toIso8601String(),
    'resolved_at': resolvedAt?.toIso8601String(),
    'user': user?.toJson(),
    'media': media?.toJson(),
  };

  AdminReportResponse copyWith({User? user, MediaBase? media}) {
  return AdminReportResponse(
    id: id,
    mediaId: mediaId,
    userId: userId,
    reason: reason,
    description: description,
    status: status,
    adminNote: adminNote,
    createdAt: createdAt,
    resolvedAt: resolvedAt,
    user: user ?? this.user,
    media: media ?? this.media,
  );
}
}

class AdminReportUpdate {
  final ReportStatus status;
  final String? adminNote;

  const AdminReportUpdate({
    required this.status,
    this.adminNote,
  });

  factory AdminReportUpdate.fromJson(Map<String, dynamic> json) {
    return AdminReportUpdate(
      status: ReportStatus.fromString(json['status']),
      adminNote: json['admin_note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.value,
    'admin_note': adminNote,
  };
}

class AdminReportListResponse {
  final List<AdminReportResponse> items;
  final Pagination pagination;

  const AdminReportListResponse({
    required this.items,
    required this.pagination,
  });

  factory AdminReportListResponse.fromJson(Map<String, dynamic> json) {
    return AdminReportListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => AdminReportResponse.fromJson(e))
          .toList() ??
          const [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

