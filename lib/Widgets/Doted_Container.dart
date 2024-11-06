import 'package:flutter/material.dart';

class DottedBorderContainer extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final Color borderColor;
  final double strokeWidth;

  const DottedBorderContainer({super.key, 
    required this.height,
    required this.width,
    required this.child,
    required this.borderColor,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DottedBorderPainter(color: borderColor, strokeWidth: strokeWidth),
      child: SizedBox(
        height: height,
        width: width,
        child: child,
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5.0;
    const double dashSpace = 3.0;
    double startX = 0;
    double startY = 0;

    // Draw top border
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    startY = size.height;

    // Draw bottom border
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, startY), Offset(startX + dashWidth, startY), paint);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    startY = 0;

    // Draw left border
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    startY = 0;
    startX = size.width;

    // Draw right border
    while (startY < size.height) {
      canvas.drawLine(Offset(startX, startY), Offset(startX, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}