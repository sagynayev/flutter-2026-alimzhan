import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../widgets/empty_state.dart';
import '../widgets/responsive_session_collection.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    super.key,
  });

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onFavourite;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final _searchController = TextEditingController();
  StudyCategory? _category;
  String _query = '';
  bool _pastOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _pastOnly = false;
    });
  }

  List<StudySession> get _filtered {
    final query = _query.trim().toLowerCase();
    return widget.sessions
        .where(
          (session) =>
              query.isEmpty || session.title.toLowerCase().contains(query),
        )
        .where((session) => _category == null || session.category == _category)
        .where((session) => !_pastOnly || session.isPast)
        .toList()
      ..sort((a, b) {
        if (a.isPast != b.isPast) {
          return a.isPast ? 1 : -1;
        }
        return a.when.compareTo(b.when);
      });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search sessions',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              const SizedBox(width: 6),
              for (final category in StudyCategory.values) ...[
                ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
                const SizedBox(width: 6),
              ],
              FilterChip(
                label: const Text('Past only'),
                selected: _pastOnly,
                onSelected: (value) => setState(() => _pastOnly = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No sessions match these filters.',
                  buttonLabel: 'Clear filters',
                  onPressed: _clearFilters,
                )
              : ResponsiveSessionCollection(
                  sessions: filtered,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
