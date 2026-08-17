import '../auth/user.dart';
import '../common/media_base.dart';
import '../common/pagination.dart';
import 'report_enums.dart';

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

  ReportCreate copyWith({
    ReportReason? reason,
    String? description,
  }) {
    return ReportCreate(
      reason: reason ?? this.reason,
      description: description ?? this.description,
    );
  }
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
  final User? user;
  final MediaBase? media;

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
    this.user,
    this.media,
  });

  String? get userName => user?.fullName ?? user?.username;
  String? get userEmail => user?.email;
  String? get mediaTitle => media?.title;

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
      user: json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      media: json['media'] is Map<String, dynamic>
          ? MediaBase.fromJson(json['media'] as Map<String, dynamic>)
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
    'user': user?.toJson(),
    'media': media?.toJson(),
  };

  ReportResponse copyWith({
    int? id,
    int? mediaId,
    int? userId,
    ReportReason? reason,
    String? description,
    ReportStatus? status,
    String? adminNote,
    DateTime? createdAt,
    DateTime? resolvedAt,
    User? user,
    MediaBase? media,
  }) {
    return ReportResponse(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      user: user ?? this.user,
      media: media ?? this.media,
    );
  }
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

  ReportListResponse copyWith({
    List<ReportResponse>? items,
    Pagination? pagination,
  }) {
    return ReportListResponse(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
    );
  }
}