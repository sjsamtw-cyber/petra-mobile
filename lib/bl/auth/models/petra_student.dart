import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_gender.dart';

class PetraStudent {
  /*
    "user_id": 373,
    "first_name": "Kristen",
    "middle_name": "",
    "last_name": "Saviyo",
    "gender": 1,
    "photo_url": "na",
    "class_teacher_id": 2,
    "roll_no": "1",
    "admission_no": "QASTU0080",
    "father_first_nm": "Saviyo",
    "father_middle_nm": null,
    "father_last_nm": "Kumar"
   */
  int studentDetailId; // Same as the user ID
  String firstName;
  String middleName;
  String lastName;
  UserGender? gender;
  int classDetailID;
  String classHRName; // Names like 'I','IV' etc
  String classDivision; // Names like 'A','B' etc
  int teacherId;
  String? imageUrl;
  bool?
  attendanceStatus; // Used in pages like attendance, null means not marked.
  String? remarks; // Used in pages like attendance.
  String? rollNo;
  String? fatherFirstName;
  String? fatherMiddleName;
  String? fatherLastName;
  String? admissionNumber;

  PetraStudent({
    required this.studentDetailId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.classDetailID,
    required this.classDivision,
    required this.classHRName,
    required this.teacherId,
    required this.imageUrl,
    this.attendanceStatus,
    this.remarks,
    this.rollNo,
    this.fatherFirstName,
    this.fatherMiddleName,
    this.fatherLastName,
    this.admissionNumber,
  });
  String get fullName {
    return '$firstName $middleName $lastName';
  }

  String get fatherFullName {
    final first = fatherFirstName ?? '';
    final middle = fatherMiddleName ?? '';
    final last = fatherLastName ?? '';
    return '$first $middle $last'.trim();
  }

  String get className {
    return '$classHRName $classDivision';
  }

  static bool isStudentList(List values) {
    bool valid = true;
    for (var value in values) {
      if (!isMapInstance(value)) {
        valid = false;
      }
    }
    return valid;
  }

  static List<PetraStudent> getStudentList(List values) {
    List<PetraStudent> students = [];
    for (var value in values) {
      students.add(
        PetraStudent(
          studentDetailId: value['user_id'],
          firstName: value['first_name'],
          middleName: value['middle_name'],
          lastName: value['last_name'],
          gender: UserGenderDetails.getGenderFromNumber(value['gender']),
          classDetailID: value['class_detail_id'],
          classDivision: value['class_division'],
          classHRName: value['class_hr_name'],
          teacherId: value['class_teacher_id'],
          imageUrl: value['photo_url'],
          attendanceStatus: null != value['attendance_status']
              ? ('p' == value['attendance_status'])
              : null,
          remarks: value['remarks'] ?? '',
        ),
      );
    }
    return students;
  }

  static bool isMapInstance(Map value) {
    return value.containsKey('user_id') &&
        value['user_id'] is int &&
        value.containsKey('first_name') &&
        value['first_name'] is String &&
        value.containsKey('middle_name') &&
        value['middle_name'] is String &&
        value.containsKey('last_name') &&
        value['last_name'] is String &&
        value.containsKey('gender') &&
        value['gender'] is int &&
        value.containsKey('photo_url') &&
        value['photo_url'] is String &&
        value.containsKey('class_detail_id') &&
        value['class_detail_id'] is int &&
        value.containsKey('class_hr_name') &&
        value['class_hr_name'] is String &&
        value.containsKey('class_division') &&
        value['class_division'] is String &&
        value.containsKey('class_teacher_id') &&
        value['class_teacher_id'] is int &&
        value.containsKey('attendance_status') &&
        value['attendance_status'] is String;
  }

