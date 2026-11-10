import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/loading_view.dart';
import 'widgets/error_view.dart';
import 'widgets/empty_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.api});
  final FakeApi api;
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  late final FakeApi _api = widget.api;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _save(BuildContext context) async {
    if (_saving || _students == null) return;
    setState(() => _saving = true);
    try {
      await _api.save(_students!.length);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on StateError catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _students == null && _error == null;
    Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: () => unawaited(_load()));
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(_students!);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('By hand'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: loading || _saving ? null : () => unawaited(_load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save',
        onPressed: _students == null || _saving
            ? null
            : () => unawaited(_save(context)),
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
