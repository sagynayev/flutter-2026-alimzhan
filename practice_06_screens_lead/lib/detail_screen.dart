import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.student, super.key});

  final Student student;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Student _student = widget.student;

  Future<void> _edit() async {
    final name = await Navigator.of(context)
        .pushNamed<String>(Routes.edit, arguments: _student);
    if (name == null || !mounted) {
      return;
    }
    setState(() => _student = _student.copyWith(name: name));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_student.name),
      actions: [
        IconButton(
          tooltip: 'Edit name',
          onPressed: _edit,
          icon: const Icon(Icons.edit),
        ),
      ],
    ),
    body: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.school),
          title: const Text('Group'),
          subtitle: Text(_student.group),
        ),
        ListTile(
          leading: const Icon(Icons.mail),
          title: const Text('Email'),
          subtitle: Text(_student.email),
        ),
      ],
    ),
  );
}
