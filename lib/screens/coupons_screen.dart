import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coupon.dart';
import '../services/local_coupon_service.dart';
import '../utils/app_theme.dart';
import '../widgets/eco_logo.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final LocalCouponService _couponService = LocalCouponService();
  List<Coupon> _coupons = [];
  bool _isLoading = true;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final coupons = await _couponService.getAvailableCoupons();
      final userPoints = await _getUserPoints();
      
      setState(() {
        _coupons = coupons;
        _userPoints = userPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cupones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int> _getUserPoints() async {
    try {
      return await _couponService.getUserPoints();
    } catch (e) {
      return 0;
    }
  }

  Future<void> _claimCoupon(Coupon coupon) async {
    try {
      // Mostrar diálogo de confirmación
      final confirmed = await _showClaimDialog(coupon);
      if (!confirmed) return;

      await _couponService.claimCoupon(coupon.id);
      
      // Recargar datos
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Cupón reclamado exitosamente: ${coupon.title}!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reclamar cupón: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showClaimDialog(Coupon coupon) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reclamar Cupón'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres reclamar este cupón?'),
            const SizedBox(height: 12),
            Text(
              'Tus puntos: $_userPoints',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Puntos requeridos: ${coupon.pointsRequired}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _userPoints >= coupon.pointsRequired 
                    ? Colors.green 
                    : Colors.red,
              ),
            ),
            if (_userPoints < coupon.pointsRequired) ...[
              const SizedBox(height: 8),
              Text(
                'No tienes suficientes puntos para reclamar este cupón.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Reclamar'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cupones Disponibles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de puntos del usuario
                    _buildPointsCard(),
                    const SizedBox(height: 24),
                    
                    // Lista de cupones
                    if (_coupons.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: _coupons.map((coupon) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCouponCard(coupon),
                          ),
                        ).toList(),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const EcoLogo(size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tus Puntos Ecológicos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_userPoints puntos disponibles',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Canjeables',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final canClaim = _userPoints >= coupon.pointsRequired;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del cupón
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              coupon.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: AppColors.lightBlue.withOpacity(0.3),
                  child: const Center(
                    child: Icon(
                      Icons.local_offer,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y empresa
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                if (coupon.partnerCompany != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Por: ${coupon.partnerCompany}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray,
                    ),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Descripción
                Text(
                  coupon.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Tipo y valor
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        coupon.type.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getCouponValueText(coupon),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Puntos requeridos y botón
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: canClaim ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${coupon.pointsRequired} puntos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canClaim ? Colors.amber : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: canClaim && coupon.isAvailable 
                          ? () => _claimCoupon(coupon) 
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canClaim && coupon.isAvailable 
                            ? AppColors.primary 
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8
                        ),
                      ),
                      child: Text(
                        coupon.isAvailable ? 'Reclamar' : 'No disponible',
                      ),
                    ),
                  ],
                ),
                
                // Fecha de expiración
                const SizedBox(height: 8),
                Text(
                  'Vence: ${_formatDate(coupon.expiresAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: coupon.isExpired ? Colors.red : AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay cupones disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve pronto para ver nuevas ofertas ecológicas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  String _getCouponValueText(Coupon coupon) {
    switch (coupon.type) {
      case CouponType.discount:
        return '${coupon.value.toInt()}% descuento';
      case CouponType.freeProduct:
        return 'Producto gratis';
      case CouponType.points:
        return '${coupon.value.toInt()}x puntos';
      case CouponType.experience:
        return 'Experiencia especial';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
