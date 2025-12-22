import 'package:flutter/material.dart';

class PresentationScreen extends StatelessWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Это крутая презентация!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Переход на AuthSelectionScreen с заменой текущего экрана
                // (чтобы нельзя было вернуться назад на презентацию)
                Navigator.pushReplacementNamed(context, '/auth_selection');
              },
              child: const Text('Начать'),
            ),
          ],
        ),
      ),
    );
  }
}
