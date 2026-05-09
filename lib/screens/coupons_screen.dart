import 'package:flutter/material.dart';
import 'package:to_do_ufpso/models/coupon.dart';
import 'package:to_do_ufpso/services/coupon_service.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';
import 'package:to_do_ufpso/widgets/eco_logo.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final CouponService _couponService = CouponService();
  List<Coupon> _coupons = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final coupons = await _couponService.getCoupons();
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
            content: Text('Error al cargar los cupones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _useCoupon(Coupon coupon) async {
    try {
      await _couponService.useCoupon(coupon.id);
      await _loadCoupons();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Cupón ${coupon.code} usado exitosamente'),
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

  void _copyCouponCode(String code) {
    // Aquí podrías usar un paquete como flutter/services para copiar al portapapeles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código $code copiado al portapapeles'),
        backgroundColor: AppColors.primary,
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
            onPressed: _loadCoupons,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCoupons,
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
                    // Estadísticas
                    if (_stats != null) _buildStatsCard(),
                    const SizedBox(height: 24),
                    
                    // Lista de cupones
                    _coupons.isEmpty ? _buildEmptyState() : _buildCouponsList(),
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
            Colors.orange[400]!,
            Colors.orange[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
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
                  'Recompensas de Johan',
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
                  'Total',
                  '${_stats!['totalCoupons']}',
                  Icons.card_giftcard,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Válidos',
                  '${_stats!['validCoupons']}',
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Usados',
                  '${_stats!['usedCoupons']}',
                  Icons.done_all,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes cupones aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa tus metas de reciclaje para obtener recompensas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _coupons.length,
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        return _buildCouponCard(coupon);
      },
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isValid = coupon.isValid;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isValid ? Colors.orange[200]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(coupon),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(coupon),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (coupon.type == CouponType.discount)
                  Text(
                    '${coupon.value.toStringAsFixed(0)}% OFF',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Código del cupón
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      coupon.code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyCouponCode(coupon.code),
                    icon: const Icon(Icons.copy),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Descripción
            Text(
              coupon.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${_formatDate(coupon.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                if (coupon.expiresAt != null)
                  Text(
                    'Expira: ${_formatDate(coupon.expiresAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: coupon.isExpired ? Colors.red : Colors.grey[500],
                    ),
                  ),
              ],
            ),
            
            if (isValid && !coupon.isUsed)
              const SizedBox(height: 12),
            
            // Botón de usar
            if (isValid && !coupon.isUsed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _useCoupon(coupon),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Usar Cupón'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Coupon coupon) {
    if (coupon.isUsed) return Colors.grey;
    if (coupon.isExpired) return Colors.red;
    return Colors.green;
  }

  String _getStatusText(Coupon coupon) {
    if (coupon.isUsed) return 'Usado';
    if (coupon.isExpired) return 'Expirado';
    return 'Válido';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
