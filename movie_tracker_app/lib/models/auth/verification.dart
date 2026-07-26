import 'token.dart';

class PasswordChangeBase {
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeBase({
    required this.newPassword,
    required this.confirmPassword,
  });

  factory PasswordChangeBase.fromJson(Map<String, dynamic> json) {
    return PasswordChangeBase(
      newPassword: json['new_password'],
      confirmPassword: json['confirm_password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'new_password': newPassword,
    'confirm_password': confirmPassword,
  };
}

class VerifyEmailConfirm {
  final String otp;

  const VerifyEmailConfirm({required this.otp});

  factory VerifyEmailConfirm.fromJson(Map<String, dynamic> json) {
    return VerifyEmailConfirm(otp: json['otp']);
  }

  Map<String, dynamic> toJson() => {'otp': otp};
}

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(email: json['email']);
  }

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordConfirm extends PasswordChangeBase {
  final String email;
  final String otp;

  const ResetPasswordConfirm({
    required this.email,
    required this.otp,
    required super.newPassword,
    required super.confirmPassword,
  });

  factory ResetPasswordConfirm.fromJson(Map<String, dynamic> json) {
    return ResetPasswordConfirm(
      email: json['email'],
      otp: json['otp'],
      newPassword: json['new_password'],
      confirmPassword: json['confirm_password'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'email': email,
    'otp': otp,
  };
}

class ChangePasswordRequest extends PasswordChangeBase {
  final String currentPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required super.newPassword,
    required super.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['current_password'],
      newPassword: json['new_password'],
      confirmPassword: json['confirm_password'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'current_password': currentPassword,
  };
}

class GenericResponse {
  final String message;

  const GenericResponse({required this.message});

  factory GenericResponse.fromJson(Map<String, dynamic> json) {
    return GenericResponse(message: json['message']);
  }

  Map<String, dynamic> toJson() => {'message': message};
}

class VerifyEmailResponse {
  final String message;
  final Token tokens;

  const VerifyEmailResponse({required this.message, required this.tokens});

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      message: json['message'],
      tokens: Token.fromJson(json['tokens']),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'tokens': tokens.toJson(),
  };
}