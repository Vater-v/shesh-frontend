import 'dart:ui';
import 'package:flutter/material.dart';

class GlowOrb extends StatelessWidget {
  final Color color;
  const GlowOrb({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
