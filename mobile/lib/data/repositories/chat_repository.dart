import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  ChatRepository(this._service);
  final ChatService _service;

  Future<ApiResult<ChatReplyModel>> send(String message, {int? sessionId}) async {
    try {
      return Success(await _service.send(message, sessionId: sessionId));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
