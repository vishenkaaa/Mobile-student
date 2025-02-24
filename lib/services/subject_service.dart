import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/models/subject_model.dart';
import 'package:student_app/services/student_service.dart';

class SubjectService {
  static const String baseUrl = "http://localhost:5000/subjects";

  // Отримати список всіх предметів
  static Future<List<Subject>> getAllSubjects(String studentId) async {
    final token = await StudentService.getToken();
    if (token == null) throw Exception('Неавторизований доступ');

    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> subjectJson = jsonDecode(response.body);
      return subjectJson.map((json) => Subject.fromJson(json)).toList();
    } else {
      throw Exception('Помилка завантаження списку предметів');
    }
  }
}
