import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant, system }

ChatRole chatRoleFromString(String value) =>
    ChatRole.values.firstWhere((r) => r.name == value, orElse: () => ChatRole.assistant);

class ChatMessageModel extends Equatable {
  final int id;
  final ChatRole role;
  final String content;
  final String createdAt;

  const ChatMessageModel({required this.id, required this.role, required this.content, required this.createdAt});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'] as int,
        role: chatRoleFromString(json['role'] as String),
        content: json['content'] as String,
        createdAt: json['created_at'] as String,
      );

  @override
  List<Object?> get props => [id, role, content, createdAt];
}

class ChatReplyModel extends Equatable {
  final int sessionId;
  final ChatMessageModel reply;
  final bool escalateToPharmacist;

  const ChatReplyModel({required this.sessionId, required this.reply, required this.escalateToPharmacist});

  factory ChatReplyModel.fromJson(Map<String, dynamic> json) => ChatReplyModel(
        sessionId: json['session_id'] as int,
        reply: ChatMessageModel.fromJson(json['reply'] as Map<String, dynamic>),
        escalateToPharmacist: json['escalate_to_pharmacist'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [sessionId, reply, escalateToPharmacist];
}
