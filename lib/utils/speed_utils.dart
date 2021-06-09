class SpeedUtils {
  static double getIntVal(double rawSpeed) {
    return double.parse(rawSpeed.toStringAsFixed(2));
  }

  static double toMph(double speed) {
    return speed / 1.609;
  }
}
