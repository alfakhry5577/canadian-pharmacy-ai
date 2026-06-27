import 'package:flutter/material.dart';
import '../../widgets/chat_view.dart';

class PharmacistChatScreen extends StatelessWidget {
  const PharmacistChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: const ChatView(),
    );
  }
}
