import 'subject_model.dart';

class Teacher {
  final String id;
  final String surname;
  final String name;
  final String fatherName;
  final List<Subject> subjects;

  Teacher({
    required this.id,
    required this.surname,
    required this.name,
    required this.fatherName,
    required this.subjects,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'],
      surname: json['surname'],
      name: json['name'],
      fatherName: json['fatherName'],
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((subjectJson) => Subject.fromJson(subjectJson))
          .toList() ??
          [],
    );
  }
}
