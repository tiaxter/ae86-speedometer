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
    ..strokeWidth = 15
    ..style = PaintingStyle.stroke;

  final redPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final bluePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final speedIndicatorPaint = Paint()
  ..color = Colors.lightBlueAccent
  ..strokeWidth = 2
  ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width/2, size.height/2),
          radius: 150
      ),
      150 * (pi / 180),
      (20 + 180 + 180 / 6) * (pi / 180),
      false,
      _paint,
    );

    // region Bold Speed Labels
    for (int i = 0; i <= 8; i++) {
      double sweep = 4 * (pi / 180);
      double startAngle = (11 / 12 * pi) + ((((pi + ((pi / 12) * 2)) / 8) * i) - (sweep / 2));

      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width/2, size.height/2),
            radius: 150
        ),
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

    // region Speed indicator
    Size arrowSize = Size(100, 10);
    Size rectSize = Size(110, 10);

    Path speedIndicatorPath = new Path();
    speedIndicatorPath.moveTo(0, arrowSize.height/2);
    speedIndicatorPath.lineTo(arrowSize.width, 0);
    speedIndicatorPath.lineTo(arrowSize.width, arrowSize.height);
    speedIndicatorPath.close();
    speedIndicatorPath.addRect(
        Rect.fromLTWH(
        arrowSize.width,
        0,
        rectSize.width,
        rectSize.height
      )
    );
    Rect speedIndicatorBounds = speedIndicatorPath.getBounds();

    double speedIndicatorRotationAngle = fromSpeedToAngle(speed);

    rotate(
        canvas,
        size.width/2,
        (size.height * 9/16),
        speedIndicatorRotationAngle
    );

    speedIndicatorPath = speedIndicatorPath.shift(
      Offset(
          (size.width - speedIndicatorBounds.width)/2 - (rectSize.width/2),
          (size.height * 9/16) - speedIndicatorBounds.height/2
      )
    );

    canvas.drawPath(speedIndicatorPath, speedIndicatorPaint);

    // endregion

    //
    canvas.drawOval(
        Rect.fromCircle(
            center: Offset(
                size.width/2,
                size.height * 9/16,
            ),
            radius: 20
        ),
        circlePaint
    );

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
        Rect.fromCircle(
            center: Offset(size.width/2, size.height/2),
            radius: 150
        ),
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

  // https://stackoverflow.com/a/58042892/9275679
  void rotate(Canvas canvas, double cx, double cy, double angle) {
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.translate(-cx, -cy);
  }

  double fromSpeedToAngle(speed) {
    return - pi/8;
  }
}
