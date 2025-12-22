import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shesh/features/home/presentation/pages/lobby_view.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/features/onboarding/presentation/pages/onboarding_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late PageController _pageController;

  // Мы хотим, чтобы "Лобби" (индекс 2) было по центру при старте.
  // Задаем "бесконечный" центр. 1000 * 5 = 5000. Плюс 2 (индекс лобби) = 5002.
  static const int _initialPageCenter = 5002;
  int _currentIndex = 2; // Реальный индекс (0-4) для отображения в BottomBar

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPageCenter);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();

    // Получаем текущую "виртуальную" страницу (например, 5003)
    final int currentVirtualPage = _pageController.page!.round();

    // Вычисляем реальный текущий индекс (например, 3)
    final int currentRealIndex = currentVirtualPage % _pages.length;

    // Считаем разницу, чтобы понять, куда скроллить (вперед или назад)
    // Например, если мы на 3, а нажали на 1, разница -2.
    final int diff = index - currentRealIndex;

    // Анимируем к новой виртуальной странице
    _pageController.animateToPage(
      currentVirtualPage + diff,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );

    setState(() {
      _currentIndex = index;
    });
  }

  void _onPageChanged(int index) {
    // Магия бесконечности: получаем остаток от деления на длину списка (5)
    // 5000 % 5 = 0, 5001 % 5 = 1 и т.д.
    setState(() {
      _currentIndex = index % _pages.length;
    });
  }

  // --- СПИСОК СТРАНИЦ ---
  final List<Widget> _pages = [
    const _ProfileView(),                                                 // 0: Профиль
    const _PlaceholderScreen(title: "Магазин", icon: Icons.storefront),   // 1: Магазин
    const LobbyView(),                                                    // 2: ЛОББИ
    const _PlaceholderScreen(title: "Турниры", icon: Icons.emoji_events), // 3: Турниры
    const _PlaceholderScreen(title: "Друзья", icon: Icons.people),        // 4: Друзья
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Глобальный фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C), Color(0xFF0A0A0A)],
              ),
            ),
          ),

          // Декор
          Positioned(top: -100, right: -50, child: _GlowOrb(color: colorScheme.primary.withOpacity(0.15))),
          Positioned(bottom: 100, left: -50, child: _GlowOrb(color: Colors.blueAccent.withOpacity(0.1))),

          // БЕСКОНЕЧНЫЙ PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            // itemCount не задаем, чтобы он был "бесконечным" (на самом деле очень большим int)
            itemBuilder: (context, index) {
              // Берем индекс по модулю длины списка
              final int realIndex = index % _pages.length;
              return _pages[realIndex];
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomBar(colorScheme),
    );
  }

  Widget _buildGlassBottomBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black.withOpacity(0.75),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: Icons.person_outline,
                label: "Профиль",
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavBarItem(
                icon: Icons.storefront,
                label: "Магазин",
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _CenterActionButton(
                onTap: () => _onTabTapped(2),
                isSelected: _currentIndex == 2,
              ),
              _NavBarItem(
                icon: Icons.emoji_events_outlined,
                label: "Турниры",
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
              _NavBarItem(
                icon: Icons.people_outline,
                label: "Друзья",
                isSelected: _currentIndex == 4,
                onTap: () => _onTabTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Компоненты UI (Без изменений) ---

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.4);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            if (!isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const _CenterActionButton({required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -22),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFA88620)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.black, size: 32),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  const _GlowOrb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

// --- Заглушки ---

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: const Color(0xFFD4AF37).withOpacity(0.2)),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Раздел в разработке", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 20)
                      ]
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2C2C2C),
                    child: Icon(Icons.person, size: 60, color: Color(0xFFD4AF37)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 20, color: Colors.black),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text("Игрок", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text("Новичок", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 40),

            _buildSettingsItem(Icons.settings, "Настройки игры"),
            _buildSettingsItem(Icons.language, "Язык"),
            _buildSettingsItem(Icons.help_outline, "Помощь"),
            const Divider(color: Colors.white10, height: 30),
            _buildSettingsItem(Icons.logout, "Выйти", isDestructive: true, onTap: () => _logout(context)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white),
      ),
      title: Text(title, style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w500
      )),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
