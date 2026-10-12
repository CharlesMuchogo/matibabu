import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/bloc/chats/chats_bloc.dart';
import 'package:matibabu/presentation/pages/chats_page.dart';
import 'package:matibabu/presentation/pages/history_page.dart';
import 'package:matibabu/presentation/pages/home_page.dart';
import 'package:matibabu/presentation/pages/profile_page.dart';
import 'package:matibabu/presentation/pages/search_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;

  static const _pages = [
    HomePage(),
    SearchPage(),
    HistoryPage(),
    ChatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final userId = context.select((AuthBloc bloc) => bloc.state.user?.id);
    final unread = context.select(
      (ChatsBloc bloc) => userId == null ? 0 : bloc.state.unreadFor(userId),
    );
    Widget badged(IconData icon) => Badge(
      isLabelVisible: unread > 0,
      label: Text("$unread"),
      child: Icon(icon),
    );

    return Scaffold(
      body: IndexedStack(index: _selected, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (index) => setState(() => _selected = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: badged(Icons.chat_bubble_outline_rounded),
            selectedIcon: badged(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
