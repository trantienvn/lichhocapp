import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassDialog extends StatelessWidget {
  final Widget child;
  final double? maxWidth; // Thêm thuộc tính này

  const LiquidGlassDialog({
    Key? key,
    required this.child,
    this.maxWidth, // Thêm vào constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox( // Bọc Container bằng ConstrainedBox
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity, // Áp dụng maxWidth, nếu không có thì là vô hạn
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}