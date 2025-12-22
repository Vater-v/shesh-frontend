import 'package:flutter/material.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/models/onboarding_item.dart';
import '../widgets/onboarding_content.dart';
import '../../../home/presentation/home_screen.dart'; // Импорт вашего Home Screen

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
    // Переход на главный экран с удалением истории (чтобы нельзя было вернуться "назад")
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Кнопка "Далее" или "Начать"
          ElevatedButton(
            onPressed: () {
              if (_currentPage == _items.length - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _currentPage == _items.length - 1 ? "Начать" : "Далее",
            ),
          ),
        ],
      ),
    );
  }
}
