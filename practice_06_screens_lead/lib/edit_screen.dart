import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({required this.student, super.key});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _name = widget.student.name;
  bool _allowPop = false;

  bool get _dirty => _name != widget.student.name;

  void _popAfterBuild([String? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }

  Future<void> _handleBack(bool didPop) async {
    if (didPop) {
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && context.mounted) {
      _popAfterBuild();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<String>(
    canPop: !_dirty || _allowPop,
    onPopInvokedWithResult: (didPop, result) => _handleBack(didPop),
    child: Scaffold(
      appBar: AppBar(title: const Text('Edit student')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'New name',
                hintText: widget.student.name,
              ),
              onChanged: (value) => setState(() => _name = value),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _popAfterBuild(_name),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
