import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/services/student_service.dart';
import '../models/schedule_model.dart';
import '../models/subject_model.dart';

class ScheduleService {
  static const String baseUrl = 'http://localhost:5000/schedule';

  // Отримати розклад
  static Future<List<Schedule>> getSchedule(String studentId) async {
    final token = await StudentService.getToken();
    if (token == null) throw Exception('Неавторизований доступ');

    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Schedule.fromJson(item)).toList();
    } else {
      throw Exception('Не вдалося завантажити розклад');
    }
  }
}
