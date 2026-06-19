import '../models/coupon.dart';

class LocalCouponService {
  static List<Coupon> _availableCoupons = [];
  static List<Coupon> _userCoupons = [];
  static int _userPoints = 50; // Puntos iniciales

  // Obtener todos los cupones disponibles
  Future<List<Coupon>> getAvailableCoupons() async {
    // Si no hay cupones, crear los de ejemplo
    if (_availableCoupons.isEmpty) {
      await _createSampleCoupons();
    }
    return _availableCoupons;
  }

  // Obtener los cupones del usuario
  Future<List<Coupon>> getUserCoupons() async {
    return _userCoupons;
  }

  // Reclamar un cupón
  Future<void> claimCoupon(String couponId) async {
    final couponIndex = _availableCoupons.indexWhere((c) => c.id == couponId);
    if (couponIndex == -1) throw Exception('Cupón no encontrado');

    final coupon = _availableCoupons[couponIndex];
    
    if (!coupon.isAvailable) {
      throw Exception('El cupón ya no está disponible');
    }

    if (_userPoints < coupon.pointsRequired) {
      throw Exception('No tienes suficientes puntos para reclamar este cupón');
    }

    // Descontar puntos
    _userPoints -= coupon.pointsRequired;

    // Actualizar estado del cupón disponible
    _availableCoupons[couponIndex] = coupon.copyWith(
      status: CouponStatus.claimed,
      claimedAt: DateTime.now(),
    );

    // Crear copia para el usuario
    final userCoupon = coupon.copyWith(
      status: CouponStatus.claimed,
      claimedAt: DateTime.now(),
    );

    _userCoupons.add(userCoupon);
  }

  // Usar un cupón
  Future<void> useCoupon(String couponId) async {
    final couponIndex = _userCoupons.indexWhere((c) => c.id == couponId);
    if (couponIndex == -1) throw Exception('Cupón no encontrado');

    final coupon = _userCoupons[couponIndex];
    
    if (!coupon.canBeUsed) {
      throw Exception('Este cupón no puede ser usado');
    }

    // Actualizar estado del cupón a usado
    _userCoupons[couponIndex] = coupon.copyWith(
      status: CouponStatus.used,
      usedAt: DateTime.now(),
    );

    // Otorgar puntos adicionales por usar el cupón
    _userPoints += 10;
  }

  // Obtener estadísticas de cupones del usuario
  Future<Map<String, dynamic>> getCouponStats() async {
    final available = _userCoupons.where((c) => 
        c.status == CouponStatus.claimed && !c.isExpired).length;
    final used = _userCoupons.where((c) => c.status == CouponStatus.used).length;
    final expired = _userCoupons.where((c) => c.isExpired).length;

    return {
      'total': _userCoupons.length,
      'available': available,
      'used': used,
      'expired': expired,
    };
  }

  // Obtener puntos del usuario
  Future<int> getUserPoints() async {
    return _userPoints;
  }

  // Añadir puntos al usuario
  Future<void> addPoints(int points) async {
    _userPoints += points;
  }

