import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/attendance_alert_message.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/review_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';

// Helper to format yyyy-mm-dd to dd-mm-yyyy
String _formatDate(String? date) {
  if (date == null) return '';
  try {
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return date;
  } catch (_) {
    return date;
  }
}

class AttendanceAlertScreen extends StatelessWidget {
  static const String page = 'AttendanceAlertScreen';

  final AttendanceAlertMessage? alert;

  const AttendanceAlertScreen({super.key, this.alert});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (alert != null) ...[
            if (alert!.imageURL?.isNotEmpty == true)
              ClipOval(
                child: Image.network(
                  alert!.imageURL!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 100),
                ),
              ),
            SizedBox(height: 24),
            Text(
              localizations.attendanceAlertTitle,
              key: const Key('attendanceAlertTitle'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              '${localizations.attendanceAlertStudent}: ${alert!.studentName}',
              key: const Key('attendanceAlertStudent'),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '${localizations.attendanceAlertMarkedBy}: ${alert!.markedBy}',
              key: const Key('attendanceAlertMarkedBy'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            if (alert!.markedForDate.isNotEmpty)
              Text(
                'Marked For Date: ${_formatDate(alert!.markedForDate)}',
                key: const Key('attendanceAlertMarkedForDate'),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 8),
            Text(
              '${localizations.attendanceAlertMarkedTime}: ${_formatDate(alert!.markedTime)}',
              key: const Key('attendanceAlertMarkedTime'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('attendanceAlertReviewButton'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(ReviewAttendanceScreen.page);
                },
                child: Text(localizations.reviewAttendanceButton),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                localizations.attendanceAlertNoData,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
