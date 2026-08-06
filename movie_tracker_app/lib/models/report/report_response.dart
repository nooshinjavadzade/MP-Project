import 'report_enums.dart';
import '../common/pagination.dart';

class ReportCreate {
  final ReportReason reason;
  final String? description;

  const ReportCreate({
    required this.reason,
    this.description,
  });

  factory ReportCreate.fromJson(Map<String, dynamic> json) {
    return ReportCreate(
      reason: ReportReason.fromString(json['reason']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'reason': reason.value,
    'description': description,
  };
}

class ReportResponse {
  final int id;
  final int mediaId;
  final int userId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ReportResponse({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.reason,
    this.description,
    required this.status,
    this.adminNote,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
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
  };
}

class ReportListResponse {
  final List<ReportResponse> items;
  final Pagination pagination;

  const ReportListResponse({
    required this.items,
    required this.pagination,
  });

  factory ReportListResponse.fromJson(Map<String, dynamic> json) {
    return ReportListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ReportResponse.fromJson(e))
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