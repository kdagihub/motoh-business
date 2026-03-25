class Subscription {
  Subscription({
    this.plan,
    this.expiresAt,
    this.autoRenew = false,
    this.status,
    this.extra = const {},
  });

  final String? plan;
  final DateTime? expiresAt;
  final bool autoRenew;
  final String? status;
  final Map<String, dynamic> extra;

  bool get isActive {
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    DateTime? exp;
    final raw = json['expires_at'] ?? json['expiresAt'] ?? json['end_date'];
    if (raw is String) {
      exp = DateTime.tryParse(raw);
    }

    return Subscription(
      plan: json['plan'] as String?,
      expiresAt: exp,
      autoRenew: json['auto_renew'] == true || json['autoRenew'] == true,
      status: json['status'] as String?,
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((k, _) => {'plan', 'expires_at', 'expiresAt', 'end_date', 'auto_renew', 'autoRenew', 'status'}.contains(k)),
    );
  }

  Subscription copyWith({
    String? plan,
    DateTime? expiresAt,
    bool? autoRenew,
    String? status,
    Map<String, dynamic>? extra,
  }) {
    return Subscription(
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
      status: status ?? this.status,
      extra: extra ?? this.extra,
    );
  }
}
