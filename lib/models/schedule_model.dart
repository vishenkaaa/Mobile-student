import 'package:student_app/models/subject_model.dart';

class Schedule {
  final String id;
  final int dayOfWeek;
  final int lessonNumber;
  late final Subject subject;

  Schedule({
    required this.id,
    required this.dayOfWeek,
    required this.lessonNumber,
    required this.subject,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 0,
      lessonNumber: json['lessonNumber'] ?? 0,
      subject: json['subject'] != null
          ? Subject.fromJson(json['subject'])
          : Subject(id: '', name: 'Невідомий предмет', teacherId: '', hoursPerWeek: 0),
    );
  }


}