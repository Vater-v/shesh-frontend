import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/features/game/presentation/game_board_screen.dart';
import 'package:shesh/features/onboarding/presentation/pages/onboarding_screen.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/quick_play_banner.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  String _username = "Игрок";
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _apiService.getMe();
      if (mounted && user.login != null) {
        setState(() {
          _username = user.login!;
        });
      }
    } catch (e) {
      // Игнорируем ошибки при загрузке профиля (можно добавить логирование)
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _apiService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _navigateToGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameBoardScreen()),
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
            // Хедер
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Добро пожаловать,",
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    onPressed: () => _logout(context),
                    tooltip: "Выйти",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Баннер быстрой игры
            QuickPlayBanner(onTap: _navigateToGame),

            const SizedBox(height: 32),
            const Text(
              "Режимы игры",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Сетка режимов
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                GameModeCard(
                  title: "С компьютером",
                  icon: Icons.computer,
                  color: const Color(0xFF4A90E2),
                  onTap: () {}, // TODO: Добавить навигацию
                ),
                GameModeCard(
                  title: "С другом",
                  icon: Icons.people_alt,
                  color: const Color(0xFF50E3C2),
                  onTap: () {},
                ),
                GameModeCard(
                  title: "Турнир",
                  icon: Icons.emoji_events,
                  color: const Color(0xFF9013FE),
                  onTap: () {},
                ),
                GameModeCard(
                  title: "Обучение",
                  icon: Icons.school,
                  color: const Color(0xFFFF9F00),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
