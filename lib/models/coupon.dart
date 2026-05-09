enum CouponType {
  discount('Descuento'),
  freeProduct('Producto Gratis'),
  points('Puntos Extra');

  const CouponType(this.displayName);
  final String displayName;
}

class Coupon {
  final String id;
  final String code;
  final CouponType type;
  final double value;
  final String description;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final String? goalId; // ID de la meta que generó este cupón
  final String? materialType; // Tipo de material reciclado

  Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.description,
    required this.createdAt,
    this.expiresAt,
    this.isUsed = false,
    this.goalId,
    this.materialType,
  });

  // Verificar si el cupón está expirado
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Verificar si el cupón es válido (no usado y no expirado)
  bool get isValid {
    return !isUsed && !isExpired;
  }

  // Generar código único
  static String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();
    
    for (int i = 0; i < 8; i++) {
      code.write(chars[(random + i) % chars.length]);
    }
    
    return 'ECO-${code.toString()}';
  }

  // Crear copia con valores actualizados
  Coupon copyWith({
    String? id,
    String? code,
    CouponType? type,
    double? value,
    String? description,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
    String? goalId,
    String? materialType,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      goalId: goalId ?? this.goalId,
      materialType: materialType ?? this.materialType,
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'type': type.name,
      'value': value,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isUsed': isUsed,
      'goalId': goalId,
      'materialType': materialType,
    };
  }

  // Crear desde mapa de Firestore
  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      type: CouponType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => CouponType.discount,
      ),
      value: (map['value'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      isUsed: map['isUsed'] ?? false,
      goalId: map['goalId'],
      materialType: map['materialType'],
    );
  }

  // Crear cupón automáticamente al completar meta
  factory Coupon.fromCompletedGoal({
    required String goalId,
    required String materialType,
    required double targetAmount,
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 30)); // Expira en 30 días
    
    // Calcular valor del cupón basado en la meta
    final discountPercentage = _calculateDiscountPercentage(targetAmount);
    
    return Coupon(
      id: 'coupon_${now.millisecondsSinceEpoch}',
      code: generateCode(),
      type: CouponType.discount,
      value: discountPercentage,
      description: '¡Felicidades Johan! Por reciclar ${targetAmount.toStringAsFixed(1)} unidades de $materialType, obtienes ${discountPercentage.toStringAsFixed(0)}% de descuento.',
      createdAt: now,
      expiresAt: expiresAt,
      goalId: goalId,
      materialType: materialType,
    );
  }

  // Calcular porcentaje de descuento basado en la meta
  static double _calculateDiscountPercentage(double targetAmount) {
    if (targetAmount >= 100) return 20.0; // 20% para metas grandes
    if (targetAmount >= 50) return 15.0;  // 15% para metas medianas
    if (targetAmount >= 20) return 10.0;  // 10% para metas pequeñas
    return 5.0; // 5% para metas mínimas
  }
}
