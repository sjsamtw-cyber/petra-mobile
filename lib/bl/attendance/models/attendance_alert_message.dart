class AttendanceAlertMessage {
  final String studentName;
  final String markedBy;
  final String markedTime;
  final String markedForDate;
  final String? imageURL;

  AttendanceAlertMessage({
    required this.studentName,
    required this.markedBy,
    required this.markedTime,
    required this.markedForDate,
    this.imageURL,
  });
}
