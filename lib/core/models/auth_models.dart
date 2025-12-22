class Token {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  Token({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}

class UserRead {
  final String uuid;
  final String? login;
  final String? email;
  final bool isVerified;

  UserRead({
    required this.uuid,
    this.login,
    this.email,
    required this.isVerified,
  });

  factory UserRead.fromJson(Map<String, dynamic> json) {
    return UserRead(
      uuid: json['uuid'],
      login: json['login'],
      email: json['email'],
      isVerified: json['is_verified'] ?? false,
    );
  }
}
