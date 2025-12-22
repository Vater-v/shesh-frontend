import 'package:flutter/material.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/models/onboarding_item.dart';
import '../widgets/onboarding_content.dart';
import '../../../welcome/presentation/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final LocalStorageService _storageService = LocalStorageService();

  // Данные для 3-х экранов
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "Добро пожаловать",
      description: "Это первый экран вашей презентации. Расскажите о главной ценности приложения.",
      imagePath: "assets/slide1.png",
    ),
    OnboardingItem(
      title: "Удобный функционал",
      description: "Второй экран. Объясните пользователю, как пользоваться основными фичами.",
      imagePath: "assets/slide2.png",
    ),
    OnboardingItem(
      title: "Начнем!",
      description: "Третий экран. Призыв к действию и переход к основному приложению.",
      imagePath: "assets/slide3.png",
    ),
  ];

  Future<void> _completeOnboarding() async {
    // Сохраняем флаг, что презентация просмотрена
    await _storageService.setOnboardingSeen();

    if (!mounted) return;

    // Переход на WelcomeScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar нужен для кнопки "Пропустить"
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Показываем кнопку "Пропустить" только если это не последний слайд
          if (_currentPage != _items.length - 1)
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                "Пропустить",
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
      // Расширяем тело за AppBar
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(item: _items[index]);
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _items.length - 1;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Индикатор страниц (точки)
          Row(
            children: List.generate(
              _items.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? primaryColor
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Кнопка "Далее" или "Начать"
          ElevatedButton(
            onPressed: () {
              if (isLastPage) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black, // Цвет текста на кнопке
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                isLastPage ? "Начать" : "Далее",
                key: ValueKey<String>(isLastPage ? "start" : "next"),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
