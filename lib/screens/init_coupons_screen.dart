import 'package:flutter/material.dart';
import '../services/local_coupon_service.dart';
import '../services/local_eco_points_service.dart';
import '../utils/app_theme.dart';

class InitCouponsScreen extends StatefulWidget {
  const InitCouponsScreen({super.key});

  @override
  State<InitCouponsScreen> createState() => _InitCouponsScreenState();
}

class _InitCouponsScreenState extends State<InitCouponsScreen> {
  final LocalCouponService _couponService = LocalCouponService();
  final LocalEcoPointsService _pointsService = LocalEcoPointsService();
  bool _isInitializing = false;
  bool _couponsCreated = false;
  bool _userInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Inicialización del Sistema'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del sistema
            _buildInfoCard(),
            const SizedBox(height: 24),
            
            // Botones de inicialización
            _buildActionButtons(),
            const SizedBox(height: 24),
            
            // Estado de inicialización
            _buildStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sistema de Cupones EcoTask',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta pantalla te permite inicializar el sistema de cupones y puntos ecológicos para probar la funcionalidad de la aplicación.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Características:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...[
            '• Sistema de puntos por completar tareas',
            '• Cupones canjeables con puntos',
            '• Recompensas por reciclaje',
            '• Seguimiento de actividades ecológicas',
          ].map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Text(
                    feature.substring(2),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Inicializar usuario
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _userInitialized ? null : _initializeUser,
            icon: _userInitialized 
                ? const Icon(Icons.check_circle) 
                : _isInitializing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add),
            label: Text(_userInitialized ? 'Usuario Inicializado' : 'Inicializar Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _userInitialized ? Colors.green : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Crear cupones de ejemplo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _couponsCreated ? null : _createSampleCoupons,
            icon: _couponsCreated 
                ? const Icon(Icons.check_circle) 
                : _isInitializing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.local_offer),
            label: Text(_couponsCreated ? 'Cupones Creados' : 'Crear Cupones de Ejemplo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _couponsCreated ? Colors.green : AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Resetear sistema
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isInitializing ? null : _resetSystem,
            icon: const Icon(Icons.refresh),
            label: const Text('Resetear Sistema'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del Sistema',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildStatusItem('Usuario', _userInitialized ? 'Inicializado' : 'No inicializado'),
          _buildStatusItem('Cupones', _couponsCreated ? 'Creados' : 'No creados'),
          _buildStatusItem('Sistema', _isInitializing ? 'Procesando...' : 'Listo'),
          
          if (_userInitialized && _couponsCreated) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sistema listo para usar. Ahora puedes acceder a las funcionalidades de cupones y puntos desde el menú principal.',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: status.contains('Inicializado') || status.contains('Creados') 
                  ? Colors.green 
                  : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeUser() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      await _pointsService.initializeUser();
      
      setState(() {
        _userInitialized = true;
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Usuario inicializado con 50 puntos de bienvenida!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar usuario: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleCoupons() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      await _couponService.initialize();
      
      setState(() {
        _couponsCreated = true;
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cupones de ejemplo creados exitosamente!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear cupones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetSystem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Sistema'),
        content: const Text(
          '¿Estás seguro de que quieres resetear el sistema? Esto eliminará todos los datos de prueba.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _userInitialized = false;
        _couponsCreated = false;
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sistema reseteado. Vuelve a inicializar para comenzar.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
