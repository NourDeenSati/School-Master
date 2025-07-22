class Student {
  final String firstName;
  final String lastName;

  Student({
    required this.firstName,
    required this.lastName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}