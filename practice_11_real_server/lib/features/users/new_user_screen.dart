import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});
  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final model = context.read<UsersModel>();
    if (model.saving || _form.currentState?.validate() != true) return;
    final draft = User(
      id: 0,
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      website: null,
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
      companyBs: '',
    );
    try {
      final saved = await model.create(draft);
      if (!mounted) return;
      if (saved) Navigator.pop(context);
    } on ApiException catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        NoConnectionException() => 'No connection. Try again.',
        ServerException(:final status) => 'Server error: $status',
        NotFoundException() => 'Endpoint not found',
        UnauthorizedException() => 'Authorization required',
        BadResponseException() => 'Unexpected server response',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<UsersModel, bool>((model) => model.saving);
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  (value ?? '').trim().length < 2 ? 'Enter a name' : null,
            ),
            TextFormField(
              controller: _username,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a username' : null,
            ),
            TextFormField(
              controller: _email,
              enabled: !saving,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch((value ?? '').trim())
                  ? null
                  : 'Enter a valid email',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
