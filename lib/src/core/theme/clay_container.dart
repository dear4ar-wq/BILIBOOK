import 'package:flutter/material.dart';

class ClayContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const ClayContainer({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 16.0,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Bottom right dark shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(5, 5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // Top left light shadow (for that claymorphism peak)
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(-2, -2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
          // Inner glow simulation for smooth edges
          BoxShadow(
            color: color.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }
}
