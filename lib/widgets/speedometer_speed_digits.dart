import 'package:flutter/material.dart';

class SpeedometerSpeedDigits extends StatelessWidget {
  double speed;
  double speedDigitWidth;
  double speedDigitHeight;
  double speedDigitX;
  double speedDigitY;
  String theme;

  SpeedometerSpeedDigits(
      {Key? key,
      required this.speed,
      required this.speedDigitWidth,
      required this.speedDigitHeight,
      required this.speedDigitX,
      required this.speedDigitY,
      required this.theme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String roundedSpeed = (speed.toInt()).toString();
    print(roundedSpeed);
    List<Widget> widgets = [];

    for (int i = 0; i < roundedSpeed.length; i++) {
      widgets.add(Image.asset(
        "assets/tachometers/$theme/speed_yellow/speed_digits_${roundedSpeed[i]}.png",
        width: speedDigitWidth,
        height: speedDigitHeight,
      ));
    }

    return Positioned(
      child: Row(
        children: widgets,
      ),
      top: speedDigitY,
      left: speedDigitX - ((roundedSpeed.length - 1) * (speedDigitWidth)),
    );
  }
}
