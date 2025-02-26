import 'package:flutter/material.dart';
import 'package:student_app/services/student_service.dart';
import '../styles/colors.dart';
import 'package:provider/provider.dart';
import 'package:student_app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Будь ласка, заповніть всі поля');
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnackbar('Некоректний email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authProvider.login(email, password);
      //await StudentService.login(email, password);
      _showSnackbar('Вхід успішний');

      // Перехід на головний екран після входу
      //Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackbar('Помилка входу: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Вхід",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 24),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Введіть Email',
                  labelStyle: TextStyle(color: AppColors.black),
                  prefixIcon: Icon(Icons.email, color: AppColors.moonstone),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Введіть пароль',
                  labelStyle: TextStyle(color: AppColors.black),
                  prefixIcon: Icon(Icons.lock, color: AppColors.moonstone),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.gray,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.moonstone,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: AppColors.white)
                    : Text(
                  'Увійти',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
