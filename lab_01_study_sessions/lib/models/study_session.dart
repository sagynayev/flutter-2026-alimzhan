import 'dart:collection';

import 'package:flutter/material.dart';

enum StudyCategory {
  programming('Programming', Icons.code),
  math('Math', Icons.calculate_outlined),
  language('Languages', Icons.translate),
  science('Science', Icons.science_outlined),
  career('Career', Icons.work_outline),
  design('Design', Icons.design_services_outlined);

  const StudyCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme colors) => switch (this) {
    StudyCategory.programming => colors.primary,
    StudyCategory.math => colors.secondary,
    StudyCategory.language => colors.tertiary,
    StudyCategory.science => colors.error,
    StudyCategory.career => colors.inversePrimary,
    StudyCategory.design => colors.onTertiaryContainer,
  };
}

class StudySession {
  const StudySession({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    required List<String> participants,
    required this.online,
    required this.favourite,
    this.description,
    // A private backing list keeps callers from mutating it through this model.
    // ignore: prefer_initializing_formals
  }) : _participants = participants;

  StudySession.empty()
    : id = 'session-${DateTime.now().microsecondsSinceEpoch}',
      title = '',
      category = StudyCategory.programming,
      when = DateTime.now().add(const Duration(days: 1)),
      place = '',
      limit = 10,
      _participants = const [],
      online = false,
      description = null,
      favourite = false;

  final String id;
  final String title;
  final StudyCategory category;
  final DateTime when;
  final String place;
  final int limit;
  final List<String> _participants;
  final bool online;
  final String? description;
  final bool favourite;

  UnmodifiableListView<String> get participants =>
      UnmodifiableListView(_participants);
  int get count => _participants.length;
  int get freePlaces => (limit - count).clamp(0, limit);
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => _participants.any((person) => person == name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  StudySession copyWith({
    String? title,
    StudyCategory? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? participants,
    bool? online,
    String? description,
    bool? favourite,
  }) => StudySession(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    place: place ?? this.place,
    limit: limit ?? this.limit,
    participants: participants ?? _participants,
    online: online ?? this.online,
    description: description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
