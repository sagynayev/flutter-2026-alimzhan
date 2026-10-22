import 'package:flutter/material.dart';

import 'summary_card.dart';

const studentName = 'Sagynayev Alimzhan';
const practiceTitle = 'Flutter Practice 8';
const studentGroup = 'Thursday 16:00-17:00';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '$practiceTitle — $studentName',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController(text: studentName);
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();

  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _done = true);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthController.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    });
  }

  void _startOver() {
    setState(() {
      for (final c in [_email, _password, _confirm, _birthController]) {
        c.clear();
      }
      _name.text = studentName;
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 82,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(practiceTitle),
          Text(studentName, style: TextStyle(fontSize: 14)),
          Text(studentGroup, style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
    body: _done ? _buildSummary() : _buildForm(),
  );

  Widget _buildSummary() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SummaryCard(
          name: _name.text,
          email: _email.text,
          group: _group ?? '—',
          birthDate: _birthController.text.isEmpty
              ? '—'
              : _birthController.text,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Student name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final text = (v ?? '').trim();
              if (text.length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final text = (v ?? '').trim();
              if (!text.contains('@') || !text.contains('.')) {
                return 'Email looks wrong';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onChanged: (v) => setState(() => _passwordLength = v.length),
            validator: (v) {
              if ((v ?? '').length < 8) return 'Password is too short';
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              '$_passwordLength of 8',
              style: TextStyle(
                fontSize: 12,
                color: _passwordLength >= 8 ? Colors.teal : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              if ((v ?? '') != _password.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: groups
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _group = v),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _birthController,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: _pickDate,
            validator: (_) => _birth == null ? 'Pick a date of birth' : null,
          ),
          const SizedBox(height: 8),

          CheckboxListTile(
            title: const Text('I agree to the rules'),
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _submit : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}
