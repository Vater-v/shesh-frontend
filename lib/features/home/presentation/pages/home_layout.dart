import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shesh/features/home/presentation/pages/lobby_view.dart';
import 'package:shesh/features/profile/presentation/pages/profile_view.dart';
import 'package:shesh/features/home/presentation/widgets/nav_bar_item.dart';
import 'package:shesh/features/home/presentation/widgets/center_action_button.dart';
import 'package:shesh/core/presentation/widgets/glow_orb.dart';
import 'package:shesh/core/presentation/widgets/placeholder_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late PageController _pageController;
  static const int _initialPageCenter = 5002;
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const ProfileView(),
    const PlaceholderScreen(title: "Магазин", icon: Icons.storefront),
    const LobbyView(),
    const PlaceholderScreen(title: "Турниры", icon: Icons.emoji_events),
    const PlaceholderScreen(title: "Друзья", icon: Icons.people),
  ];

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
    final int currentVirtualPage = _pageController.page!.round();
    final int currentRealIndex = currentVirtualPage % _pages.length;
    final int diff = index - currentRealIndex;

    _pageController.animateToPage(
      currentVirtualPage + diff,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );

    setState(() => _currentIndex = index);
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index % _pages.length);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF121212),
      // Используем Stack для наложения элементов интерфейса поверх контента
      body: Stack(
        children: [
          // --- Слой 1: Фон и Контент ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F0F), Color(0xFF1C1C1C), Color(0xFF0A0A0A)],
              ),
            ),
          ),

          Positioned(top: -100, right: -50, child: GlowOrb(color: colorScheme.primary.withOpacity(0.15))),
          Positioned(bottom: 100, left: -50, child: GlowOrb(color: Colors.blueAccent.withOpacity(0.1))),

          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final int realIndex = index % _pages.length;
              return _pages[realIndex];
            },
          ),

          // --- Слой 2: Нижняя панель (стекло) ---
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildGlassBottomBar(colorScheme),
          ),

          // --- Слой 3: Центральная кнопка (парит над панелью) ---
          Positioned(
            bottom: 45, // Высота подобрана так, чтобы кнопка нависала над панелью
            left: 0,
            right: 0,
            child: Center(
              child: CenterActionButton(
                onTap: () => _onTabTapped(2),
                isSelected: _currentIndex == 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomBar(ColorScheme colorScheme) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35), // Более округлые края
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
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Усиленный блюр
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NavBarItem(
                icon: Icons.person_outline,
                label: "Профиль",
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              NavBarItem(
                icon: Icons.storefront,
                label: "Магазин",
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),

              // Пустое пространство под центральную кнопку
              const SizedBox(width: 60),

              NavBarItem(
                icon: Icons.emoji_events_outlined,
                label: "Турниры",
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
              NavBarItem(
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
