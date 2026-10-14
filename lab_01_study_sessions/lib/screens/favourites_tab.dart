import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../widgets/empty_state.dart';
import '../widgets/responsive_session_collection.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    required this.onShowAll,
    super.key,
  });

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onFavourite;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final favourites = sessions.where((session) => session.favourite).toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.star_border,
        message: 'No favourite sessions yet.',
        buttonLabel: 'Browse sessions',
        onPressed: onShowAll,
      );
    }
    return ResponsiveSessionCollection(
      sessions: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
