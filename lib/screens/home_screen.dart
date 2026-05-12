import 'package:flutter/material.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';
import 'package:to_do_ufpso/widgets/eco_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'coupons_screen.dart';
import 'my_coupons_screen.dart';
import 'init_coupons_screen.dart';
import '../services/local_coupon_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalCouponService _couponService = LocalCouponService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header con buscador y perfil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const EcoLogo(size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Eco-Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.gray,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Buscar tareas ecológicas...',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            _showProfileMenu(context);
                          },
                          icon: Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tarjeta de acceso rápido a metas de reciclaje
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[400]!,
                    Colors.green[600]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/recycling-goals');
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metas de Reciclaje',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Establece y sigue tus objetivos ambientales',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tarjeta de acceso a cupones
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/coupons');
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mis Cupones',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Recompensas por tus logros ambientales',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Lista de tareas organizadas por fecha
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Esta Semana
                  _buildTaskSection(
                    context: context,
                    title: 'Esta Semana',
                    tasks: _getTasksThisWeek(),
                    color: AppColors.primary,
                  ),
                  
                  // Este Mes
                  _buildTaskSection(
                    context: context,
                    title: 'Este Mes',
                    tasks: _getTasksThisMonth(),
                    color: AppColors.secondary,
                  ),
                  
                  // Próximo Mes
                  _buildTaskSection(
                    context: context,
                    title: 'Próximo Mes',
                    tasks: _getTasksNextMonth(),
                    color: AppColors.accent,
                  ),
                  
                  // Tareas Completadas
                  _buildTaskSection(
                    context: context,
                    title: 'Tareas Completadas',
                    tasks: _getCompletedTasks(),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Usuario Eco',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            Text(
              'usuario@ecotask.com',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.local_offer, color: AppColors.primary),
              title: Text('Cupones Disponibles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CouponsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard, color: AppColors.primary),
              title: Text('Mis Cupones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCouponsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: AppColors.primary),
              title: Text('Inicializar Sistema'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitCouponsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: AppColors.primary),
              title: Text('Mi Perfil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppColors.primary),
              title: Text('Configuración'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, EcoTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: task.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      task.icon,
                      color: task.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        Text(
                          task.category,
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
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Contadores y Progreso',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBlue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta: ${task.targetGoal}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Progreso actual: ${task.currentProgress}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: task.targetGoal > 0 ? (task.currentProgress / task.targetGoal) : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Contadores específicos:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTaskCounters(task),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Botones de acción
              if (!task.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _completeTask(context, task);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Completar Tarea'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editTask(context, task);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Tarea'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTask(context, task);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTask(BuildContext context, EcoTask task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    String selectedPriority = task.priority;
    String selectedCategory = task.category;
    DateTime? selectedDate = _parseDate(task.date);
    String repeatOption = 'No repetir';
    List<String> selectedDays = [];
    List<int> selectedDates = [];
    int targetGoal = task.targetGoal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar Tarea Ecológica',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            Text(
                              'Modifica los detalles de tu tarea',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.gray),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    'Título',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Reciclar botellas de plástico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe los detalles de tu tarea ecológica...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Meta
                  Text(
                    'Meta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ej: 50 botellas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (value) {
                      targetGoal = int.tryParse(value) ?? targetGoal;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.gray),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: AppColors.gray),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isNotEmpty && selectedDate != null) {
                              final updatedTask = EcoTask(
                                title: titleController.text,
                                date: '${selectedDate!.day} ${_getMonthName(selectedDate!.month)} ${selectedDate!.year}',
                                priority: selectedPriority,
                                category: selectedCategory,
                                description: descriptionController.text.isEmpty ? 'Sin descripción' : descriptionController.text,
                                icon: _getCategoryIcon(selectedCategory),
                                color: _getCategoryColor(selectedCategory),
                                counters: Map.from(task.counters),
                                targetGoal: targetGoal,
                                currentProgress: task.currentProgress,
                                isCompleted: task.isCompleted,
                              );
                              
                              final taskIndex = _ecoTasks.indexOf(task);
                              if (taskIndex != -1) {
                                setState(() {
                                  _ecoTasks[taskIndex] = updatedTask;
                                });
                              }
                              
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ Tarea actualizada: ${titleController.text}'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Guardar Cambios'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _completeTask(BuildContext context, EcoTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Completar Tarea'),
        content: Text('¿Estás seguro de que quieres marcar "${task.title}" como completada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final completedTask = EcoTask(
                title: task.title,
                date: task.date,
                priority: task.priority,
                category: task.category,
                description: task.description,
                icon: task.icon,
                color: task.color,
                counters: Map.from(task.counters),
                targetGoal: task.targetGoal,
                currentProgress: task.currentProgress,
                isCompleted: true,
              );
              
              final taskIndex = _ecoTasks.indexOf(task);
              if (taskIndex != -1) {
                setState(() {
                  _ecoTasks[taskIndex] = completedTask;
                });
              }
              
              // Generar cupón automáticamente
              try {
                final coupon = await _couponService.generateCouponForTask(task.title, task.category);
                
                Navigator.pop(context);
                
                // Mostrar mensaje con cupón
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¡Tarea completada: ${task.title}!'),
                        const SizedBox(height: 4),
                        Text('🎁 ¡Has ganado un cupón: ${coupon.title}!', 
                             style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Revisa "Mis Cupones" en el menú para usarlo.'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Ver Cupones',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyCouponsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Tarea completada: ${task.title}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, EcoTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _ecoTasks.remove(task);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Tarea eliminada: ${task.title}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'Media';
    String selectedCategory = 'Reciclaje';
    DateTime? selectedDate;
    String repeatOption = 'No repetir';
    List<String> selectedDays = [];
    List<int> selectedDates = [];
    
    // Variables para control de errores
    bool titleError = false;
    bool dateError = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nueva Tarea Ecológica',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            Text(
                              'Agrega una nueva meta para el planeta',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.gray),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    'Título',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    onChanged: (value) {
                      if (titleError) {
                        setState(() {
                          titleError = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Ej: Reciclar botellas de plástico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: titleError ? Colors.red : AppColors.gray.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: titleError ? Colors.red : AppColors.primary,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorText: titleError ? 'El título es obligatorio' : null,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe los detalles de tu tarea ecológica...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Categoría
                  Text(
                    'Categoría',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Reciclaje', child: Text('♻️ Reciclaje')),
                      DropdownMenuItem(value: 'Naturaleza', child: Text('🌿 Naturaleza')),
                      DropdownMenuItem(value: 'Compostaje', child: Text('🍂 Compostaje')),
                      DropdownMenuItem(value: 'Limpieza', child: Text('🏖️ Limpieza')),
                      DropdownMenuItem(value: 'Ahorro', child: Text('💧 Ahorro')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Prioridad
                  Text(
                    'Prioridad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Alta', 'Media', 'Baja'].map((priority) {
                      final isSelected = selectedPriority == priority;
                      final color = priority == 'Alta' 
                          ? Colors.red 
                          : priority == 'Media' 
                              ? Colors.orange 
                              : Colors.green;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPriority = priority;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? color : AppColors.gray.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              priority,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? color : AppColors.gray,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Fecha
                  Text(
                    'Fecha límite',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dateError ? Colors.red : AppColors.gray.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: dateError ? Colors.red : AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? '${selectedDate!.day} ${_getMonthName(selectedDate!.month)} ${selectedDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              color: selectedDate != null ? AppColors.darkGreen : (dateError ? Colors.red : AppColors.gray),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: dateError ? Colors.red : AppColors.gray),
                        ],
                      ),
                    ),
                  ),
                  if (dateError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'La fecha es obligatoria',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Repetir
                  Text(
                    'Repetir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: repeatOption,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'No repetir', child: Text('No repetir')),
                      DropdownMenuItem(value: 'Diario', child: Text('📅 Diario')),
                      DropdownMenuItem(value: 'Semanal', child: Text('📆 Semanal')),
                      DropdownMenuItem(value: 'Mensual', child: Text('📋 Mensual')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        repeatOption = value!;
                        selectedDays.clear();
                        selectedDates.clear();
                      });
                    },
                  ),
                  
                  // Opciones de repetición
                  if (repeatOption == 'Semanal') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Días de la semana',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'].map((day) {
                    final isSelected = selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDays.remove(day);
                          } else {
                            selectedDays.add(day);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.gray.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.gray,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else if (repeatOption == 'Mensual') ...[
                const SizedBox(height: 16),
                Text(
                  'Días del mes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(31, (index) {
                    final day = index + 1;
                    final isSelected = selectedDates.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDates.remove(day);
                          } else {
                            selectedDates.add(day);
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.gray.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.gray,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
                  
                  const SizedBox(height: 32),
                  
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.gray),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: AppColors.gray),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Validar campos
                            bool hasError = false;
                            
                            if (titleController.text.isEmpty) {
                              setState(() {
                                titleError = true;
                              });
                              hasError = true;
                            }
                            
                            if (selectedDate == null) {
                              setState(() {
                                dateError = true;
                              });
                              hasError = true;
                            }
                            
                            if (!hasError) {
                              _addNewTask(
                                title: titleController.text,
                                description: descriptionController.text,
                                category: selectedCategory,
                                priority: selectedPriority,
                                date: selectedDate!,
                                repeatOption: repeatOption,
                                repeatDays: selectedDays,
                                repeatDates: selectedDates,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Agregar Tarea'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  void _addNewTask({
    required String title,
    required String description,
    required String category,
    required String priority,
    required DateTime date,
    required String repeatOption,
    required List<String> repeatDays,
    required List<int> repeatDates,
  }) {
    final newTask = EcoTask(
      title: title,
      date: '${date.day} ${_getMonthName(date.month)} ${date.year}',
      priority: priority,
      category: category,
      description: description.isEmpty ? 'Sin descripción' : description,
      icon: _getCategoryIcon(category),
      color: _getCategoryColor(category),
      isCompleted: false,
    );
    
    setState(() {
      _ecoTasks.add(newTask);
      _ecoTasks.sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Tarea agregada: $title'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Reciclaje': return Icons.recycling;
      case 'Naturaleza': return Icons.nature;
      case 'Compostaje': return Icons.compost;
      case 'Limpieza': return Icons.beach_access;
      case 'Ahorro': return Icons.water_drop;
      default: return Icons.eco;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Reciclaje': return AppColors.primary;
      case 'Naturaleza': return AppColors.secondary;
      case 'Compostaje': return AppColors.brown;
      case 'Limpieza': return AppColors.accent;
      case 'Ahorro': return AppColors.lightBlue;
      default: return AppColors.primary;
    }
  }

  Widget _buildTaskSection({
    required BuildContext context,
    required String title,
    required List<EcoTask> tasks,
    required Color color,
  }) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Lista de tareas de esta sección
        ...tasks.map((task) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              _showTaskDetails(context, task);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Círculo de completado
                  GestureDetector(
                    onTap: () {
                      if (!task.isCompleted) {
                        _completeTask(context, task);
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted ? Colors.green : AppColors.gray.withOpacity(0.5),
                          width: 2,
                        ),
                        color: task.isCompleted ? Colors.green : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Icono de la tarea
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: task.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      task.icon,
                      color: task.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Información de la tarea
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.gray,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.date,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: task.priority == 'Alta' 
                                    ? Colors.red.withOpacity(0.1)
                                    : task.priority == 'Media'
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.priority,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: task.priority == 'Alta' 
                                      ? Colors.red
                                      : task.priority == 'Media'
                                          ? Colors.orange
                                          : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Menú de opciones
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.gray,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editTask(context, task);
                      } else if (value == 'complete') {
                        _completeTask(context, task);
                      } else if (value == 'delete') {
                        _deleteTask(context, task);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Text('Completar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTaskCounters(EcoTask task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: task.counters.entries.map((entry) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGreen,
                ),
                onChanged: (value) {
                  // Actualizar el contador
                  final newValue = int.tryParse(value) ?? 0;
                  setState(() {
                    task.counters[entry.key] = newValue;
                    // Recalcular el progreso total
                    int total = 0;
                    task.counters.forEach((key, value) {
                      total += value;
                    });
                    // Actualizar el progreso creando una nueva tarea con los valores actualizados
                    final updatedTask = EcoTask(
                      title: task.title,
                      date: task.date,
                      priority: task.priority,
                      category: task.category,
                      description: task.description,
                      icon: task.icon,
                      color: task.color,
                      counters: Map.from(task.counters),
                      targetGoal: task.targetGoal,
                      currentProgress: total,
                      isCompleted: task.isCompleted,
                    );
                    
                    // Reemplazar la tarea en la lista
                    final taskIndex = _ecoTasks.indexOf(task);
                    if (taskIndex != -1) {
                      _ecoTasks[taskIndex] = updatedTask;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<EcoTask> _getTasksThisWeek() {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    
    return _ecoTasks.where((task) {
      final taskDate = _parseDate(task.date);
      return !task.isCompleted &&
             taskDate.isAfter(now.subtract(const Duration(days: 1))) && 
             taskDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<EcoTask> _getTasksThisMonth() {
    final now = DateTime.now();
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _ecoTasks.where((task) {
      final taskDate = _parseDate(task.date);
      return !task.isCompleted &&
             taskDate.month == now.month && 
             taskDate.year == now.year &&
             !taskDate.isBefore(now) &&
             !taskDate.isAfter(monthEnd);
    }).toList();
  }

  List<EcoTask> _getTasksNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final nextMonthEnd = DateTime(now.year, now.month + 2, 0);
    
    return _ecoTasks.where((task) {
      final taskDate = _parseDate(task.date);
      return !task.isCompleted &&
             taskDate.isAfter(nextMonth.subtract(const Duration(days: 1))) && 
             taskDate.isBefore(nextMonthEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<EcoTask> _getCompletedTasks() {
    return _ecoTasks.where((task) => task.isCompleted).toList();
  }

  DateTime _parseDate(String dateString) {
    // Formato esperado: "DD MMM YYYY" (ej: "25 Mar 2026")
    final parts = dateString.split(' ');
    final day = int.parse(parts[0]);
    final monthMap = {
      'Ene': 1, 'Feb': 2, 'Mar': 3, 'Abr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Ago': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dic': 12,
    };
    final month = monthMap[parts[1]] ?? 1;
    final year = int.parse(parts[2]);
    
    return DateTime(year, month, day);
  }
}

class EcoTask {
  final String title;
  final String date;
  final String priority;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, int> counters; // Contadores para cada categoría
  final int targetGoal; // Meta total a alcanzar
  final int currentProgress; // Progreso actual
  final bool isCompleted; // Estado de completado

  EcoTask({
    required this.title,
    required this.date,
    required this.priority,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    this.counters = const {},
    this.targetGoal = 0,
    this.currentProgress = 0,
    this.isCompleted = false,
  });
}

final List<EcoTask> _ecoTasks = [
  EcoTask(
    title: 'Reciclar botellas de plástico',
    date: '25 Mar 2026',
    priority: 'Alta',
    category: 'Reciclaje',
    description: 'Separar y llevar al centro de reciclaje todas las botellas de plástico acumuladas esta semana. Esto ayudará a reducir la contaminación y promover una economía circular.',
    icon: Icons.recycling,
    color: AppColors.primary,
    counters: {
      'Botellas de plástico': 12,
      'Envases de cartón': 8,
      'Papel reciclado': 15,
    },
    targetGoal: 50,
    currentProgress: 35,
    isCompleted: false,
  ),
  EcoTask(
    title: 'Plantar árboles en el parque',
    date: '28 Mar 2026',
    priority: 'Media',
    category: 'Naturaleza',
    description: 'Participar en la jornada de reforestación comunitaria. Lleva guantes y ropa cómoda. Plantaremos 20 árboles nativos para mejorar la calidad del aire.',
    icon: Icons.nature,
    color: AppColors.secondary,
    counters: {
      'Árboles plantados': 8,
      'Hectáreas reforestadas': 2,
    },
    targetGoal: 20,
    currentProgress: 8,
    isCompleted: false,
  ),
  EcoTask(
    title: 'Compostaje orgánico',
    date: '30 Mar 2026',
    priority: 'Baja',
    category: 'Compostaje',
    description: 'Iniciar el compostaje con residuos orgánicos de la cocina. Revisar el compostador y añadir los materiales necesarios para acelerar el proceso.',
    icon: Icons.compost,
    color: AppColors.brown,
    counters: {
      'Residuos orgánicos': 25,
      'Compostaje logrado (kg)': 35,
    },
    targetGoal: 100,
    currentProgress: 35,
    isCompleted: false,
  ),
  EcoTask(
    title: 'Limpiar playa local',
    date: '01 Abr 2026',
    priority: 'Alta',
    category: 'Limpieza',
    description: 'Organizar una jornada de limpieza en la playa cercana. Recoger plásticos y otros residuos que afectan la vida marina. Coordinar con autoridades locales.',
    icon: Icons.beach_access,
    color: AppColors.accent,
    counters: {
      'Envases de plástico': 45,
      'Residuos de vidrio': 23,
      'Residuos orgánicos': 12,
    },
    targetGoal: 200,
    currentProgress: 45,
    isCompleted: false,
  ),
  EcoTask(
    title: 'Reducir consumo de agua',
    date: '02 Abr 2026',
    priority: 'Media',
    category: 'Ahorro',
    description: 'Implementar medidas para reducir el consumo de agua en casa. Revisar fugas, instalar dispositivos de ahorro y educar a la familia sobre prácticas sostenibles.',
    icon: Icons.water_drop,
    color: AppColors.lightBlue,
    counters: {
      'Litros de agua ahorrados': 250,
      'Duchas cortadas': 15,
    },
    targetGoal: 1000,
    currentProgress: 250,
    isCompleted: false,
  ),
];
