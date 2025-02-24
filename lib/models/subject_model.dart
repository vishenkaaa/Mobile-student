class Subject {
  final String id;
  final String name;
  final String teacherId;
  final int hoursPerWeek;

  Subject({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.hoursPerWeek,
  });

  /*factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'] as String,
      name: json['name'] as String,
      teacherId: json['teacher'] as String,
      hoursPerWeek: json['hoursPerWeek'] as int,
    );
  }*/

  factory Subject.fromJson(Map<String, dynamic> json) {
    print("Parsing Subject: $json");

    return Subject(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Невідомий предмет',
      teacherId: json['teacher'] is Map<String, dynamic>
          ? json['teacher']['_id']?.toString() ?? ''
          : json['teacher']?.toString() ?? '',
      hoursPerWeek: json['hoursPerWeek'] is int
          ? json['hoursPerWeek']
          : int.tryParse(json['hoursPerWeek'].toString()) ?? 0,
    );
  }

}
