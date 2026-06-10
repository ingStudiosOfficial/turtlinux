import 'package:flutter/material.dart';

class ResponseOverlay extends StatelessWidget {
  final Stream<String> responseStream;

  const ResponseOverlay({super.key, required this.responseStream});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String currentResponse = '';

    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder(
      stream: responseStream,
      builder: (context, asyncSnapshot) {
        final incomingText = asyncSnapshot.data ?? '';
        currentResponse += incomingText;

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
                        child: Text(currentResponse),
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
}
