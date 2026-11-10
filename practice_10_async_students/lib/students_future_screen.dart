import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/loading_view.dart';
import 'widgets/error_view.dart';
import 'widgets/empty_view.dart';
import 'widgets/student_list.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key, required this.api});
  final FakeApi api;
  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  // Not final: Retry deliberately replaces the request.
  late Future<List<Student>> _future;
  bool _compact = false;
  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = widget.api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FutureBuilder'),
      actions: [
        Switch(
          value: _compact,
          onChanged: (value) => setState(() => _compact = value),
        ),
        IconButton(
          tooltip: 'Reload',
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<List<Student>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(onRetry: _retry);
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final list = snapshot.data ?? const [];
        if (list.isEmpty) return const EmptyView();
        return StudentList(list, compact: _compact);
      },
    ),
  );
}
