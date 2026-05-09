enum MaterialType {
  bottles('Botellas'),
  paper('Papel'),
  boxes('Cajas');

  const MaterialType(this.displayName);
  final String displayName;
}

class RecyclingGoal {
  final String id;
  final MaterialType materialType;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;

  RecyclingGoal({
    required this.id,
    required this.materialType,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
  });

  // Calcular progreso como porcentaje
  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // Verificar si la meta está completada
  bool get isGoalCompleted => currentAmount >= targetAmount;

  // Crear copia con valores actualizados
  RecyclingGoal copyWith({
    String? id,
    MaterialType? materialType,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    return RecyclingGoal(
      id: id ?? this.id,
      materialType: materialType ?? this.materialType,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convertir a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialType': materialType.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Crear desde mapa de Firestore
  factory RecyclingGoal.fromMap(Map<String, dynamic> map) {
    return RecyclingGoal(
      id: map['id'] ?? '',
      materialType: MaterialType.values.firstWhere(
        (type) => type.name == map['materialType'],
        orElse: () => MaterialType.bottles,
      ),
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
