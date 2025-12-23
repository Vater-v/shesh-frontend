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

  // Данные для экранов (картинки убраны)
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "Добро пожаловать",
      description: "Это стартовый шаблон клиентского приложения.",
      imagePath: "", // Пустая строка - покажется заглушка-иконка
    ),
    OnboardingItem(
      title: "Чистый интерфейс",
      description: "Ничего лишнего. Готовая база для разработки вашего функционала.",
      imagePath: "",
    ),
    OnboardingItem(
      title: "Поехали",
      description: "Авторизуйтесь, чтобы начать работу с клиентом.",
      imagePath: "",
    ),
  ];

  Future<void> _completeOnboarding() async {
    await _storageService.setOnboardingSeen();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
              foregroundColor: Colors.black,
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
