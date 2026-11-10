import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'students_screen.dart';
import 'students_future_screen.dart';
import 'countdown_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Practice 10 - Sagynayev Alimzhan',
    theme: ThemeData(colorSchemeSeed: Colors.blue),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = FakeApi();
  final _emptyApi = FakeApi(empty: true);
  bool _empty = false;

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice 10')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Sagynayev Alimzhan', style: TextStyle(fontSize: 22)),
        const Text('Thursday 16:00-17:00'),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Empty API response'),
          value: _empty,
          onChanged: (value) => setState(() => _empty = value),
        ),
        FilledButton(
          onPressed: () async {
            await _open(StudentsScreen(api: _empty ? _emptyApi : _api));
          },
          child: const Text('By hand'),
        ),
        FilledButton(
          onPressed: () async {
            await _open(StudentsFutureScreen(api: _empty ? _emptyApi : _api));
          },
          child: const Text('FutureBuilder'),
        ),
        FilledButton(
          onPressed: () async {
            await _open(const CountdownScreen());
          },
          child: const Text('Countdown'),
        ),
      ],
    ),
  );
}
