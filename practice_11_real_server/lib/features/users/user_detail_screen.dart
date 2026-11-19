import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});
  final User user;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(user.name)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(title: Text(user.username), subtitle: Text('ID: ${user.id}')),
        ListTile(title: Text(user.email), subtitle: const Text('Email')),
        ListTile(
          title: Text(user.phone),
          subtitle: Text(user.phoneDigits),
          onTap: () {},
        ),
        ListTile(
          title: Text(user.website ?? '—'),
          subtitle: const Text('Website'),
          onTap: () {},
        ),
        ListTile(
          title: Text('${user.address.street}, ${user.address.suite}'),
          subtitle: Text('${user.address.city}, ${user.address.zipcode}'),
        ),
        ListTile(
          title: Text('${user.address.geo.lat}, ${user.address.geo.lng}'),
          subtitle: const Text('Coordinates'),
        ),
        ListTile(
          title: Text(user.company.name),
          subtitle: Text('${user.company.catchPhrase}\n${user.companyBs}'),
        ),
      ],
    ),
  );
}
