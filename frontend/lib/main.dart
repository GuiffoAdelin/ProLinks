import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _authFuture;

  @override
  void initState() {
    super.initState();
    // Vérification du token au lancement
    _authFuture = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProLinks',

      // THÈME CLAIR
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6A1B9A), // Ton violet
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF6A1B9A),
          elevation: 0.5,
        ),
      ),

      // THÈME SOMBRE
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFBB86FC), // Violet clair pour lisibilité
        scaffoldBackgroundColor: const Color(0xFF000000), // Noir profond
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Color(0xFFBB86FC),
          elevation: 0.5,
        ),
      ),

      themeMode: ThemeMode.system, // Utilise le réglage du téléphone

      home: FutureBuilder(
        future: _authFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Consumer<AuthProvider>(
            builder: (ctx, auth, _) =>
                auth.isAuth ? const HomeScreen() : const LoginScreen(),
          );
        },
      ),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
