class StudintInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String gender;

  StudintInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
  });

  factory StudintInfo.fromJson(Map<String, dynamic> json) {
    return StudintInfo(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}
