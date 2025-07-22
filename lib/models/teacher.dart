class Teacher {
  final String firstName;
  final String lastName;
  final int popularity;

  Teacher({
    required this.firstName,
    required this.lastName,
    required this.popularity,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      firstName: json['first_name'],
      lastName: json['last_name'],
      popularity: json['popularity'],
    );
  }
}