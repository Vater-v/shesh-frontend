import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../game/presentation/game_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Контроллер для свайпа страниц
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 5 Панелей
  final List<Widget> _pages = [
    const _LobbyView(),
    const _PlaceholderScreen(title: "Турниры", icon: Icons.emoji_events, description: "Соревнуйся за призы"),
    const _PlaceholderScreen(title: "Магазин", icon: Icons.storefront, description: "Скины, доски и кубики"),
    const _PlaceholderScreen(title: "Друзья", icon: Icons.people, description: "Чат и игры с друзьями"),
    const _ProfileView(), // Выделили профиль в отдельный виджет
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      // Плавная прокрутка к нужной странице
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Получаем цвета темы
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Используем Stack, чтобы положить красивый фон под всё приложение
      body: Stack(
        children: [
          // 1. Глобальный фон с градиентом
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F0F),
                  Color(0xFF181818),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),

          // 2. Декоративные круги на фоне (для атмосферы)
          Positioned(
            top: -100,
            right: -100,
            child: _GlowCircle(color: colorScheme.primary.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _GlowCircle(color: Colors.blueAccent.withOpacity(0.1)),
          ),

          // 3. Основной контент (PageView для свайпов)
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: _pages,
          ),
        ],
      ),

      // 4. Нижняя навигация
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212).withOpacity(0.9),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(icon: Icons.grid_view_rounded, label: "Лобби", isSelected: _currentIndex == 0, onTap: () => _onItemTapped(0)),
                _NavBarItem(icon: Icons.emoji_events_outlined, label: "Турниры", isSelected: _currentIndex == 1, onTap: () => _onItemTapped(1)),
                // Центральная кнопка (Магазин или Играть)
                _MainActionButton(onTap: () => _onItemTapped(2)),
                _NavBarItem(icon: Icons.people_outline, label: "Друзья", isSelected: _currentIndex == 3, onTap: () => _onItemTapped(3)),
                _NavBarItem(icon: Icons.person_outline, label: "Профиль", isSelected: _currentIndex == 4, onTap: () => _onItemTapped(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- ЛОББИ (Главный экран) ---

class _LobbyView extends StatefulWidget {
  const _LobbyView();

  @override
  State<_LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<_LobbyView> {
  String _username = "Гость";
  String? _rank = "Новичок";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await ApiService().getMe();
      if (mounted && user.login != null) {
        setState(() {
          _username = user.login!;
          // Тут можно добавить логику ранга
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Хедер
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[800],
                  foregroundImage: const AssetImage('assets/avatar_placeholder.png'), // Заглушка
                  child: Text(_username[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Привет, $_username", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(_rank!, style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37))),
                  ],
                ),
                const Spacer(),
                _GlassIconButton(icon: Icons.notifications_none, onTap: () {}),
                const SizedBox(width: 12),
                _GlassIconButton(icon: Icons.settings_outlined, onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Большая карточка "Быстрая игра"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _HeroPlayCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameBoardScreen())),
            ),
          ),

          const SizedBox(height: 32),

          // Карусель режимов игры
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Режимы игры", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Icon(Icons.arrow_forward, color: Colors.white54, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 160,
            child: PageView(
              padEnds: false,
              controller: PageController(viewportFraction: 0.85),
              children: const [
                _GameModeCard(title: "С компьютером", subtitle: "Тренировка", icon: Icons.computer, color: Colors.blueAccent),
                _GameModeCard(title: "С другом", subtitle: "На одном устройстве", icon: Icons.phonelink_ring, color: Colors.greenAccent),
                _GameModeCard(title: "Обучение", subtitle: "Правила и тактики", icon: Icons.school, color: Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- ВИДЖЕТЫ UI ---

// Красивая главная карточка
class _HeroPlayCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HeroPlayCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFA88620)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Stack(
          children: [
            // Фоновый узор
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(Icons.casino, size: 180, color: Colors.white.withOpacity(0.15)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text("1,204 онлайн", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text("ОНЛАЙН", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const Text("ИГРАТЬ", style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900, height: 1.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Карточка режима игры для карусели
class _GameModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _GameModeCard({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
                // Иллюстрация или декор справа
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.1), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Кастомная кнопка навигации
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFD4AF37) : Colors.white24;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// Центральная кнопка (акцентная)
class _MainActionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MainActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFA88620)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.4), blurRadius: 10)],
        ),
        child: const Icon(Icons.storefront, color: Colors.black, size: 28),
      ),
    );
  }
}

// Стеклянная кнопка
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

// Фоновый светящийся круг
class _GlowCircle extends StatelessWidget {
  final Color color;
  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

// Заглушка для новых экранов
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _PlaceholderScreen({required this.title, required this.icon, required this.description});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: const Color(0xFFD4AF37).withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }
}

// --- ПРОФИЛЬ (Вынесли отдельно) ---
class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFFD4AF37), child: Icon(Icons.person, size: 50, color: Colors.black)),
            const SizedBox(height: 16),
            const Text("Игрок", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                child: const Text("Выйти"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
