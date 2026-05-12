import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coupon.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a las colecciones
  CollectionReference get _availableCoupons => 
      _firestore.collection('available_coupons');
  
  CollectionReference get _userCoupons => 
      _firestore.collection('users').doc(_auth.currentUser?.uid).collection('coupons');

  CollectionReference get _usersCollection => 
      _firestore.collection('users');

  // Obtener todos los cupones disponibles
  Future<List<Coupon>> getAvailableCoupons() async {
    try {
      final snapshot = await _availableCoupons
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Coupon.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar cupones disponibles: $e');
    }
  }

  // Obtener los cupones del usuario
  Future<List<Coupon>> getUserCoupons() async {
    try {
      final snapshot = await _userCoupons
          .orderBy('claimedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Coupon.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar cupones del usuario: $e');
    }
  }

  // Reclamar un cupón
  Future<void> claimCoupon(String couponId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Obtener el cupón disponible
      final couponDoc = await _availableCoupons.doc(couponId).get();
      if (!couponDoc.exists) throw Exception('Cupón no encontrado');

      final coupon = Coupon.fromMap(couponDoc.data() as Map<String, dynamic>);
      
      if (!coupon.isAvailable) {
        throw Exception('El cupón ya no está disponible');
      }

      // Verificar si el usuario tiene suficientes puntos
      final userDoc = await _usersCollection.doc(user.uid).get();
      final userPoints = userDoc.data()?['ecoPoints'] ?? 0;

      if (userPoints < coupon.pointsRequired) {
        throw Exception('No tienes suficientes puntos para reclamar este cupón');
      }

      // Realizar la transacción
      await _firestore.runTransaction((transaction) async {
        // Descontar puntos del usuario
        transaction.update(_usersCollection.doc(user.uid), {
          'ecoPoints': FieldValue.increment(-coupon.pointsRequired)
        });

        // Actualizar estado del cupón disponible
        transaction.update(_availableCoupons.doc(couponId), {
          'status': 'claimed',
          'claimedAt': DateTime.now().toIso8601String(),
          'claimedBy': user.uid
        });

        // Crear copia del cupón para el usuario
        final userCoupon = coupon.copyWith(
          status: CouponStatus.claimed,
          claimedAt: DateTime.now(),
        );

        transaction.set(_userCoupons.doc(couponId), userCoupon.toMap());
      });
    } catch (e) {
      throw Exception('Error al reclamar cupón: $e');
    }
  }

  // Usar un cupón
  Future<void> useCoupon(String couponId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Obtener el cupón del usuario
      final couponDoc = await _userCoupons.doc(couponId).get();
      if (!couponDoc.exists) throw Exception('Cupón no encontrado');

      final coupon = Coupon.fromMap(couponDoc.data() as Map<String, dynamic>);
      
      if (!coupon.canBeUsed) {
        throw Exception('Este cupón no puede ser usado');
      }

      // Actualizar estado del cupón a usado
      await _userCoupons.doc(couponId).update({
        'status': 'used',
        'usedAt': DateTime.now().toIso8601String()
      });

      // Otorgar puntos adicionales por usar el cupón (bonus)
      await _usersCollection.doc(user.uid).update({
        'ecoPoints': FieldValue.increment(10) // 10 puntos bonus
      });
    } catch (e) {
      throw Exception('Error al usar cupón: $e');
    }
  }

  // Obtener estadísticas de cupones del usuario
  Future<Map<String, dynamic>> getCouponStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final snapshot = await _userCoupons.get();
      final coupons = snapshot.docs
          .map((doc) => Coupon.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final available = coupons.where((c) => c.status == CouponStatus.claimed && !c.isExpired).length;
      final used = coupons.where((c) => c.status == CouponStatus.used).length;
      final expired = coupons.where((c) => c.isExpired).length;

      return {
        'total': coupons.length,
        'available': available,
        'used': used,
        'expired': expired,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Crear cupones de ejemplo (solo para desarrollo)
  Future<void> createSampleCoupons() async {
    try {
      final sampleCoupons = [
        Coupon(
          id: 'coupon_1',
          title: '20% de descuento en tienda ecológica',
          description: 'Obtén 20% de descuento en tu próxima compra en Tienda Verde',
          type: CouponType.discount,
          value: 20.0,
          partnerCompany: 'Tienda Verde',
          imageUrl: 'https://picsum.photos/seed/green-store/200/120',
          code: Coupon.generateCouponCode(),
          pointsRequired: 100,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
          status: CouponStatus.available,
          terms: [
            'Válido por 20% de descuento en productos seleccionados',
            'No acumulable con otras promociones',
            'Válido por 30 días desde la reclamación',
            'Máximo 1 uso por cliente'
          ],
        ),
        Coupon(
          id: 'coupon_2',
          title: 'Bolsa de tela reutilizable gratis',
          description: 'Recibe una bolsa de tela ecológica completamente gratis',
          type: CouponType.freeProduct,
          value: 1.0,
          partnerCompany: 'EcoBag Store',
          imageUrl: 'https://picsum.photos/seed/eco-bag/200/120',
          code: Coupon.generateCouponCode(),
          pointsRequired: 50,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 15)),
          status: CouponStatus.available,
          terms: [
            'Bolsa de tela 100% algodón orgánico',
            'Retiro en tienda física',
            'Válido por 15 días desde la reclamación',
            'Sujeto a disponibilidad'
          ],
        ),
        Coupon(
          id: 'coupon_3',
          title: 'Doble de puntos en próxima actividad',
          description: 'Gana el doble de puntos en tu próxima tarea ecológica completada',
          type: CouponType.points,
          value: 2.0,
          imageUrl: 'https://picsum.photos/seed/double-points/200/120',
          code: Coupon.generateCouponCode(),
          pointsRequired: 75,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          status: CouponStatus.available,
          terms: [
            'Válido para duplicar puntos en 1 tarea',
            'Aplicable solo para tareas completadas en 7 días',
            'No acumulable con otros bonificadores',
            'Máximo 1 uso por usuario'
          ],
        ),
      ];

      for (final coupon in sampleCoupons) {
        await _availableCoupons.doc(coupon.id).set(coupon.toMap());
      }
    } catch (e) {
      throw Exception('Error al crear cupones de ejemplo: $e');
    }
  }

  // Eliminar cupón (admin function)
  Future<void> deleteCoupon(String couponId) async {
    try {
      await _availableCoupons.doc(couponId).delete();
    } catch (e) {
      throw Exception('Error al eliminar cupón: $e');
    }
  }

  // Actualizar cupón (admin function)
  Future<void> updateCoupon(Coupon coupon) async {
    try {
      await _availableCoupons.doc(coupon.id).update(coupon.toMap());
    } catch (e) {
      throw Exception('Error al actualizar cupón: $e');
    }
  }
}
