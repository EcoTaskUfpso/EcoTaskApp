import 'package:flutter/material.dart';
import 'package:to_do_ufpso/models/recycling_goal.dart' as models;
import 'package:to_do_ufpso/services/recycling_goal_service.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';
import 'package:to_do_ufpso/widgets/eco_logo.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final RecyclingGoalService _goalService = RecyclingGoalService();

  models.MaterialType _selectedMaterial = models.MaterialType.bottles;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      
      await _goalService.createGoal(
        materialType: _selectedMaterial,
        targetAmount: amount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Meta de reciclaje creada exitosamente!'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Crear Meta de Reciclaje'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const EcoLogo(size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Establece tu meta ambiental',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Define cuánto quieres reciclar y contribuye al planeta',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Selección de material
              const Text(
                'Tipo de material',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: models.MaterialType.values.map((material) {
                    return RadioListTile<models.MaterialType>(
                      title: Row(
                        children: [
                          Icon(
                            _getMaterialIcon(material),
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            material.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      value: material,
                      groupValue: _selectedMaterial,
                      onChanged: (models.MaterialType? value) {
                        setState(() {
                          _selectedMaterial = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Cantidad a reciclar
              const Text(
                'Cantidad a reciclar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ej: 10',
                  suffixText: _getUnitSuffix(),
                  prefixIcon: Icon(
                    Icons.eco,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                  if (amount > 10000) {
                    return 'La cantidad no puede ser mayor a 10,000';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botón de crear
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Creando meta...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 8),
                            Text(
                              'Crear Meta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(models.MaterialType material) {
    switch (material) {
      case models.MaterialType.bottles:
        return Icons.local_drink;
      case models.MaterialType.paper:
        return Icons.description;
      case models.MaterialType.boxes:
        return Icons.inventory_2;
    }
  }

  String _getUnitSuffix() {
    switch (_selectedMaterial) {
      case models.MaterialType.bottles:
        return 'unidades';
      case models.MaterialType.paper:
        return 'kg';
      case models.MaterialType.boxes:
        return 'unidades';
    }
  }
}
