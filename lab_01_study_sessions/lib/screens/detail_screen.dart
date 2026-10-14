import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/study_session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _DetailAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.arguments, super.key});

  final DetailArguments arguments;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late StudySession _session = widget.arguments.session;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(
      context,
    ).pushNamed<StudySession>(Routes.form, arguments: FormArguments(_session));
    if (updated == null || !mounted) {
      return;
    }
    setState(() => _session = updated);
    widget.arguments.onChanged(updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(_session.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    widget.arguments.onDeleted(_session.id);
    Navigator.of(context).pop();
  }

  Future<void> _toggleParticipation() async {
    final name = widget.arguments.profileName.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in Profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              widget.arguments.onOpenProfile();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      return;
    }

    final joined = _session.contains(name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(joined ? 'Leave this session?' : 'Join this session?'),
        content: Text(_session.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(joined ? 'Leave' : 'Join'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final participants = [..._session.participants];
    if (joined) {
      participants.remove(name);
    } else {
      participants.add(name);
    }
    final updated = _session.copyWith(participants: participants);
    setState(() => _session = updated);
    widget.arguments.onChanged(updated);
  }

  void _handleMenu(_DetailAction action) {
    switch (action) {
      case _DetailAction.edit:
        _edit();
      case _DetailAction.delete:
        _delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final profileName = widget.arguments.profileName.trim();
    final joined = profileName.isNotEmpty && _session.contains(profileName);
    final disabled = !joined && (_session.isFull || _session.isPast);
    final (:taken, :free) = _session.places;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session.title),
          actions: [
            PopupMenuButton<_DetailAction>(
              onSelected: _handleMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _DetailAction.edit, child: Text('Edit')),
                PopupMenuItem(
                  value: _DetailAction.delete,
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              Tab(text: 'People ($taken)'),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 210,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/study_room.png',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Chip(
                      avatar: Icon(_session.category.icon),
                      label: Text(_session.category.label),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Chip(
                      label: Text(
                        describeCountdown(
                          countdownFor(_session.when, now: _now),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Date and time'),
                        subtitle: Text(formatDateTime(_session.when)),
                      ),
                      ListTile(
                        leading: Icon(
                          _session.online ? Icons.link : Icons.place_outlined,
                        ),
                        title: Text(_session.online ? 'Meeting link' : 'Place'),
                        subtitle: Text(_session.place),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: const Text('Places'),
                        subtitle: Text('$taken taken · $free free'),
                      ),
                      if (_session.description case final String description)
                        ListTile(
                          leading: const Icon(Icons.notes),
                          title: const Text('Description'),
                          subtitle: Text(description),
                        ),
                    ],
                  ),
                  _session.participants.isEmpty
                      ? const EmptyState(
                          icon: Icons.person_off_outlined,
                          message: 'Nobody has joined this session yet.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _session.participants.length,
                          itemBuilder: (context, index) {
                            final person = _session.participants[index];
                            final isYou = person == profileName;
                            return ListTile(
                              leading: CircleAvatar(child: Text(person[0])),
                              title: Text(
                                person,
                                style: isYou
                                    ? Theme.of(context).textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )
                                    : null,
                              ),
                              trailing: isYou ? const Text('You') : null,
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: disabled ? null : _toggleParticipation,
              icon: Icon(joined ? Icons.logout : Icons.person_add_alt),
              label: Text(joined ? 'Leave' : 'Join'),
              style: FilledButton.styleFrom(
                disabledBackgroundColor: colors.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
