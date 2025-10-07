import 'package:flutter/foundation.dart';

@immutable
class NotificationEvent {
  final String type;
  final Map<String, dynamic> data;
  final String? title;
  final String? body;

  const NotificationEvent({
    required this.type,
    required this.data,
    this.title,
    this.body,
  });

  factory NotificationEvent.fromMessage(Map<String, dynamic> message) {
    return NotificationEvent(
      type: message['petra_notification_type'] ?? 'unknown',
      data: Map<String, dynamic>.from(message),
      title: message['title'],
      body: message['body'],
    );
  }
}
