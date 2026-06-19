import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do_ufpso/firebase_options.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';
import 'package:to_do_ufpso/screens/login_screen.dart';
import 'package:to_do_ufpso/screens/register_screen.dart';
import 'package:to_do_ufpso/screens/recycling_goals_screen.dart';
import 'package:to_do_ufpso/screens/coupons_screen.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Task',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/recycling-goals': (context) => const RecyclingGoalsScreen(),
        '/coupons': (context) => const CouponsScreen(),
      },
    );
  }
}
