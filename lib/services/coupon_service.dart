import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coupon.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de cupones del usuario actual
  CollectionReference get _couponsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _firestore.collection('users').doc(userId).collection('coupons');
  }

  // Generar cupón al completar una meta
  Future<String> generateCouponForCompletedGoal({
    required String goalId,
    required String materialType,
    required double targetAmount,
  }) async {
    try {
      // Verificar si ya existe un cupón para esta meta
      final existingCoupons = await _couponsCollection
          .where('goalId', isEqualTo: goalId)
          .get();

      if (existingCoupons.docs.isNotEmpty) {
        throw Exception('Ya existe un cupón para esta meta');
      }

      final coupon = Coupon.fromCompletedGoal(
        goalId: goalId,
        materialType: materialType,
        targetAmount: targetAmount,
      );

      await _couponsCollection.doc(coupon.id).set(coupon.toMap());
      return coupon.code;
    } catch (e) {
      throw 'Error al generar cupón: ${e.toString()}';
    }
  }

  // Obtener todos los cupones del usuario
  Future<List<Coupon>> getCoupons() async {
    try {
      final snapshot = await _couponsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Coupon.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener los cupones: ${e.toString()}';
    }
  }

  // Obtener cupones válidos (no usados y no expirados)
  Future<List<Coupon>> getValidCoupons() async {
    try {
      final allCoupons = await getCoupons();
      return allCoupons.where((coupon) => coupon.isValid).toList();
    } catch (e) {
      throw 'Error al obtener cupones válidos: ${e.toString()}';
    }
  }

  // Obtener un cupón específico
  Future<Coupon?> getCoupon(String couponId) async {
    try {
      final doc = await _couponsCollection.doc(couponId).get();
      if (!doc.exists) return null;

      return Coupon.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw 'Error al obtener el cupón: ${e.toString()}';
    }
  }

  // Buscar cupón por código
  Future<Coupon?> getCouponByCode(String code) async {
    try {
      final snapshot = await _couponsCollection
          .where('code', isEqualTo: code.toUpperCase())
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Coupon.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw 'Error al buscar cupón por código: ${e.toString()}';
    }
  }

  // Marcar cupón como usado
  Future<void> useCoupon(String couponId) async {
    try {
      final coupon = await getCoupon(couponId);
      if (coupon == null) throw Exception('Cupón no encontrado');
      if (coupon.isUsed) throw Exception('Cupón ya fue usado');
      if (coupon.isExpired) throw Exception('Cupón expirado');

      await _couponsCollection.doc(couponId).update({
        'isUsed': true,
        'usedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Error al usar cupón: ${e.toString()}';
    }
  }

  // Eliminar un cupón
  Future<void> deleteCoupon(String couponId) async {
    try {
      await _couponsCollection.doc(couponId).delete();
    } catch (e) {
      throw 'Error al eliminar cupón: ${e.toString()}';
    }
  }

  // Stream para escuchar cambios en los cupones en tiempo real
  Stream<List<Coupon>> getCouponsStream() {
    return _couponsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Coupon.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Obtener estadísticas de cupones
  Future<Map<String, dynamic>> getCouponStats() async {
    try {
      final coupons = await getCoupons();
      
      int totalCoupons = coupons.length;
      int usedCoupons = coupons.where((coupon) => coupon.isUsed).length;
      int expiredCoupons = coupons.where((coupon) => coupon.isExpired).length;
      int validCoupons = coupons.where((coupon) => coupon.isValid).length;

      // Calcular valor total de descuentos
      double totalDiscountValue = coupons
          .where((coupon) => coupon.type == CouponType.discount)
          .fold(0.0, (sum, coupon) => sum + coupon.value);

      return {
        'totalCoupons': totalCoupons,
        'usedCoupons': usedCoupons,
        'expiredCoupons': expiredCoupons,
        'validCoupons': validCoupons,
        'totalDiscountValue': totalDiscountValue,
        'averageDiscount': totalCoupons > 0 ? totalDiscountValue / totalCoupons : 0.0,
      };
    } catch (e) {
      throw 'Error al obtener estadísticas de cupones: ${e.toString()}';
    }
  }

  // Verificar si una meta ya tiene cupón generado
  Future<bool> hasCouponForGoal(String goalId) async {
    try {
      final snapshot = await _couponsCollection
          .where('goalId', isEqualTo: goalId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Error al verificar cupón para meta: ${e.toString()}';
    }
  }
}
