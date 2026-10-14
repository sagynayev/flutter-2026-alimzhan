import 'package:flutter/material.dart';

import '../models/study_session.dart';
import 'session_card.dart';

class ResponsiveSessionCollection extends StatelessWidget {
  const ResponsiveSessionCollection({
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    super.key,
  });

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onFavourite;

  Widget _card(StudySession session) => SessionCard(
    session: session,
    onTap: () => onOpen(session),
    onFavourite: () => onFavourite(session),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 600) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.8,
          ),
          itemCount: sessions.length,
          itemBuilder: (context, index) => _card(sessions[index]),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) => _card(sessions[index]),
        separatorBuilder: (context, index) => const SizedBox(height: 4),
      );
    },
  );
}
