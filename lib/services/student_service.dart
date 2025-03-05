import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import 'baseUrl.dart';

class StudentService {
  static const String url = BaseUrl.baseUrl + 'students';

  // Отримати студента за ід
  static Future<Student> getStudentById(String id) async {
    final response = await http.get(Uri.parse('$url/$id'));

    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Помилка отримання даних студента');
    }
  }

  // Вхід
  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$url/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      final studentId = responseData['studentId'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('studentId', studentId);
    } else {
      throw Exception('Помилка входу: ${response.body}');
    }
  }

  // Вихід
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('studentId');
  }

  // Отримати токен
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Отримати ід учня
  static Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('studentId');
  }

  // Оновити інформацію про учня
  static Future<Student> updateStudent(String id, String email, String surname, String name,
      String className, DateTime dateOfBirth) async {
    final response = await http.put(
      Uri.parse('$url/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'surname': surname,
        'name': name,
        'studentClass': className,
        'dateOfBirth': dateOfBirth.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Student.fromJson(responseData['student']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Помилка оновлення: ${errorData['error']}');
    }
  }
}