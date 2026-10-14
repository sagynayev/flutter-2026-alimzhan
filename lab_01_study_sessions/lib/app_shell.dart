import 'package:flutter/material.dart';

import 'data/seed_data.dart';
import 'models/profile.dart';
import 'models/study_session.dart';
import 'routes.dart';
import 'screens/favourites_tab.dart';
import 'screens/profile_tab.dart';
import 'screens/sessions_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<StudySession> _sessions = createSeedSessions();
  Profile _profile = const Profile.empty();
  int _tabIndex = 0;

  void _replaceSession(StudySession updated) {
    setState(() {
      _sessions = [
        for (final session in _sessions)
          if (session.id == updated.id) updated else session,
      ];
    });
  }

  void _removeSession(String id) {
    setState(() {
      _sessions = _sessions.where((session) => session.id != id).toList();
    });
  }

  void _toggleFavourite(StudySession session) {
    _replaceSession(session.copyWith(favourite: !session.favourite));
  }

  void _openDetail(StudySession session) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArguments(
        session: session,
        profileName: _profile.name,
        onChanged: _replaceSession,
        onDeleted: _removeSession,
        onOpenProfile: () => setState(() => _tabIndex = 2),
      ),
    );
  }

  Future<void> _openNewSession() async {
    final created = await Navigator.of(context).pushNamed<StudySession>(
      Routes.form,
      arguments: const FormArguments(null),
    );
    if (created == null || !mounted) {
      return;
    }
    setState(() => _sessions = [..._sessions, created]);
  }

  Future<void> _showAbout(BuildContext drawerContext) async {
    Navigator.of(drawerContext).pop();
    await showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('About'),
        content: Text(
          'Study Sessions helps students find and join small study meetings.',
        ),
      ),
    );
  }

  Future<void> _resetData(BuildContext drawerContext) async {
    Navigator.of(drawerContext).pop();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text('Sessions and profile changes will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _sessions = createSeedSessions();
      _profile = const Profile.empty();
      _tabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SessionsTab(
        sessions: _sessions,
        onOpen: _openDetail,
        onFavourite: _toggleFavourite,
      ),
      FavouritesTab(
        sessions: _sessions,
        onOpen: _openDetail,
        onFavourite: _toggleFavourite,
        onShowAll: () => setState(() => _tabIndex = 0),
      ),
      ProfileTab(
        profile: _profile,
        sessions: _sessions,
        themeMode: widget.themeMode,
        onProfileChanged: (profile) => setState(() => _profile = profile),
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];
    final titles = ['Study sessions', 'Favourites', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_tabIndex])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                leading: Icon(Icons.school_outlined),
                title: Text('Study Sessions'),
                subtitle: Text('Lab 1'),
              ),
              const Divider(),
              Builder(
                builder: (drawerContext) => ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () => _showAbout(drawerContext),
                ),
              ),
              Builder(
                builder: (drawerContext) => ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Reset data'),
                  onTap: () => _resetData(drawerContext),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _tabIndex, children: pages),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _openNewSession,
              tooltip: 'New session',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Sessions'),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
