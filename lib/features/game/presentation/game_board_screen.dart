import 'package:flutter/material.dart';
import 'dart:math' as math;

// Модель пункта на доске
class BoardPoint {
  final int index;
  final int checkerCount;
  final int owner; // 1 = Вы (Белые), -1 = Соперник (Черные), 0 = Пусто

  BoardPoint(this.index, this.checkerCount, this.owner);
}

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({super.key});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  // Инициализация классической расстановки
  // Индекс 0 - правый нижний угол (дом белых), 23 - правый верхний
  List<BoardPoint> points = List.generate(24, (i) {
    if (i == 0) return BoardPoint(i, 2, -1);
    if (i == 5) return BoardPoint(i, 5, 1);
    if (i == 7) return BoardPoint(i, 3, 1);
    if (i == 11) return BoardPoint(i, 5, -1);
    if (i == 12) return BoardPoint(i, 5, 1);
    if (i == 16) return BoardPoint(i, 3, -1);
    if (i == 18) return BoardPoint(i, 5, -1);
    if (i == 23) return BoardPoint(i, 2, 1);
    return BoardPoint(i, 0, 0);
  });

  int? _selectedPointIndex;

  void _handlePointTap(int index) {
    setState(() {
      // Логика выбора: можно выбрать только свои шашки (owner == 1)
      if (_selectedPointIndex == index) {
        _selectedPointIndex = null;
      } else if (points[index].owner == 1) {
        _selectedPointIndex = index;
      }
      // TODO: Сюда добавить логику перемещения, если пункт назначения выбран валидно
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Матч #4203", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const _PlayerPanel(name: "Соперник", isTop: true),

          // --- ИГРОВОЕ ПОЛЕ ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1B10), // Темное дерево
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5D4037), width: 8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // 1. Рисуем фон (треугольники)
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: BoardBackgroundPainter(),
                        ),
                        // 2. Бар (центр)
                        Center(child: Container(width: 24, color: Colors.black26)),
                        // 3. Интерактивные пункты с шашками
                        ..._buildClickablePoints(constraints.maxWidth, constraints.maxHeight),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const _PlayerPanel(name: "Вы", isTop: false),
        ],
      ),
    );
  }

  List<Widget> _buildClickablePoints(double w, double h) {
    List<Widget> widgets = [];
    double barW = 24.0;
    double pointW = (w - barW - 20) / 12; // 20 - отступы по краям
    double pointH = h * 0.42;

    for (int i = 0; i < 24; i++) {
      bool isTop = i >= 12;
      double left;

      // Логика координат X (классическая доска нард)
      if (isTop) {
        if (i < 18) { // 12-17 (слева сверху)
          left = 10 + (i - 12) * pointW;
        } else { // 18-23 (справа сверху)
          left = 10 + barW + (i - 12) * pointW;
        }
      } else {
        if (i < 6) { // 0-5 (справа снизу)
          left = w - 10 - (i + 1) * pointW;
        } else { // 6-11 (слева снизу)
          left = w - 10 - barW - (i + 1) * pointW;
        }
      }

      widgets.add(Positioned(
        left: left,
        top: isTop ? 0 : null,
        bottom: isTop ? null : 0,
        width: pointW,
        height: pointH,
        child: GestureDetector(
          onTap: () => _handlePointTap(i),
          behavior: HitTestBehavior.opaque,
          child: Container(
            // Подсветка выбранного пункта
            decoration: BoxDecoration(
              color: _selectedPointIndex == i ? Colors.yellow.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: isTop ? Radius.zero : const Radius.circular(20),
                bottom: isTop ? const Radius.circular(20) : Radius.zero,
              ),
            ),
            alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildCheckersStack(points[i], pointW),
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildCheckersStack(BoardPoint point, double width) {
    if (point.checkerCount == 0) return const SizedBox();

    double size = width * 0.85;
    Color color = point.owner == 1 ? const Color(0xFFE0E0E0) : const Color(0xFF1E1E1E);
    Color border = point.owner == 1 ? Colors.black54 : Colors.white24;

    // Ограничиваем отрисовку 5 шашками, если больше - пишем цифру
    int visibleCount = math.min(point.checkerCount, 5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(visibleCount, (index) {
        bool isLast = index == visibleCount - 1;
        int overflow = point.checkerCount - 5;
        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: border, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 2))],
          ),
          child: (isLast && overflow > 0)
              ? Center(child: Text("+$overflow", style: TextStyle(color: point.owner == 1 ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 10)))
              : null,
        );
      }),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final String name;
  final bool isTop;
  const _PlayerPanel({required this.name, required this.isTop});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            CircleAvatar(radius: 12, backgroundColor: isTop ? Colors.redAccent : Colors.white, child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white)),
          ]),
          if (!isTop) const Icon(Icons.casino, color: Color(0xFFD4AF37), size: 20),
        ],
      ),
    );
  }
}

class BoardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF5D4037).withOpacity(0.6);
    final paintLight = Paint()..color = const Color(0xFF8D6E63).withOpacity(0.4);

    double w = size.width;
    double h = size.height;
    double barW = 24.0;
    double triW = (w - barW - 20) / 12;
    double triH = h * 0.4;

    // Рисуем треугольники
    for(int i = 0; i < 12; i++) {
      // Верхний ряд
      bool isDark = (i % 2 == 0); // Чередование цветов
      double topX = (i < 6) ? 10 + i * triW : 10 + barW + i * triW;

      Path topTri = Path()
        ..moveTo(topX, 0)
        ..lineTo(topX + triW, 0)
        ..lineTo(topX + triW / 2, triH)
        ..close();
      canvas.drawPath(topTri, isDark ? paintDark : paintLight);

      // Нижний ряд (зеркально)
      // Внизу индексы идут справа налево для визуального соответствия (для UI)
      // Но здесь просто отрисовка сетки

      double botX = (i < 6) ? 10 + i * triW : 10 + barW + i * triW;
      // Инвертируем цвет для нижнего ряда, чтобы напротив темного был светлый
      bool isBotDark = !isDark;

      Path botTri = Path()
        ..moveTo(botX, h)
        ..lineTo(botX + triW, h)
        ..lineTo(botX + triW / 2, h - triH)
        ..close();
      canvas.drawPath(botTri, isBotDark ? paintDark : paintLight);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
