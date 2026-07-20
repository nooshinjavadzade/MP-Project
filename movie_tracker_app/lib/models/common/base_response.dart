class BaseResponse<T> {
  final bool success;
  final String? message;
  final T data;

  const BaseResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory BaseResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJson,
      ) {
    return BaseResponse(
      success: json['success'],
      message: json['message'],
      data: fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson(
      Object Function(T value) toJson,
      ) {
    return {
      'success': success,
      'message': message,
      'data': toJson(data),
    };
  }
}