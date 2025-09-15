class UserModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final String semester;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.semester,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'semester': semester,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? semester,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<String> getDepartments() {
    return [
      'Civil Engineering',
      'Electrical Engineering',
      'Mechanical Engineering',
      'Architecture',
      'Management Sciences',
      'Basic Science and Humanities',
      'Computer Science',
      'Nursing',
      'Allied Health Sciences',
      'Integrative Biosciences',
      'Pharmacy',
    ];
  }

  static List<String> getSemesters() {
    return [
      '1st Semester',
      '2nd Semester',
      '3rd Semester',
      '4th Semester',
      '5th Semester',
      '6th Semester',
      '7th Semester',
      '8th Semester',
    ];
  }
}
