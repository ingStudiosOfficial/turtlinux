import 'package:flutter/material.dart';

class InputOverlay extends StatefulWidget {
  final void Function(String) onPrompt;

  const InputOverlay({super.key, required this.onPrompt});

  @override
  State<InputOverlay> createState() => _InputOverlayState();
}

class _InputOverlayState extends State<InputOverlay> {
  final TextEditingController _promptTextController = TextEditingController();

  @override
  void dispose() {
    _promptTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(120),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(150),
                blurRadius: 16,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(50),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: TextField(
                  controller: _promptTextController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Ask Tutel',
                    border: InputBorder.none,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.mic),
                color: theme.colorScheme.onSurface,
              ),
              IconButton.filled(
                onPressed: _onSend,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSend() {
    widget.onPrompt(_promptTextController.text);
  }
}
