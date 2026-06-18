import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ResponseOverlay extends StatelessWidget {
  final Stream<({bool isThinking, String text})> responseStream;

  const ResponseOverlay({super.key, required this.responseStream});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String currentResponse = '';

    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder(
      stream: responseStream,
      builder: (context, asyncSnapshot) {
        final incomingData = asyncSnapshot.data;

        currentResponse += incomingData?.text ?? '';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.5,
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: _generateResponseBody(
                          theme,
                          currentResponse,
                          incomingData?.isThinking ?? false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          color: theme.colorScheme.surfaceContainer,
          child: MarkdownBody(data: response),
        ),
      );
    }

    return MarkdownBody(data: response);
  }
}