  // Crear cupones de ejemplo
  Future<void> _createSampleCoupons() async {
    _availableCoupons = [
      Coupon(
        id: 'coupon_1',
        title: '20% de descuento en tienda ecológica',
        description: 'Obtén 20% de descuento en tu próxima compra en Tienda Verde',
        type: CouponType.discount,
        value: 20.0,
        partnerCompany: 'Tienda Verde',
        imageUrl: 'https://picsum.photos/seed/green-store/200/120',
        code: 'ECO20OFF',
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
        code: 'FREEBAG',
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
        code: 'DOUBLEXP',
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
      Coupon(
        id: 'coupon_4',
        title: 'Taller de compostaje gratis',
        description: 'Participa gratis en nuestro taller de compostaje y aprende a reducir residuos',
        type: CouponType.experience,
        value: 1.0,
        partnerCompany: 'EcoAcademy',
        imageUrl: 'https://picsum.photos/seed/compost-workshop/200/120',
        code: 'COMPOST24',
        pointsRequired: 120,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 45)),
        status: CouponStatus.available,
        terms: [
          'Taller presencial de 3 horas',
          'Material incluido',
          'Certificado de participación',
          'Válido para la próxima fecha disponible'
        ],
      ),
    ];
  }

  // Resetear datos locales
  void resetData() {
    _availableCoupons.clear();
    _userCoupons.clear();
    _userPoints = 50;
  }

  // Generar cupón automáticamente al completar tarea
  Future<Coupon> generateCouponForTask(String taskTitle, String taskCategory) async {
    final couponId = 'task_${DateTime.now().millisecondsSinceEpoch}';
    final couponType = _getCouponTypeForCategory(taskCategory);
    final pointsValue = _getPointsValueForCategory(taskCategory);
    
    final coupon = Coupon(
      id: couponId,
      title: _getCouponTitleForTask(taskTitle, taskCategory),
      description: _getCouponDescriptionForTask(taskCategory),
      type: couponType,
      value: pointsValue,
      partnerCompany: 'EcoTask Rewards',
      imageUrl: _getCouponImageForCategory(taskCategory),
      code: Coupon.generateCouponCode(),
      pointsRequired: 0, // Gratis por completar tarea
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      status: CouponStatus.claimed, // Ya reclamado automáticamente
      claimedAt: DateTime.now(),
      terms: [
        'Cupón generado automáticamente por completar tarea',
        'Válido por 30 días desde la generación',
        'No acumulable con otras promociones',
        'Máximo 1 uso por cliente'
      ],
    );

    // Añadir directamente a los cupones del usuario
    _userCoupons.add(coupon);
    
    return coupon;
  }

  // Determinar tipo de cupón según categoría
  CouponType _getCouponTypeForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'reciclaje':
      case 'recycling':
        return CouponType.discount;
      case 'energía':
      case 'energy':
        return CouponType.points;
      case 'agua':
      case 'water':
        return CouponType.freeProduct;
      default:
        return CouponType.experience;
    }
  }

  // Obtener valor de puntos según categoría
  double _getPointsValueForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'reciclaje':
      case 'recycling':
        return 15.0; // 15% descuento
      case 'energía':
      case 'energy':
        return 2.0; // Doble de puntos
      case 'agua':
      case 'water':
        return 1.0; // Producto gratis
      default:
        return 1.0;
    }
  }

  // Generar título del cupón según tarea
  String _getCouponTitleForTask(String taskTitle, String category) {
    switch (category.toLowerCase()) {
      case 'reciclaje':
      case 'recycling':
        return '15% de descuento en productos ecológicos';
      case 'energía':
      case 'energy':
        return 'Doble de puntos en tu próxima actividad';
      case 'agua':
      case 'water':
        return 'Producto ecológico gratis';
      default:
        return 'Recompensa especial por tu esfuerzo';
    }
  }

  // Generar descripción del cupón
  String _getCouponDescriptionForTask(String category) {
    switch (category.toLowerCase()) {
      case 'reciclaje':
      case 'recycling':
        return 'Por tu compromiso con el reciclaje, obtén 15% de descuento en nuestra tienda ecológica.';
      case 'energía':
      case 'energy':
        return 'Por ahorrar energía, duplica tus puntos en la próxima tarea que completes.';
      case 'agua':
      case 'water':
        return 'Por conservar el agua, elige un producto ecológico de nuestra selección completamente gratis.';
      default:
        return 'Por tu contribución al medio ambiente, disfruta de esta recompensa especial.';
    }
  }

  // Obtener imagen según categoría
  String _getCouponImageForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'reciclaje':
      case 'recycling':
        return 'https://picsum.photos/seed/recycling-reward/200/120';
      case 'energía':
      case 'energy':
        return 'https://picsum.photos/seed/energy-reward/200/120';
      case 'agua':
      case 'water':
        return 'https://picsum.photos/seed/water-reward/200/120';
      default:
        return 'https://picsum.photos/seed/eco-reward/200/120';
    }
  }

  // Inicializar datos
  Future<void> initialize() async {
    if (_availableCoupons.isEmpty) {
      await _createSampleCoupons();
    }
  }
}
