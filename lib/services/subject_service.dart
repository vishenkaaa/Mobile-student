import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/models/subject_model.dart';
import 'package:student_app/services/student_service.dart';

import 'baseUrl.dart';

class SubjectService {
  static const String url = BaseUrl.baseUrl + 'subjects';

  // Отримати список всіх предметів
  static Future<List<Subject>> getAllSubjects(String studentId) async {
    final token = await StudentService.getToken();
    if (token == null) throw Exception('Неавторизований доступ');

    final response = await http.get(
      Uri.parse('$url/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List subjectJson = jsonDecode(response.body);
      return subjectJson.map((json) => Subject.fromJson(json)).toList();
    } else {
      throw Exception('Помилка завантаження списку предметів');
    }
  }

  // Отримати список предметів вчителя
  static Future<List<Subject>> getAllTeacherSubjects(String teacherId) async {
    final token = await StudentService.getToken();
    if (token == null) throw Exception('Неавторизований доступ');

    final response = await http.get(
      Uri.parse('$url/teacher/$teacherId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List subjectJson = jsonDecode(response.body);
      return subjectJson.map((json) => Subject.fromJson(json)).toList();
    } else {
      throw Exception('Помилка завантаження списку предметів');
    }
  }
}