class DriverProfile {
  DriverProfile({
    this.fullName,
    this.city,
    this.photo,
    this.identityDocument,
    this.motorcyclePlate,
    this.defaultZone,
    this.hasSubscription = false,
    this.isVisible = false,
    this.isOnline = false,
    this.extra = const {},
  });

  final String? fullName;
  final String? city;
  final String? photo;
  final String? identityDocument;
  final String? motorcyclePlate;
  final String? defaultZone;
  final bool hasSubscription;
  final bool isVisible;
  final bool isOnline;
  final Map<String, dynamic> extra;

  bool get needsCompletion {
    final n = fullName?.trim() ?? '';
    final plate = motorcyclePlate?.trim() ?? '';
    return n.isEmpty || plate.isEmpty;
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      fullName: json['full_name'] as String?,
      city: json['city'] as String?,
      photo: json['photo'] as String?,
      identityDocument: json['identity_document'] as String?,
      motorcyclePlate: json['motorcycle_plate'] as String?,
      defaultZone: json['default_zone'] as String?,
      hasSubscription: json['has_subscription'] == true,
      isVisible: json['is_visible'] == true,
      isOnline: json['is_online'] == true,
      extra: Map<String, dynamic>.from(json)
        ..removeWhere(
          (k, _) => {
            'full_name',
            'city',
            'photo',
            'identity_document',
            'motorcycle_plate',
            'default_zone',
            'has_subscription',
            'is_visible',
            'is_online',
          }.contains(k),
        ),
    );
  }

  Map<String, dynamic> toUpdateBody() {
    final m = <String, dynamic>{};
    if (fullName != null) m['full_name'] = fullName;
    if (city != null) m['city'] = city;
    if (photo != null) m['photo'] = photo;
    if (defaultZone != null) m['default_zone'] = defaultZone;
    return m;
  }

  DriverProfile copyWith({
    String? fullName,
    String? city,
    String? photo,
    String? identityDocument,
    String? motorcyclePlate,
    String? defaultZone,
    bool? hasSubscription,
    bool? isVisible,
    bool? isOnline,
    Map<String, dynamic>? extra,
  }) {
    return DriverProfile(
      fullName: fullName ?? this.fullName,
      city: city ?? this.city,
      photo: photo ?? this.photo,
      identityDocument: identityDocument ?? this.identityDocument,
      motorcyclePlate: motorcyclePlate ?? this.motorcyclePlate,
      defaultZone: defaultZone ?? this.defaultZone,
      hasSubscription: hasSubscription ?? this.hasSubscription,
      isVisible: isVisible ?? this.isVisible,
      isOnline: isOnline ?? this.isOnline,
      extra: extra ?? this.extra,
    );
  }
}
