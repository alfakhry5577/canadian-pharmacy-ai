import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int id;
  final String subject;
  final String body;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.subject,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as int,
        subject: json['subject'] as String,
        body: json['body'] as String,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] as String,
      );

  @override
  List<Object?> get props => [id, subject, body, isRead, createdAt];
}
