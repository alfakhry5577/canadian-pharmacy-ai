import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/chat_model.dart';

class ChatService {
  ChatService(this._dio);
  final Dio _dio;

  Future<ChatReplyModel> send(String message, {int? sessionId}) async {
    final response = await _dio.post(ApiPaths.chatSend, data: {
      'message': message,
      if (sessionId != null) 'session_id': sessionId,
    });
    return ChatReplyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ChatMessageModel>> history(int sessionId) async {
    final response = await _dio.get(ApiPaths.chatHistory(sessionId));
    return (response.data as List<dynamic>).map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
