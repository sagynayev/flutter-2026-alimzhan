import 'package:flutter/foundation.dart';

import 'models/study_session.dart';

abstract final class Routes {
  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArguments {
  const DetailArguments({
    required this.session,
    required this.profileName,
    required this.onChanged,
    required this.onDeleted,
    required this.onOpenProfile,
  });

  final StudySession session;
  final String profileName;
  final ValueChanged<StudySession> onChanged;
  final ValueChanged<String> onDeleted;
  final VoidCallback onOpenProfile;
}

class FormArguments {
  const FormArguments(this.session);

  final StudySession? session;
}
