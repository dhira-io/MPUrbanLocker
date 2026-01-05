class OAuthSession {
  final String sessionId;
  final String state;
  final String authorizationUrl;
  final int expiresIn;

  OAuthSession({
    required this.sessionId,
    required this.state,
    required this.authorizationUrl,
    required this.expiresIn,
  });

  factory OAuthSession.fromJson(Map<String, dynamic> json) {
    return OAuthSession(
      sessionId: json['sessionId'] as String,
      state: json['state'] as String,
      authorizationUrl: json['authorizationUrl'] as String,
      expiresIn: json['expiresIn'] as int? ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'state': state,
      'authorizationUrl': authorizationUrl,
      'expiresIn': expiresIn,
    };
  }
}

class SessionStatus {
  final bool completed;
  final String? userId;
  final String? token;
  final String? name;
  final String? email;
  final String? mobile;
  final int? documentsCount;
  final bool? newAccount;

  SessionStatus({
    required this.completed,
    this.userId,
    this.token,
    this.name,
    this.email,
    this.mobile,
    this.documentsCount,
    this.newAccount,
  });

  factory SessionStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return SessionStatus(
      completed: json['completed'] as bool? ?? false,
      userId: data?['userId'] as String?,
      token: data?['token'] as String?,
      name: data?['name'] as String?,
      email: data?['email'] as String?,
      mobile: data?['mobile'] as String?,
      documentsCount: data?['documentsCount'] as int?,
      newAccount: data?['newAccount'] as bool?,
    );
  }
}

class PKCEParams {
  final String state;
  final String nonce;
  final String codeVerifier;
  final String codeChallenge;

  PKCEParams({
    required this.state,
    required this.nonce,
    required this.codeVerifier,
    required this.codeChallenge,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'nonce': nonce,
      'codeVerifier': codeVerifier,
      'codeChallenge': codeChallenge,
    };
  }
}
