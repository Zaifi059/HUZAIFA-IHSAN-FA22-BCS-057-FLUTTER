class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender; // Male, Female, Other
  final String contact; // phone or other contact
  final String diagnosis;
  final String notes;
  final String? imagePath; // profile image path
  final List<String> filePaths; // Local paths to documents/images

  const Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.diagnosis,
    required this.notes,
    required this.filePaths,
    this.imagePath,
  });

  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? contact,
    String? diagnosis,
    String? notes,
    String? imagePath,
    List<String>? filePaths,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contact: contact ?? this.contact,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      filePaths: filePaths ?? this.filePaths,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact,
      'diagnosis': diagnosis,
      'notes': notes,
      'image_path': imagePath,
      'file_paths': filePaths.join('|'),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    final files = (map['file_paths'] as String?)?.split('|').where((e) => e.isNotEmpty).toList() ?? <String>[];
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: map['gender'] as String? ?? 'Other',
      contact: map['contact'] as String? ?? '',
      diagnosis: map['diagnosis'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      filePaths: files,
    );
  }
}


