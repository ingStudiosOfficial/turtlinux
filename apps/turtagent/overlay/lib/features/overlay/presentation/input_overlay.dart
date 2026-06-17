import 'package:flutter/material.dart';

class InputOverlayController {
  void Function()? onEnd;
}

class InputOverlay extends StatefulWidget {
  final void Function(String) onPrompt;
  final void Function() onStop;

  final InputOverlayController inputOverlayController;

  const InputOverlay({
    super.key,
    required this.onPrompt,
    required this.inputOverlayController,
    required this.onStop,
  });

  @override
  State<InputOverlay> createState() => _InputOverlayState();
}

class _InputOverlayState extends State<InputOverlay> {
  final TextEditingController _promptTextController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    widget.inputOverlayController.onEnd = _onDone;
  }

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
                  onSubmitted: (value) => _onSend(),
                ),
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.mic),
                color: theme.colorScheme.onSurface,
              ),
              _isGenerating
                  ? IconButton.filledTonal(
                      onPressed: _onStop,
                      icon: const Icon(Icons.stop),
                    )
                  : IconButton.filled(
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
    _setGeneratingState(true);
    _promptTextController.clear();
  }

  void _onStop() {
    widget.onStop();
    _setGeneratingState(false);
  }

  void _onDone() {
    _setGeneratingState(false);
  }

  void _setGeneratingState(bool state) {
    setState(() {
      _isGenerating = state;
    });
  }
}
