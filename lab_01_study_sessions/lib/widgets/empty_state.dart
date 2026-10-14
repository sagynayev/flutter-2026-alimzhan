import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = buttonLabel;
    final action = onPressed;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (label != null && action != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: action, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
