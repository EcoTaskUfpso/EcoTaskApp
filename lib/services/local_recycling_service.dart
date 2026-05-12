import '../models/recycling_goal.dart';

class LocalRecyclingService {
  static List<RecyclingGoal> _goals = [];
  static List<Map<String, dynamic>> _recyclingRecords = [];
  static int _userPoints = 0;

  // Obtener todas las metas de reciclaje
  Future<List<RecyclingGoal>> getGoals() async {
    if (_goals.isEmpty) {
      await _createSampleGoals();
    }
    return _goals;
  }

  // Obtener estadísticas de reciclaje
  Future<Map<String, dynamic>> getRecyclingStats() async {
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((goal) => goal.isGoalCompleted).length;
    final totalProgress = _goals.isEmpty 
        ? 0.0 
        : _goals.map((goal) => goal.progress).reduce((a, b) => a + b) / _goals.length * 100;

    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'overallProgress': totalProgress,
    };
  }

  // Agregar progreso a una meta
  Future<void> addProgress(String goalId, double amount) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex == -1) throw Exception('Meta no encontrada');

    final goal = _goals[goalIndex];
    final newAmount = goal.currentAmount + amount;
    
    // Calcular puntos ganados
    final pointsEarned = _calculateRecyclingPoints(goal.materialType, amount);
    
    // Actualizar la meta
    _goals[goalIndex] = goal.copyWith(
      currentAmount: newAmount,
      updatedAt: DateTime.now(),
      isCompleted: newAmount >= goal.targetAmount,
    );

    // Añadir puntos del usuario
    _userPoints += pointsEarned;

    // Registrar la actividad
    _recyclingRecords.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'goalId': goalId,
      'materialType': goal.materialType.name,
      'amount': amount,
      'previousAmount': goal.currentAmount,
      'newAmount': newAmount,
      'pointsEarned': pointsEarned,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Obtener puntos del usuario
  Future<int> getUserPoints() async {
    return _userPoints;
  }

  // Calcular puntos de reciclaje
  int _calculateRecyclingPoints(MaterialType materialType, double amount) {
    int basePoints;
    switch (materialType) {
      case MaterialType.bottles:
        basePoints = 5; // 5 puntos por botella
        break;
      case MaterialType.paper:
        basePoints = 2; // 2 puntos por kg
        break;
      case MaterialType.boxes:
        basePoints = 3; // 3 puntos por caja
        break;
    }

    return (basePoints * amount).round();
  }

  // Crear nueva meta
  Future<void> createGoal(RecyclingGoal goal) async {
    _goals.add(goal);
  }

  // Actualizar meta
  Future<void> updateGoal(RecyclingGoal updatedGoal) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
    if (goalIndex != -1) {
      _goals[goalIndex] = updatedGoal;
    }
  }

  // Eliminar meta
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((goal) => goal.id == goalId);
    _recyclingRecords.removeWhere((record) => record['goalId'] == goalId);
  }

  // Obtener historial de reciclaje
  Future<List<Map<String, dynamic>>> getRecyclingHistory() async {
    return List.from(_recyclingRecords.reversed.take(50));
  }

  // Obtener metas por tipo de material
  Future<List<RecyclingGoal>> getGoalsByType(MaterialType materialType) async {
    return _goals.where((goal) => goal.materialType == materialType).toList();
  }

  // Crear metas de ejemplo
  Future<void> _createSampleGoals() async {
    _goals = [
      RecyclingGoal(
        id: 'goal_1',
        materialType: MaterialType.bottles,
        targetAmount: 50.0,
        currentAmount: 0.0,
        createdAt: DateTime.now(),
        isCompleted: false,
      ),
      RecyclingGoal(
        id: 'goal_2',
        materialType: MaterialType.paper,
        targetAmount: 10.0,
        currentAmount: 0.0,
        createdAt: DateTime.now(),
        isCompleted: false,
      ),
      RecyclingGoal(
        id: 'goal_3',
        materialType: MaterialType.boxes,
        targetAmount: 25.0,
        currentAmount: 0.0,
        createdAt: DateTime.now(),
        isCompleted: false,
      ),
    ];
  }

  // Resetear datos
  void resetData() {
    _goals.clear();
    _recyclingRecords.clear();
  }

  // Inicializar datos
  Future<void> initialize() async {
    if (_goals.isEmpty) {
      await _createSampleGoals();
    }
  }
}
