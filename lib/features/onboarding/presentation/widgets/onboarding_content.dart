import 'package:flutter/material.dart';
import '../../domain/models/onboarding_item.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Отображаем картинку, если путь задан
          if (item.imagePath.isNotEmpty)
            Expanded(
              flex: 3,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Если картинка не найдена, показываем иконку
                  return Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.white.withOpacity(0.2),
                  );
                },
              ),
            )
          else
            const Spacer(flex: 3), // Заполнитель, если картинки нет

          const SizedBox(height: 40),

          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Явно задаем цвет для темной темы
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7), // Более мягкий цвет текста
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
