class PetraDay {
  final bool isWorkingDay;
  final bool isAttendanceTaken;
  final String workingHours; // Format: "08:00|16:00" or "holiday"
  final DateTime date;

  PetraDay({
    required this.isWorkingDay,
    required this.isAttendanceTaken,
    required this.workingHours,
    required this.date,
  });

  /// Factory constructor to create PetraDay from API response
  factory PetraDay.fromJson(Map<String, dynamic> json) {
    return PetraDay(
      isWorkingDay: json['is_working_day'] as bool? ?? false,
      isAttendanceTaken: json['is_attendance_taken'] as bool? ?? false,
      workingHours: json['working_hours'] as String? ?? 'holiday',
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Convert PetraDay to JSON
  Map<String, dynamic> toJson() {
    return {
      'is_working_day': isWorkingDay,
      'is_attendance_taken': isAttendanceTaken,
      'working_hours': workingHours,
      'date': date.toIso8601String(),
    };
  }

  /// Create a copy with updated properties
  PetraDay copyWith({
    bool? isWorkingDay,
    bool? isAttendanceTaken,
    String? workingHours,
    DateTime? date,
  }) {
    return PetraDay(
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      isAttendanceTaken: isAttendanceTaken ?? this.isAttendanceTaken,
      workingHours: workingHours ?? this.workingHours,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'PetraDay{date: $date, isWorkingDay: $isWorkingDay, isAttendanceTaken: $isAttendanceTaken, workingHours: $workingHours}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetraDay &&
        other.date == date &&
        other.isWorkingDay == isWorkingDay &&
        other.isAttendanceTaken == isAttendanceTaken &&
        other.workingHours == workingHours;
  }

  @override
  int get hashCode =>
      date.hashCode ^
      isWorkingDay.hashCode ^
      isAttendanceTaken.hashCode ^
      workingHours.hashCode;
}
