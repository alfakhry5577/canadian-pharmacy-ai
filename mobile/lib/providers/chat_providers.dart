import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_model.dart';
import 'core_providers.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final int? sessionId;
  final bool isSending;
  final bool escalateToPharmacist;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.sessionId,
    this.isSending = false,
    this.escalateToPharmacist = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    int? sessionId,
    bool? isSending,
    bool? escalateToPharmacist,
    String? errorMessage,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        sessionId: sessionId ?? this.sessionId,
        isSending: isSending ?? this.isSending,
        escalateToPharmacist: escalateToPharmacist ?? this.escalateToPharmacist,
        errorMessage: errorMessage,
      );
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this.ref) : super(const ChatState());
  final Ref ref;
  int _localIdCounter = -1;

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    final optimisticMessage = ChatMessageModel(
      id: _localIdCounter--,
      role: ChatRole.user,
      content: text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(messages: [...state.messages, optimisticMessage], isSending: true, errorMessage: null);

    final result = await ref.read(chatRepositoryProvider).send(text.trim(), sessionId: state.sessionId);

    result.when(
      success: (data) {
        state = state.copyWith(
          messages: [...state.messages, data.reply],
          sessionId: data.sessionId,
          isSending: false,
          escalateToPharmacist: data.escalateToPharmacist,
        );
      },
      failure: (f) => state = state.copyWith(isSending: false, errorMessage: f.message),
    );
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose<ChatController, ChatState>(
  (ref) => ChatController(ref),
);

const List<String> suggestedQuestionsAr = [
  'ما الفرق بين بنادول وبروفين؟',
  'هل يمكنني أخذ دواء البرد مع أدويتي المزمنة؟',
  'كيف أعرف أن دوائي قارب على النفاد؟',
  'ما معنى ظهور علامة "تعارض دوائي" في وصفتي؟',
];
