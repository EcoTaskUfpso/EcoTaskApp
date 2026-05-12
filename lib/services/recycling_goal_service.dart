import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_ufpso/models/recycling_goal.dart' as models;

class RecyclingGoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de metas del usuario actual
  CollectionReference get _goalsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _firestore.collection('users').doc(userId).collection('recycling_goals');
  }

  // Crear una nueva meta de reciclaje
  Future<String> createGoal({
    required models.MaterialType materialType,
    required double targetAmount,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final goalId = _firestore.collection('users').doc(userId).collection('recycling_goals').doc().id;
      
      final goal = models.RecyclingGoal(
        id: goalId,
        materialType: materialType,
        targetAmount: targetAmount,
        createdAt: DateTime.now(),
      );

      await _goalsCollection.doc(goalId).set(goal.toMap());
      return goalId;
    } catch (e) {
      throw 'Error al crear la meta: ${e.toString()}';
    }
  }

  // Crear una nueva meta de reciclaje a partir de un objeto RecyclingGoal
  Future<void> createGoalFromObject(models.RecyclingGoal goal) async {
    try {
      await _goalsCollection.doc(goal.id).set(goal.toMap());
    } catch (e) {
      throw 'Error al crear la meta: ${e.toString()}';
    }
  }

  // Obtener todas las metas del usuario
  Future<List<models.RecyclingGoal>> getGoals() async {
    try {
      final snapshot = await _goalsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => models.RecyclingGoal.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener las metas: ${e.toString()}';
    }
  }

  // Obtener una meta específica
  Future<models.RecyclingGoal?> getGoal(String goalId) async {
    try {
      final doc = await _goalsCollection.doc(goalId).get();
      if (!doc.exists) return null;

      return models.RecyclingGoal.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw 'Error al obtener la meta: ${e.toString()}';
    }
  }

  // Actualizar una meta
  Future<void> updateGoal({
    required String goalId,
    models.MaterialType? materialType,
    double? targetAmount,
    double? currentAmount,
    bool? isCompleted,
  }) async {
    try {
      final currentGoal = await getGoal(goalId);
      if (currentGoal == null) throw Exception('Meta no encontrada');

      final updatedGoal = currentGoal.copyWith(
        materialType: materialType,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        isCompleted: isCompleted,
      );

      await _goalsCollection.doc(goalId).update(updatedGoal.toMap());
    } catch (e) {
      throw 'Error al actualizar la meta: ${e.toString()}';
    }
  }

  // Incrementar el progreso de una meta
  Future<void> addProgress(String goalId, double amount) async {
    try {
      final currentGoal = await getGoal(goalId);
      if (currentGoal == null) throw Exception('Meta no encontrada');

      final newAmount = currentGoal.currentAmount + amount;
      final isCompleted = newAmount >= currentGoal.targetAmount;

      await updateGoal(
        goalId: goalId,
        currentAmount: newAmount,
        isCompleted: isCompleted,
      );
    } catch (e) {
      throw 'Error al actualizar el progreso: ${e.toString()}';
    }
  }

  // Eliminar una meta
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalsCollection.doc(goalId).delete();
    } catch (e) {
      throw 'Error al eliminar la meta: ${e.toString()}';
    }
  }

  // Stream para escuchar cambios en las metas en tiempo real
  Stream<List<models.RecyclingGoal>> getGoalsStream() {
    return _goalsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.RecyclingGoal.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Obtener estadísticas de reciclaje
  Future<Map<String, dynamic>> getRecyclingStats() async {
    try {
      final goals = await getGoals();
      
      int totalGoals = goals.length;
      int completedGoals = goals.where((goal) => goal.isCompleted).length;
      double totalRecycled = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
      double totalTarget = goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

      return {
        'totalGoals': totalGoals,
        'completedGoals': completedGoals,
        'pendingGoals': totalGoals - completedGoals,
        'totalRecycled': totalRecycled,
        'totalTarget': totalTarget,
        'overallProgress': totalTarget > 0 ? (totalRecycled / totalTarget) * 100 : 0.0,
      };
    } catch (e) {
      throw 'Error al obtener estadísticas: ${e.toString()}';
    }
  }
}
