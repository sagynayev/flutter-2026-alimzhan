import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'users_model.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'new_user_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final Widget body;
    if (model.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = switch (model.error) {
        null => UserList(model.items),
        NoConnectionException() => MessageView(
          'No connection',
          onRetry: model.load,
        ),
        ServerException(:final status) => MessageView(
          'Server error: $status',
          onRetry: model.load,
        ),
        NotFoundException() => const MessageView('Users not found'),
        UnauthorizedException() => const MessageView('Authorization required'),
        BadResponseException() => const MessageView(
          'Unexpected server response. Please report this problem.',
        ),
      };
    }
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Users'),
            Text('Sagynayev Alimzhan', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: model.loading || model.saving ? null : model.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: model.load, child: body),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New user',
        onPressed: model.loading
            ? null
            : () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const NewUserScreen()),
                );
              },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView(this.message, {super.key, this.onRetry});
  final String message;
  final Future<void> Function()? onRetry;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: constraints.maxHeight * 0.32),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
        if (onRetry != null)
          Center(
            child: FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ),
      ],
    ),
  );
}

class UserList extends StatelessWidget {
  const UserList(this.items, {super.key});
  final List<User> items;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const MessageView('No users yet');
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = items[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text('${user.email}\n${user.address.city}'),
          isThreeLine: true,
          onTap: () async {
            await Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
            );
          },
        );
      },
    );
  }
}
