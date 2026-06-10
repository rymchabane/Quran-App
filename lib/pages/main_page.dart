import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import 'login_page.dart';
import 'stats_page.dart';
import 'reciters_list_page.dart';
import 'favorites_page.dart';
import '../widgets/mini_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _recitersNavKey = GlobalKey<NavigatorState>();

  Future<void> _logout() async {
    await AudioPlayerService().stop();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex == 1 && _recitersNavKey.currentState?.canPop() == true) {
      _recitersNavKey.currentState!.pop();
      return false;
    }
    return true;
  }

  Widget _buildRecitersTab() {
    return Navigator(
      key: _recitersNavKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const RecitersPage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const StatsPage(),
      _buildRecitersTab(),
      const FavoritesPage(),
    ];

    final labels = ['Stats', 'Reciters', 'Favorites'];
    final icons = [Icons.bar_chart_rounded, Icons.music_note_rounded, Icons.favorite_rounded];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D0D),
          elevation: 0,
          titleSpacing: 24,
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mosque_rounded, color: Color(0xFF00C853), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "Quran",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                " App",
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _logout,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFF9E9E9E), size: 18),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            pages[_currentIndex],
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  final isSelected = _currentIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00C853).withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icons[index],
                            color: isSelected ? const Color(0xFF00C853) : const Color(0xFF424242),
                            size: 22,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Text(
                              labels[index],
                              style: const TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
