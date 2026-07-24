import 'package:flutter/material.dart';
import 'package:turtagent_hub/data/models/chat_types.dart';

class ConversationsSidebar extends StatefulWidget {
  const ConversationsSidebar({super.key});

  @override
  State<ConversationsSidebar> createState() => _ConversationsSidebarState();
}

class _ConversationsSidebarState extends State<ConversationsSidebar> {
  final List<ChatHistory> _conversations = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ..._conversations.map((el) {
          return ListTile(title: const Text('hi'));
        }),
        DrawerHeader(child: const Text('Turtagent Hub')),
      ],
    );
  }
}