  /// Factory constructor to create PetraStudent from API response
  factory PetraStudent.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Debug: PetraStudent.fromJson - Input JSON: $json');
    }

    // Handle missing or null fields with defaults
    final studentDetailId = json['user_id'] as int? ?? 0;
    final firstName = json['first_name'] as String? ?? 'Unknown';
    final middleName = json['middle_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? 'Student';
    final genderValue = json['gender'] as int? ?? 1;
    final classDetailID = json['class_detail_id'] as int? ?? 0;
    final classDivision = json['class_division'] as String? ?? 'A';
    final classHRName = json['class_hr_name'] as String? ?? 'Unknown';
    final teacherId = json['class_teacher_id'] as int? ?? 0;
    final imageUrl = json['photo_url'] as String?;
    final remarks = json['remarks'] as String? ?? ''; // Attendance remarks
    final rollNo = json['roll_no'] as String?;
    final fatherFirstName = json['father_first_nm'] as String?;
    final fatherMiddleName = json['father_middle_nm'] as String?;
    final fatherLastName = json['father_last_nm'] as String?;
    final admissionNumber = json['admission_no'] as String?;

    // Handle attendance status
    bool? attendanceStatus;
    if (json['attendance_status'] != null) {
      if (json['attendance_status'] is String) {
        attendanceStatus = json['attendance_status'] == 'p';
      } else if (json['attendance_status'] is bool) {
        attendanceStatus = json['attendance_status'] as bool;
      }
    }

    if (kDebugMode) {
      print(
        'Debug: Parsed student - ID: $studentDetailId, Name: $firstName $middleName $lastName',
      );
    }

    final student = PetraStudent(
      studentDetailId: studentDetailId,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      gender: UserGenderDetails.getGenderFromNumber(genderValue),
      classDetailID: classDetailID,
      classDivision: classDivision,
      classHRName: classHRName,
      teacherId: teacherId,
      imageUrl: imageUrl,
      attendanceStatus: attendanceStatus,
      remarks: remarks,
      rollNo: rollNo,
      fatherFirstName: fatherFirstName,
      fatherMiddleName: fatherMiddleName,
      fatherLastName: fatherLastName,
      admissionNumber: admissionNumber,
    );

    if (kDebugMode) {
      print('Debug: Created PetraStudent: ${student.fullName}');
    }
    return student;
  }

  /// Convert PetraStudent to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': studentDetailId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'gender': gender != null
          ? (gender == UserGender.male
                ? 1
                : gender == UserGender.female
                ? 2
                : 1)
          : 1,
      'class_detail_id': classDetailID,
      'class_division': classDivision,
      'class_hr_name': classHRName,
      'class_teacher_id': teacherId,
      'photo_url': imageUrl,
      'attendance_status': attendanceStatus != null
          ? (attendanceStatus! ? 'p' : 'a')
          : null,
      'remarks': remarks,
    };
  }

  /// Create a copy with updated properties (useful for attendance marking)
  PetraStudent copyWith({
    int? studentDetailId,
    String? firstName,
    String? middleName,
    String? lastName,
    UserGender? gender,
    int? classDetailID,
    String? classHRName,
    String? classDivision,
    int? teacherId,
    String? imageUrl,
    bool? attendanceStatus,
    String? remarks,
    String? rollNo,
    String? fatherFirstName,
    String? fatherMiddleName,
    String? fatherLastName,
    String? admissionNumber,
  }) {
    return PetraStudent(
      studentDetailId: studentDetailId ?? this.studentDetailId,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      classDetailID: classDetailID ?? this.classDetailID,
      classHRName: classHRName ?? this.classHRName,
      classDivision: classDivision ?? this.classDivision,
      teacherId: teacherId ?? this.teacherId,
      imageUrl: imageUrl ?? this.imageUrl,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      remarks: remarks ?? this.remarks,
      rollNo: rollNo ?? this.rollNo,
      fatherFirstName: fatherFirstName ?? this.fatherFirstName,
      fatherMiddleName: fatherMiddleName ?? this.fatherMiddleName,
      fatherLastName: fatherLastName ?? this.fatherLastName,
      admissionNumber: admissionNumber ?? this.admissionNumber,
    );
  }
}
