import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/services/student_service.dart';

import '../models/teacher_model.dart';
import 'baseUrl.dart';

class TeacherService {
  static const String url = BaseUrl.baseUrl + 'teachers';

  // Отримати список вчителів студента
  static Future<List<Teacher>> getStudentTeachers() async {
    final token = await StudentService.getToken();
    if (token == null) throw Exception('Неавторизований доступ');

    final response = await http.get(
      Uri.parse('$url/student'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> teachersJson = jsonDecode(response.body);
      return teachersJson.map((json) => Teacher.fromJson(json)).toList();
    } else {
      throw Exception('Помилка завантаження списку вчителів');
    }
  }
}

