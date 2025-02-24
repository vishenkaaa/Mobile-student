class Teacher {
  final String id;
  final String surname;
  final String name;
  final String fatherName;

  Teacher({required this.id, required this.surname, required this.name, required this.fatherName});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'],
      surname: json['surname'],
      name: json['name'],
      fatherName: json['fatherName'],
    );
  }
}
