import 'package:flutter/material.dart';
import '../../../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../game/presentation/game_board_screen.dart';
import '../../../../core/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _LobbyView(),
    const Center(child: Text("История матчей", style: TextStyle(color: Colors.white54))),
    const Center(child: Text("Профиль", style: TextStyle(color: Colors.white54))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFFD4AF37).withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF1E1E1E),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.videogame_asset_outlined), selectedIcon: Icon(Icons.videogame_asset, color: Color(0xFFD4AF37)), label: 'Лобби'),
            NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: Color(0xFFD4AF37)), label: 'История'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFFD4AF37)), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}

class _LobbyView extends StatefulWidget {
  const _LobbyView();

  @override
  State<_LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<_LobbyView> {
  String _username = "Игрок";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService().getMe();
      if (mounted && user.login != null) {
        setState(() {
          _username = user.login!;
        });
      }
    } catch (e) {
      // Игнорируем ошибки при загрузке профиля
    }
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Добро пожаловать,", style: TextStyle(color: Colors.white.withOpacity(0.6))),
                    const SizedBox(height: 4),
                    Text(_username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    onPressed: () => _logout(context),
                    tooltip: "Выйти",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GameBoardScreen()));
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [const Color(0xFFD4AF37), const Color(0xFFD4AF37).withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Stack(
                  children: [
                    Positioned(right: -30, bottom: -30, child: Icon(Icons.casino, size: 200, color: Colors.white.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: const BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: const Text("ONLINE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const SizedBox(height: 12),
                          const Text("БЫСТРАЯ ИГРА", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)),
                          const Text("Рейтинговый матч", style: TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text("Режимы игры", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: const [
                _GameModeItem(title: "С компьютером", icon: Icons.computer, color: Color(0xFF4A90E2)),
                _GameModeItem(title: "С другом", icon: Icons.people_alt, color: Color(0xFF50E3C2)),
                _GameModeItem(title: "Турнир", icon: Icons.emoji_events, color: Color(0xFF9013FE)),
                _GameModeItem(title: "Обучение", icon: Icons.school, color: Color(0xFFFF9F00)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameModeItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _GameModeItem({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
