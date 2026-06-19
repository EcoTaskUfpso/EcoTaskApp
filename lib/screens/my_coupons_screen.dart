import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../services/local_coupon_service.dart';
import '../utils/app_theme.dart';
import '../widgets/eco_logo.dart';
import 'coupons_screen.dart';

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  final LocalCouponService _couponService = LocalCouponService();
  List<Coupon> _coupons = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

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
      final coupons = await _couponService.getUserCoupons();
      final stats = await _couponService.getCouponStats();
      
      setState(() {
        _coupons = coupons;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tus cupones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _useCoupon(Coupon coupon) async {
    try {
      // Mostrar diálogo de confirmación
      final confirmed = await _showUseDialog(coupon);
      if (!confirmed) return;

      await _couponService.useCoupon(coupon.id);
      
      // Recargar datos
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Cupón usado exitosamente: ${coupon.title}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al usar cupón: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showUseDialog(Coupon coupon) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usar Cupón'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres usar este cupón?'),
            const SizedBox(height: 12),
            Text(
              'Cupón: ${coupon.title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Una vez usado, no podrás volver a utilizarlo.',
              style: TextStyle(color: Colors.orange),
            ),
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
            child: Text('Usar Cupón'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showCouponDetails(Coupon coupon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        if (coupon.partnerCompany != null)
                          Text(
                            'Por: ${coupon.partnerCompany}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  coupon.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: AppColors.lightBlue.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.local_offer,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Descripción
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                coupon.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Información del cupón
              Text(
                'Información del Cupón',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Tipo', coupon.type.displayName),
                    _buildInfoRow('Valor', _getCouponValueText(coupon)),
                    _buildInfoRow('Código', coupon.code),
                    _buildInfoRow('Reclamado', _formatDate(coupon.claimedAt!)),
                    _buildInfoRow('Expira', _formatDate(coupon.expiresAt)),
                    _buildInfoRow('Estado', coupon.status.displayName),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Términos y condiciones
              Text(
                'Términos y Condiciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              ...coupon.terms.map((term) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        term,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 32),
              
              // Botón de usar cupón
              if (coupon.canBeUsed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _useCoupon(coupon);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Usar Cupón'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mis Cupones'),
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
                    // Tarjeta de estadísticas
                    if (_stats != null) _buildStatsCard(),
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

  Widget _buildStatsCard() {
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
      child: Column(
        children: [
          Row(
            children: [
              const EcoLogo(size: 40),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mis Cupones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Disponibles',
                  '${_stats!['available']}',
                  Icons.local_offer,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Usados',
                  '${_stats!['used']}',
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Expirados',
                  '${_stats!['expired']}',
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
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
          // Header con imagen y estado
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  coupon.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
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
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(coupon.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    coupon.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Código del cupón
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Código: ${coupon.code}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Información adicional
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.gray,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expira: ${_formatDate(coupon.expiresAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: coupon.isExpired ? Colors.red : AppColors.gray,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getCouponValueText(coupon),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCouponDetails(coupon),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Ver Detalles'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    if (coupon.canBeUsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _useCoupon(coupon),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Usar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
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
            'No tienes cupones reclamados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visita la sección de cupones disponibles para reclamar tus primeras recompensas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CouponsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explorar Cupones'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CouponStatus status) {
    switch (status) {
      case CouponStatus.claimed:
        return AppColors.primary;
      case CouponStatus.used:
        return Colors.green;
      case CouponStatus.expired:
        return Colors.red;
      default:
        return Colors.grey;
    }
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
