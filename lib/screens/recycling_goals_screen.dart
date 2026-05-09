import 'package:flutter/material.dart';
import 'package:to_do_ufpso/models/recycling_goal.dart';
import 'package:to_do_ufpso/services/recycling_goal_service.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';
import 'package:to_do_ufpso/widgets/eco_logo.dart';
import 'package:to_do_ufpso/widgets/recycling_goal_list.dart';

class RecyclingGoalsScreen extends StatefulWidget {
  const RecyclingGoalsScreen({super.key});

  @override
  State<RecyclingGoalsScreen> createState() => _RecyclingGoalsScreenState();
}

class _RecyclingGoalsScreenState extends State<RecyclingGoalsScreen> {
  final RecyclingGoalService _goalService = RecyclingGoalService();
  List<RecyclingGoal> _goals = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await _goalService.getGoals();
      final stats = await _goalService.getRecyclingStats();
      
      setState(() {
        _goals = goals;
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
            content: Text('Error al cargar las metas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteGoal(RecyclingGoal goal) async {
    try {
      await _goalService.deleteGoal(goal.id);
      await _loadGoals();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta eliminada exitosamente'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la meta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddProgressDialog(RecyclingGoal goal) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar progreso - ${goal.materialType.displayName}'),
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
                  labelText: 'Cantidad a agregar',
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
                  final wasCompleted = goal.isCompleted;
                  await _goalService.addProgress(goal.id, amount);
                  await _loadGoals();
                  
                  if (mounted) {
                    // Verificar si se acaba de completar la meta
                    final updatedGoal = _goals.firstWhere((g) => g.id == goal.id);
                    if (!wasCompleted && updatedGoal.isCompleted) {
                      // Celebración por meta completada
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.celebration, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('🎉 ¡Meta completada! Johan ha logrado su objetivo ambiental'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ¡${amount.toStringAsFixed(1)} ${_getUnitSuffix(goal.materialType)} registrados!'),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al agregar progreso: ${e.toString()}'),
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
              child: const Text('Agregar'),
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
        title: const Text('Metas de Reciclaje'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGoals,
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
                    RecyclingGoalList(
                      goals: _goals,
                      onAddProgress: _showAddProgressDialog,
                      onDelete: _deleteGoal,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGoalScreen(),
            ),
          ).then((_) => _loadGoals());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
                  'Tu Impacto Ambiental',
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
                  'Metas Totales',
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
                  'Progreso Total',
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
}
