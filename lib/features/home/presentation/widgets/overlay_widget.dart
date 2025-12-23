import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MyOverlayWidget extends StatefulWidget {
  const MyOverlayWidget({super.key});

  @override
  State<MyOverlayWidget> createState() => _MyOverlayWidgetState();
}

class _MyOverlayWidgetState extends State<MyOverlayWidget> {
  Color _borderColor = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1E1E).withOpacity(0.95),
            border: Border.all(color: _borderColor, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 12, spreadRadius: 2)
            ],
          ),
          child: Stack(
            children: [
              // Иконка по центру (например, логотип или действие)
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Пример интерактива: меняем цвет рамки при тапе
                    setState(() {
                      _borderColor = _borderColor == const Color(0xFFD4AF37)
                          ? Colors.green
                          : const Color(0xFFD4AF37);
                    });
                    // Тут можно добавить логику отправки сообщений в основное приложение
                  },
                  child: const Icon(Icons.token, color: Color(0xFFD4AF37), size: 36),
                ),
              ),

              // Кнопка закрытия (маленький крестик сверху справа)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    await FlutterOverlayWindow.closeOverlay();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
