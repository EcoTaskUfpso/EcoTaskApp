import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EcoPointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _usersCollection => 
      _firestore.collection('users');

  // Obtener puntos del usuario
  Future<int> getUserPoints() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final userDoc = await _usersCollection.doc(user.uid).get();
      return userDoc.data()?['ecoPoints'] ?? 0;
    } catch (e) {
      throw Exception('Error al obtener puntos: $e');
    }
  }

  // Añadir puntos por completar tarea
  Future<void> addPointsForTask(String taskId, int difficulty) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Calcular puntos basados en dificultad
      int pointsEarned = _calculatePoints(difficulty);

      // Verificar si la tarea ya fue completada antes
      final userDoc = await _usersCollection.doc(user.uid).get();
      final completedTasks = List<String>.from(userDoc.data()?['completedTasks'] ?? []);
      
      if (completedTasks.contains(taskId)) {
        throw Exception('Esta tarea ya fue completada anteriormente');
      }

      // Realizar transacción
      await _firestore.runTransaction((transaction) async {
        // Añadir puntos al usuario
        transaction.update(_usersCollection.doc(user.uid), {
          'ecoPoints': FieldValue.increment(pointsEarned),
          'completedTasks': FieldValue.arrayUnion([taskId]),
          'lastTaskCompleted': DateTime.now().toIso8601String(),
        });

        // Crear registro de actividad
        final activityRef = _usersCollection
            .doc(user.uid)
            .collection('point_activities')
            .doc();
        
        transaction.set(activityRef, {
          'id': activityRef.id,
          'taskId': taskId,
          'pointsEarned': pointsEarned,
          'difficulty': difficulty,
          'type': 'task_completion',
          'createdAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Error al añadir puntos: $e');
    }
  }

  // Añadir puntos por reciclaje
  Future<void> addPointsForRecycling(String materialType, double amount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Calcular puntos basados en material y cantidad
      int pointsEarned = _calculateRecyclingPoints(materialType, amount);

      // Realizar transacción
      await _firestore.runTransaction((transaction) async {
        // Añadir puntos al usuario
        transaction.update(_usersCollection.doc(user.uid), {
          'ecoPoints': FieldValue.increment(pointsEarned),
          'totalRecycled': FieldValue.increment(amount),
          'lastRecyclingActivity': DateTime.now().toIso8601String(),
        });

        // Crear registro de actividad
        final activityRef = _usersCollection
            .doc(user.uid)
            .collection('point_activities')
            .doc();
        
        transaction.set(activityRef, {
          'id': activityRef.id,
          'materialType': materialType,
          'amount': amount,
          'pointsEarned': pointsEarned,
          'type': 'recycling',
          'createdAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Error al añadir puntos de reciclaje: $e');
    }
  }

  // Obtener historial de actividades de puntos
  Future<List<Map<String, dynamic>>> getPointActivities() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _usersCollection
          .doc(user.uid)
          .collection('point_activities')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener actividades: $e');
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final userDoc = await _usersCollection.doc(user.uid).get();
      final data = userDoc.data() ?? {};

      return {
        'totalPoints': data['ecoPoints'] ?? 0,
        'completedTasks': data['completedTasks']?.length ?? 0,
        'totalRecycled': data['totalRecycled'] ?? 0.0,
        'lastTaskCompleted': data['lastTaskCompleted'],
        'lastRecyclingActivity': data['lastRecyclingActivity'],
        'memberSince': data['createdAt'] ?? DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Inicializar usuario con puntos iniciales
  Future<void> initializeUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final userDoc = await _usersCollection.doc(user.uid).get();
      
      if (!userDoc.exists) {
        await _usersCollection.doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'ecoPoints': 50, // Puntos de bienvenida
          'completedTasks': [],
          'totalRecycled': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
          'lastTaskCompleted': null,
          'lastRecyclingActivity': null,
        });

        // Crear registro de puntos de bienvenida
        final activityRef = _usersCollection
            .doc(user.uid)
            .collection('point_activities')
            .doc();
        
        await activityRef.set({
          'id': activityRef.id,
          'pointsEarned': 50,
          'type': 'welcome_bonus',
          'description': 'Puntos de bienvenida',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Error al inicializar usuario: $e');
    }
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

  // Canjear puntos por cupón (manejado en CouponService)
  // Este método es solo para referencia
  Future<void> redeemPoints(int points) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final currentPoints = await getUserPoints();
      if (currentPoints < points) {
        throw Exception('No tienes suficientes puntos');
      }

      await _usersCollection.doc(user.uid).update({
        'ecoPoints': FieldValue.increment(-points),
      });
    } catch (e) {
      throw Exception('Error al canjear puntos: $e');
    }
  }
}
