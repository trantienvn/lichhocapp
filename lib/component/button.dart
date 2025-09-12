import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;

  const GlassmorphismButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.blur = 10,
    this.opacity = 0.3,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}