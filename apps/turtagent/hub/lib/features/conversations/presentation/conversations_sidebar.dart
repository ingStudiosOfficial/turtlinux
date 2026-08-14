import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtagent_hub/features/chat/presentation/chat.dart';
import 'package:turtagent_hub/features/conversations/providers/conversations_notifier.dart';

class ConversationsSidebar extends ConsumerStatefulWidget {
  final ChatContainerController chatContainerController;

  const ConversationsSidebar({
    super.key,
    required this.chatContainerController,
  });

  @override
  ConsumerState<ConversationsSidebar> createState() =>
      _ConversationsSidebarState();
}

class _ConversationsSidebarState extends ConsumerState<ConversationsSidebar> {
  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(child: const Text('Turtagent Hub')),
        conversationsState.when(
          data: (conversations) => Column(
            children: conversations.map((el) {
              return ListTile(
                title: Text(el.title),
                onTap: () {
                  widget.chatContainerController.setChat(el);
                  Navigator.of(context).pop();
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (String value) async {
                    switch (value) {
                      case 'delete':
                        {
                          await ref
                              .read(conversationsProvider.notifier)
                              .deleteConversation(el);
                          break;
                        }
                    }
                  },
                  itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: _buildPopupContent(
                        Icons.delete_outlined,
                        'Delete',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading conversations: $err'),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupContent(IconData icon, String text) {
    return Row(spacing: 12, children: [Icon(icon), Text(text)]);
  }
}
