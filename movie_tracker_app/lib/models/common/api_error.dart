class ApiError {
  final int statusCode;
  final String message;
  final String? error;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.statusCode,
    required this.message,
    this.error,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['status_code'],
      message: json['message'],
      error: json['error'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status_code': statusCode,
    'message': message,
    'error': error,
    'details': details,
  };

  ApiError copyWith({
    int? statusCode,
    String? message,
    String? error,
    Map<String, dynamic>? details,
  }) {
    return ApiError(
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      error: error ?? this.error,
      details: details ?? this.details,
    );
  }
}