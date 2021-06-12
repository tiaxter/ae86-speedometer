import 'dart:math';

import 'package:flutter/material.dart';

class Ae86TachometerBackground extends CustomPainter {
  int speed;

  Ae86TachometerBackground(this.speed);

  final _paint = Paint()
    ..color = Color.fromRGBO(45, 45, 45, 1)
    ..strokeWidth = 25
    // Use [PaintingStyle.fill] if you want the circle to be filled.
    ..style = PaintingStyle.stroke;

  final circlePaint = Paint()
    ..color = Color.fromRGBO(45, 45, 45, 1)
    ..style = PaintingStyle.fill;

  final boldLabelPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 20
    ..style = PaintingStyle.stroke;

  final redPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final bluePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      150 * (pi / 180),
      (20 + 180 + 180 / 6) * (pi / 180),
      false,
      _paint,
    );

    canvas.drawOval(
        Rect.fromLTWH(
            (size.width / 2) - (5 / 2),
            (size.height / 2) - 5 / 2,
            5,
            5
        ),
        circlePaint
    );


    /*canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), redPaint);

    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), redPaint);*/

    /*canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -pi,
      pi,
      false,
      redPaint,
    );

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      pi,
      -pi,
      false,
      bluePaint,
    );*/

    // region Bold Speed Labels
    for (int i = 0; i <= 8; i++) {
      double sweep = 4 * (pi / 180);
      double startAngle = (11 / 12 * pi) + ((((pi + ((pi / 12) * 2)) / 8) * i) - (sweep / 2));

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweep,
        false,
        boldLabelPaint,
      );

      double startAngleSin = sin(startAngle);
      double startAngleCos = cos(startAngle);

      double x = (size.width/2) + (startAngleCos * 115);
      double y = (size.width/2) + (startAngleSin * 115);

      drawText(
        text: ((i + 1) * 20).toString(),
        textStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'EuroStyle',
          fontSize: 25
        ),
        x: x,
        y: y,
        canvas: canvas
      );
    }
    // endregion

    // region  Semi-bold speed notches
    drawSpeedometerNotches(
        notchSweep: 2,
        notchesCount: 16,
        canvas: canvas,
        size: size
    );

    // endregion

    // region Thin speed notches
    drawSpeedometerNotches(
        notchSweep: 1,
        notchesCount: 32,
        canvas: canvas,
        size: size
    );
    // endregion

    // region Speed unit text
    drawText(
        text: 'km/h',
        textStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'EuroStyle',
          fontSize: 20
        ),
        x: size.width * 7/8,
        y: size.height * 5/6,
        canvas: canvas
    );
    // endregion

    // region Speed text

    Size kilometersRectSize = Size(75, 20);

    canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
              size.width/2,
              size.height * 5/12
          ),
          width: kilometersRectSize.width,
          height: kilometersRectSize.height
        ),
        circlePaint
    );

    double kilometersFontSize = 20;

    drawText(
        text: speed.toString(),
        textStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'EuroStyle',
          fontSize: kilometersFontSize
        ),
        x: size.width/2,
        y: size.height * 5/12 + (kilometersFontSize/10),
        canvas: canvas
    );

    // endregion

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawSpeedometerNotches({
    required double notchSweep,
    required int notchesCount,
    required Canvas canvas,
    required Size size
  }) {
    for (int i = 0; i < notchesCount; i++) {
      double sweep = notchSweep * (pi / 180);
      double spaceBetweenNotches = (pi + (pi / 12) * 2)/notchesCount;
      double startAngle = (11 / 12 * pi) + ((spaceBetweenNotches * i) - (sweep/2));

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweep,
        false,
        boldLabelPaint,
      );
    }
  }

  void drawText({
    required String text,
      required TextStyle textStyle,
      required double x,
      required double y,
      required Canvas canvas
  }) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
    );
    final offset = Offset(x - (textPainter.width/2), y - (textPainter.height/2));
    textPainter.paint(canvas, offset);
  }
}
