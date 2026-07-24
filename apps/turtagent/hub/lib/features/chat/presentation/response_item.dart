import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ResponseItem extends StatefulWidget {
  final Stream<({bool isThinking, String text})> responseStream;

  const ResponseItem({super.key, required this.responseStream});

  @override
  State<ResponseItem> createState() => _ResponseItemState();
}

class _ResponseItemState extends State<ResponseItem> {
  String _currentThinking = '';
  String _currentResponse = '';
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void didUpdateWidget(ResponseItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.responseStream != widget.responseStream) {
      _cancelSubscription();
      _currentThinking = '';
      _currentResponse = '';
      _startListening();
    }
  }

  void _startListening() {
    _subscription = widget.responseStream.listen((data) {
      setState(() {
        if (data.isThinking) {
          _currentThinking += data.text;
        } else {
          _currentResponse += data.text;
        }
      });
    });
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentThinking.isNotEmpty)
                          _generateResponseBody(theme, _currentThinking, true),
                        if (_currentResponse.isNotEmpty)
                          _generateResponseBody(theme, _currentResponse, false),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generateResponseBody(
    ThemeData theme,
    String response,
    bool isThinking,
  ) {
    if (isThinking) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: MarkdownBody(data: response),
        ),
      );
    }

    return MarkdownBody(
      data: response,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 18),
        h1: const TextStyle(fontSize: 32),
        h2: const TextStyle(fontSize: 28),
      ),
    );
  }
}
