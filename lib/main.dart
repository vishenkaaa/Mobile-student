import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/providers/auth_provider.dart';
import 'package:student_app/screens/home_screen.dart';
import 'package:student_app/screens/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return authProvider.isAuthenticated ? HomeScreen() : LoginScreen();
        },
      ),
    );
  }
}
