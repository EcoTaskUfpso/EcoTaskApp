class LocalEcoPointsService {
  static int _userPoints = 50; // Puntos iniciales de bienvenida
  static List<String> _completedTasks = [];
  static List<Map<String, dynamic>> _pointActivities = [];
  static double _totalRecycled = 0.0;

  // Obtener puntos del usuario
  Future<int> getUserPoints() async {
    return _userPoints;
  }

  // Añadir puntos por completar tarea
  Future<void> addPointsForTask(String taskId, int difficulty) async {
    // Verificar si la tarea ya fue completada antes
    if (_completedTasks.contains(taskId)) {
      throw Exception('Esta tarea ya fue completada anteriormente');
    }

    // Calcular puntos basados en dificultad
    int pointsEarned = _calculatePoints(difficulty);

    // Actualizar datos locales
    _userPoints += pointsEarned;
    _completedTasks.add(taskId);

    // Crear registro de actividad
    _pointActivities.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'taskId': taskId,
      'pointsEarned': pointsEarned,
      'difficulty': difficulty,
      'type': 'task_completion',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Añadir puntos por reciclaje
  Future<void> addPointsForRecycling(String materialType, double amount) async {
    // Calcular puntos basados en material y cantidad
    int pointsEarned = _calculateRecyclingPoints(materialType, amount);

    // Actualizar datos locales
    _userPoints += pointsEarned;
    _totalRecycled += amount;

    // Crear registro de actividad
    _pointActivities.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'materialType': materialType,
      'amount': amount,
      'pointsEarned': pointsEarned,
      'type': 'recycling',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Obtener historial de actividades de puntos
  Future<List<Map<String, dynamic>>> getPointActivities() async {
    return List.from(_pointActivities.reversed.take(50));
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    return {
      'totalPoints': _userPoints,
      'completedTasks': _completedTasks.length,
      'totalRecycled': _totalRecycled,
      'lastTaskCompleted': _completedTasks.isNotEmpty ? DateTime.now().toIso8601String() : null,
      'lastRecyclingActivity': _totalRecycled > 0 ? DateTime.now().toIso8601String() : null,
      'memberSince': DateTime.now().toIso8601String(),
    };
  }

  // Inicializar usuario con puntos iniciales
  Future<void> initializeUser() async {
    // Ya inicializado con 50 puntos en la variable estática
    _pointActivities.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'pointsEarned': 50,
      'type': 'welcome_bonus',
      'description': 'Puntos de bienvenida',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Calcular puntos basados en dificultad
  int _calculatePoints(int difficulty) {
    switch (difficulty) {
      case 1: // Fácil
        return 10;
      case 2: // Medio
        return 25;
      case 3: // Difícil
        return 50;
      default:
        return 15;
    }
  }

  // Calcular puntos de reciclaje
  int _calculateRecyclingPoints(String materialType, double amount) {
    int basePoints;
    switch (materialType.toLowerCase()) {
      case 'botellas':
      case 'bottles':
        basePoints = 5; // 5 puntos por botella
        break;
      case 'papel':
      case 'paper':
        basePoints = 2; // 2 puntos por kg
        break;
      case 'cajas':
      case 'boxes':
        basePoints = 3; // 3 puntos por caja
        break;
      default:
        basePoints = 1;
    }

    return (basePoints * amount).round();
  }

  // Canjear puntos por cupón
  Future<void> redeemPoints(int points) async {
    if (_userPoints < points) {
      throw Exception('No tienes suficientes puntos');
    }
    _userPoints -= points;
  }

  // Resetear datos locales
  void resetData() {
    _userPoints = 50;
    _completedTasks.clear();
    _pointActivities.clear();
    _totalRecycled = 0.0;
  }

  // Inicializar datos
  Future<void> initialize() async {
    if (_pointActivities.isEmpty) {
      await initializeUser();
    }
  }
}
