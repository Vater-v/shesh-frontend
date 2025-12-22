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
      // TODO: Сюда добавить логику перемещения, если пункт уже выбран
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
      // Визуальная позиция (0..5 справа, 6..11 слева)
      // Для нижней части: 0 справа. Для верхней: 23 справа.
      int visualPos = isTop ? (i - 12) : (11 - i);
      // Корректируем порядок для нижней части, чтобы 0 был справа
      if (!isTop) visualPos = (i < 6) ? (5 - i) : (11 - i); // Сложная маппинг логика зависит от правил, упростим:

      // Простой маппинг для UI:
      // Низ (0-11): 11..6 |BAR| 5..0
      // Верх (12-23): 12..17 |BAR| 18..23

      double left;
      // Логика координат X
      if (isTop) {
        if (i < 18) { // 12-17 (слева)
          left = 10 + (i - 12) * pointW;
        } else { // 18-23 (справа)
          left = 10 + barW + (i - 12) * pointW;
        }
      } else {
        if (i < 6) { // 0-5 (справа)
          left = w - 10 - (i + 1) * pointW;
        } else { // 6-11 (слева)
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
            color: _selectedPointIndex == i ? Colors.yellow.withOpacity(0.15) : Colors.transparent,
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

    // Просто рисуем треугольники
    for(int i=0; i<12; i++) {
      // Логика отрисовки фоновых треугольников
      // ... (код аналогичен вашему BackgammonBoardPainter, только без логики шашек)
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
