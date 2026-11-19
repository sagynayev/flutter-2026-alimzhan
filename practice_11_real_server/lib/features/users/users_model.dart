import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);
  final UserRepository _repo;
  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;

  Future<void> load() async {
    if (loading || saving || _disposed) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      if (!_disposed) items = result;
    } on ApiException catch (exception) {
      if (!_disposed) error = exception;
    } finally {
      loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> create(User draft) async {
    if (saving || loading || _disposed) return false;
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      if (_disposed) return false;
      // JSONPlaceholder assigns 11 repeatedly: keep IDs unique locally.
      items = [created, ...items.where((user) => user.id != created.id)];
      return true;
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repo.close();
    super.dispose();
  }
}
