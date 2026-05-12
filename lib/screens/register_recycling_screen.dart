import 'package:flutter/material.dart';
import '../models/recycling_goal.dart';
import '../services/local_recycling_service.dart';
import '../utils/app_theme.dart';
import '../widgets/eco_logo.dart';

class RegisterRecyclingScreen extends StatefulWidget {
  const RegisterRecyclingScreen({super.key});

  @override
  State<RegisterRecyclingScreen> createState() => _RegisterRecyclingScreenState();
}

class _RegisterRecyclingScreenState extends State<RegisterRecyclingScreen> {
  final LocalRecyclingService _recyclingService = LocalRecyclingService();
  List<RecyclingGoal> _goals = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
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
      final goals = await _recyclingService.getGoals();
      final stats = await _recyclingService.getRecyclingStats();
      final points = await _recyclingService.getUserPoints();
      
      setState(() {
        _goals = goals;
        _stats = stats;
        _userPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar metas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddProgressDialog(RecyclingGoal goal) async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrar ${goal.materialType.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Actual: ${goal.currentAmount.toStringAsFixed(1)} / ${goal.targetAmount.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad a registrar',
                  hintText: 'Ej: 1.5',
                  suffixText: _getUnitSuffix(goal.materialType),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa una cantidad';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  final amount = double.parse(value);
                  if (amount <= 0) {
                    return 'La cantidad debe ser mayor a 0';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                
                final amount = double.parse(controller.text);
                Navigator.of(context).pop();
                
                try {
                  await _recyclingService.addProgress(goal.id, amount);
                  await _loadData();
                  
                  // Calcular puntos ganados
                  final pointsEarned = _calculatePointsDisplay(goal.materialType, amount);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¡Registrados ${amount.toStringAsFixed(1)} ${_getUnitSuffix(goal.materialType)}!'),
                            const SizedBox(height: 4),
                            Text('🌟 Has ganado $pointsEarned puntos ecológicos', 
                                 style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al registrar: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Registrar Reciclaje'),
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
                    // Estadísticas
                    if (_stats != null) _buildStatsCard(),
                    const SizedBox(height: 24),
                    
                    // Lista de metas
                    if (_goals.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: _goals.map((goal) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildGoalCard(goal),
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
                  'Tu Progreso de Reciclaje',
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
                  'Metas',
                  '${_stats!['totalGoals']}',
                  Icons.flag,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Completadas',
                  '${_stats!['completedGoals']}',
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Progreso',
                  '${_stats!['overallProgress'].toStringAsFixed(1)}%',
                  Icons.trending_up,
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

  Widget _buildGoalCard(RecyclingGoal goal) {
    final progress = goal.progress;
    final isCompleted = goal.isGoalCompleted;

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getMaterialIcon(goal.materialType),
                    color: isCompleted ? Colors.green : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.materialType.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Text(
                        'Meta: ${goal.targetAmount.toStringAsFixed(1)} ${_getUnitSuffix(goal.materialType)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso actual',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray,
                      ),
                    ),
                    Text(
                      '${goal.currentAmount.toStringAsFixed(1)} / ${goal.targetAmount.toStringAsFixed(1)} ${_getUnitSuffix(goal.materialType)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% completado',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? Colors.green : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCompleted ? null : () => _showAddProgressDialog(goal),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(isCompleted ? 'Meta Completada' : 'Registrar Cantidad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
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
            Icons.recycling_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay metas de reciclaje',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera meta para empezar a registrar tu progreso de reciclaje',
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

  IconData _getMaterialIcon(MaterialType material) {
    switch (material) {
      case MaterialType.bottles:
        return Icons.local_drink;
      case MaterialType.paper:
        return Icons.description;
      case MaterialType.boxes:
        return Icons.inventory_2;
    }
  }

  String _getUnitSuffix(MaterialType material) {
    switch (material) {
      case MaterialType.bottles:
        return 'unidades';
      case MaterialType.paper:
        return 'kg';
      case MaterialType.boxes:
        return 'unidades';
    }
  }

  int _calculatePointsDisplay(MaterialType materialType, double amount) {
    int basePoints;
    switch (materialType) {
      case MaterialType.bottles:
        basePoints = 5; // 5 puntos por botella
        break;
      case MaterialType.paper:
        basePoints = 2; // 2 puntos por kg
        break;
      case MaterialType.boxes:
        basePoints = 3; // 3 puntos por caja
        break;
    }

    return (basePoints * amount).round();
  }
}
