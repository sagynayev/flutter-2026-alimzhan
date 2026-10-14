import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/study_session.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
    super.key,
  });

  final Profile profile;
  final List<StudySession> sessions;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _groupError(String? value) {
    final group = value?.trim() ?? '';
    if (group.isEmpty) {
      return null;
    }
    return RegExp(r'^[A-Za-z]{2,4}-\d{4}$').hasMatch(group)
        ? null
        : 'Use a format like CS-2426';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name.trim();
    final joinedCount = name.isEmpty
        ? 0
        : widget.sessions.fold<int>(
            0,
            (total, session) => total + (session.contains(name) ? 1 : 0),
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) {
              widget.onProfileChanged(
                widget.profile.copyWith(name: value.trim()),
              );
              _groupFocus.requestFocus();
            },
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _groupController,
            focusNode: _groupFocus,
            decoration: const InputDecoration(
              labelText: 'Group',
              border: OutlineInputBorder(),
            ),
            validator: _groupError,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) {
              if (_groupError(value) == null) {
                widget.onProfileChanged(
                  widget.profile.copyWith(group: value.trim()),
                );
              }
            },
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 20),
          Text('You are on $joinedCount lists'),
          const SizedBox(height: 24),
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('System'),
                selected: widget.themeMode == ThemeMode.system,
                onSelected: (_) => widget.onThemeModeChanged(ThemeMode.system),
              ),
              ChoiceChip(
                label: const Text('Light'),
                selected: widget.themeMode == ThemeMode.light,
                onSelected: (_) => widget.onThemeModeChanged(ThemeMode.light),
              ),
              ChoiceChip(
                label: const Text('Dark'),
                selected: widget.themeMode == ThemeMode.dark,
                onSelected: (_) => widget.onThemeModeChanged(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
