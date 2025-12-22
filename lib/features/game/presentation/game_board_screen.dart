import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameBoardScreen extends StatelessWidget {
  const GameBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Темный фон стола
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Матч #4203", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          // Панель соперника
          const _PlayerPanel(name: "Соперник", score: 0, isTop: true),

          // Игровая доска (занимает все свободное место)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1B10), // Цвет дерева (темный орех)
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5D4037), width: 8),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CustomPaint(
                    painter: BackgammonBoardPainter(),
                    child: const Stack(
                      children: [
                        // Сюда в будущем добавим шашки через Positioned или LayoutBuilder
                        Center(child: Text("БАР", style: TextStyle(color: Colors.white12, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Панель игрока
          const _PlayerPanel(name: "Вы", score: 0, isTop: false),
        ],
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final String name;
  final int score;
  final bool isTop;

  const _PlayerPanel({required this.name, required this.score, required this.isTop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isTop ? Colors.redAccent : Colors.blueAccent,
                child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          // Зары (Dice) - заглушка
          if (!isTop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: const Text("Бросить", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

// Рисует треугольники (пункты)
class BackgammonBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF8D6E63); // Темный треугольник
    final paintLight = Paint()..color = const Color(0xFFD7CCC8); // Светлый треугольник
    final barPaint = Paint()..color = const Color(0xFF1B100A); // Бар посередине

    final double width = size.width;
    final double height = size.height;
    final double midX = width / 2;
    final double triangleWidth = (width - 40) / 12; // 12 пунктов по ширине (минус бар)
    final double triangleHeight = height * 0.4;
    final double barWidth = 20.0;

    // Рисуем Бар
    canvas.drawRect(Rect.fromLTWH(midX - barWidth / 2, 0, barWidth, height), barPaint);

    // Функция рисования ряда треугольников
    void drawTriangles(bool isTop) {
      for (int i = 0; i < 6; i++) {
        // Левая половина
        double leftX = i * triangleWidth;
        // Правая половина (с учетом бара)
        double rightX = midX + barWidth / 2 + i * triangleWidth;

        Paint currentPaint = (i % 2 == (isTop ? 0 : 1)) ? paintDark : paintLight;

        // Рисуем слева
        Path pathLeft = Path();
        if (isTop) {
          pathLeft.moveTo(leftX, 0);
          pathLeft.lineTo(leftX + triangleWidth / 2, triangleHeight);
          pathLeft.lineTo(leftX + triangleWidth, 0);
        } else {
          pathLeft.moveTo(leftX, height);
          pathLeft.lineTo(leftX + triangleWidth / 2, height - triangleHeight);
          pathLeft.lineTo(leftX + triangleWidth, height);
        }
        canvas.drawPath(pathLeft, currentPaint);

        // Рисуем справа
        Paint currentPaintRight = (i % 2 == (isTop ? 0 : 1)) ? paintDark : paintLight;
        Path pathRight = Path();
        if (isTop) {
          pathRight.moveTo(rightX, 0);
          pathRight.lineTo(rightX + triangleWidth / 2, triangleHeight);
          pathRight.lineTo(rightX + triangleWidth, 0);
        } else {
          pathRight.moveTo(rightX, height);
          pathRight.lineTo(rightX + triangleWidth / 2, height - triangleHeight);
          pathRight.lineTo(rightX + triangleWidth, height);
        }
        canvas.drawPath(pathRight, currentPaintRight);
      }
    }

    drawTriangles(true);  // Верхние
    drawTriangles(false); // Нижние
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
