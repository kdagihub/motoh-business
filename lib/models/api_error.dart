class ApiError implements Exception {
  ApiError({required this.code, required this.message, this.details});

  final String code;
  final String message;
  final String? details;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'Erreur inconnue',
      details: json['details'] as String?,
    );
  }

  @override
  String toString() => message;
}
