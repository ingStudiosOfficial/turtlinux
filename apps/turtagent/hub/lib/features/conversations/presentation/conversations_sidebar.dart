import 'package:flutter/material.dart';
import 'package:turtagent_hub/core/data/models/chat_types.dart';

class ConversationsSidebar extends StatefulWidget {
  const ConversationsSidebar({super.key});

  @override
  State<ConversationsSidebar> createState() => _ConversationsSidebarState();
}

class _ConversationsSidebarState extends State<ConversationsSidebar> {
  final Conversations _conversations = [
    (title: 'Cool chat', history: []),
    (title: 'Another cool chat', history: []),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(child: const Text('Turtagent Hub')),
        ..._conversations.map((el) {
          return ListTile(title: Text(el.title));
        }),
      ],
    );
  }
}
