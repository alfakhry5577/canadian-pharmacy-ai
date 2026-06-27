import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_model.dart';
import '../providers/chat_providers.dart';
import 'primary_button.dart';
import 'safety_callout.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send([String? text]) {
    final message = text ?? _controller.text;
    if (message.trim().isEmpty) return;
    ref.read(chatControllerProvider.notifier).send(message);
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SafetyCallout(
            severity: CalloutSeverity.info,
            title: 'مساعد معلومات عامة، وليس بديلاً عن الطبيب أو الصيدلاني',
            message: 'لا يقدّم هذا المساعد تشخيصًا ولا يغيّر جرعات علاجية. في الحالات العاجلة، تواصل فورًا مع الصيدلاني أو الطوارئ.',
          ),
        ),
        if (chatState.escalateToPharmacist)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SafetyCallout(
              severity: CalloutSeverity.critical,
              title: 'يُفضّل التواصل المباشر',
              message: 'بناءً على رسالتك، يُنصح بالتواصل فورًا مع الصيدلاني أو الطبيب أو الطوارئ.',
            ),
          ),
        Expanded(
          child: chatState.messages.isEmpty
              ? _SuggestedQuestionsView(onPick: _send)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, i) => _ChatBubble(message: chatState.messages[i]),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'اكتب سؤالك هنا...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton.filled(
                    icon: chatState.isSending
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    onPressed: chatState.isSending ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestedQuestionsView extends StatelessWidget {
  const _SuggestedQuestionsView({required this.onPick});
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('جرّب أحد الأسئلة الشائعة، أو اكتب سؤالك مباشرة', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ...suggestedQuestionsAr.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PrimaryButton(label: q, outlined: true, onPressed: () => onPick(q)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isUser ? Colors.white : theme.colorScheme.onSurfaceVariant, height: 1.4),
        ),
      ),
    );
  }
}
