import 'package:flutter/material.dart';

class CenterActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const CenterActionButton({super.key, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFA88620)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            // Основная тень
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            // Внутреннее свечение (имитация объема)
            if (isSelected)
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: -5,
              ),
          ],
          // Акцентная обводка
          border: Border.all(
              color: isSelected ? Colors.white : Colors.black.withOpacity(0.2),
              width: isSelected ? 3 : 1
          ),
        ),
        child: Icon(
          isSelected ? Icons.grid_view_rounded : Icons.play_arrow_rounded, // Иконка Play более призывает к действию
          color: Colors.black,
          size: 36,
        ),
      ),
    );
  }
}
