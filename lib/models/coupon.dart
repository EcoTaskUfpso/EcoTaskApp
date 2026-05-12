enum CouponType {
  discount('Descuento'),
  freeProduct('Producto Gratis'),
  points('Puntos Extra'),
  experience('Experiencia Ecológica');

  const CouponType(this.displayName);
  final String displayName;
}

enum CouponStatus {
  available('Disponible'),
  claimed('Reclamado'),
  used('Usado'),
  expired('Expirado');

  const CouponStatus(this.displayName);
  final String displayName;
}

class Coupon {
  final String id;
  final String title;
  final String description;
  final CouponType type;
  final double value; // Valor del descuento o puntos
  final String? partnerCompany; // Empresa colaboradora
  final String imageUrl;
  final String code;
  final int pointsRequired; // Puntos necesarios para reclamar
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? claimedAt;
  final DateTime? usedAt;
  final CouponStatus status;
  final List<String> terms; // Términos y condiciones

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.partnerCompany,
    required this.imageUrl,
    required this.code,
    required this.pointsRequired,
    required this.createdAt,
    required this.expiresAt,
    this.claimedAt,
    this.usedAt,
    required this.status,
    required this.terms,
  });

  // Verificar si el cupón está disponible para reclamar
  bool get isAvailable => 
      status == CouponStatus.available && 
      DateTime.now().isBefore(expiresAt);

  // Verificar si el cupón está expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Verificar si el cupón puede ser usado
  bool get canBeUsed => 
      status == CouponStatus.claimed && 
      !isExpired &&
      usedAt == null;

  // Crear copia con valores actualizados
  Coupon copyWith({
    String? id,
    String? title,
    String? description,
    CouponType? type,
    double? value,
    String? partnerCompany,
    String? imageUrl,
    String? code,
    int? pointsRequired,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? claimedAt,
    DateTime? usedAt,
    CouponStatus? status,
    List<String>? terms,
  }) {
    return Coupon(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      partnerCompany: partnerCompany ?? this.partnerCompany,
      imageUrl: imageUrl ?? this.imageUrl,
      code: code ?? this.code,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      claimedAt: claimedAt ?? this.claimedAt,
      usedAt: usedAt ?? this.usedAt,
      status: status ?? this.status,
      terms: terms ?? this.terms,
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'value': value,
      'partnerCompany': partnerCompany,
      'imageUrl': imageUrl,
      'code': code,
      'pointsRequired': pointsRequired,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'status': status.name,
      'terms': terms,
    };
  }

  // Crear desde mapa de Firestore
  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: CouponType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => CouponType.discount,
      ),
      value: (map['value'] ?? 0.0).toDouble(),
      partnerCompany: map['partnerCompany'],
      imageUrl: map['imageUrl'] ?? '',
      code: map['code'] ?? '',
      pointsRequired: map['pointsRequired'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(map['expiresAt'] ?? DateTime.now().toIso8601String()),
      claimedAt: map['claimedAt'] != null ? DateTime.parse(map['claimedAt']) : null,
      usedAt: map['usedAt'] != null ? DateTime.parse(map['usedAt']) : null,
      status: CouponStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => CouponStatus.available,
      ),
      terms: List<String>.from(map['terms'] ?? []),
    );
  }

  // Generar código aleatorio para cupón
  static String generateCouponCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();
    
    for (int i = 0; i < 8; i++) {
      code.write(chars[(random + i) % chars.length]);
    }
    
    return code.toString();
  }
}
