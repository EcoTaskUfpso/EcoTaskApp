import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../utils/app_theme.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;
  final VoidCallback? onUse;
  final bool showActions;
  final int? userPoints;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onTap,
    this.onClaim,
    this.onUse,
    this.showActions = true,
    this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    final canClaim = userPoints != null && userPoints! >= coupon.pointsRequired;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y estado
            Stack(
              children: [
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  
                  // Puntos requeridos y acciones
                  if (showActions) ...[
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
                        if (coupon.isAvailable && onClaim != null)
                          ElevatedButton(
                            onPressed: canClaim ? onClaim : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canClaim ? AppColors.primary : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, 
                                vertical: 8
                              ),
                            ),
                            child: const Text('Reclamar'),
                          )
                        else if (coupon.canBeUsed && onUse != null)
                          ElevatedButton(
                            onPressed: onUse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, 
                                vertical: 8
                              ),
                            ),
                            child: const Text('Usar'),
                          )
                        else
                          Text(
                            coupon.isExpired ? 'Expirado' : 'No disponible',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                  
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
      ),
    );
  }

  Color _getStatusColor(CouponStatus status) {
    switch (status) {
      case CouponStatus.available:
        return AppColors.primary;
      case CouponStatus.claimed:
        return Colors.blue;
      case CouponStatus.used:
        return Colors.green;
      case CouponStatus.expired:
        return Colors.red;
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

// Widget compacto para lista de cupones
class CompactCouponCard extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback? onTap;
  final bool showStatus;

  const CompactCouponCard({
    super.key,
    required this.coupon,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_offer,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          coupon.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getCouponValueText(coupon),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Vence: ${_formatDate(coupon.expiresAt)}',
              style: TextStyle(
                fontSize: 11,
                color: coupon.isExpired ? Colors.red : AppColors.gray,
              ),
            ),
          ],
        ),
        trailing: showStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(coupon.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  coupon.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Color _getStatusColor(CouponStatus status) {
    switch (status) {
      case CouponStatus.available:
        return AppColors.primary;
      case CouponStatus.claimed:
        return Colors.blue;
      case CouponStatus.used:
        return Colors.green;
      case CouponStatus.expired:
        return Colors.red;
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
