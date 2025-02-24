class Student {
  final String id;
  final String email;
  final String surname;
  final String name;
  final String className;
  final DateTime dateOfBirth;

  Student({required this.id, required this.email, required this.surname, required this.name,
    required this.className, required this.dateOfBirth});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'],
      email: json['email'],
      surname: json['surname'],
      name: json['name'],
      className: json['class'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
    );
  }

  Student copyWith({
    String? surname,
    String? name,
    String? className,
    DateTime? dateOfBirth,
    String? email,
  }) {
    return Student(
      id: id,
      surname: surname ?? this.surname,
      name: name ?? this.name,
      className: className ?? this.className,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
    );
  }
}
