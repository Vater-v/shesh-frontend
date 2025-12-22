import 'package:flutter/material.dart';

class CenterActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const CenterActionButton({super.key, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -22),
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
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.black, size: 32),
        ),
      ),
    );
  }
}
