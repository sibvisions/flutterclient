import 'package:flutter/widgets.dart';

class SoAlignment {
  static Alignment defaultAlignment = Alignment.center;

  static Alignment getAlignmentFromInt(int textAlign) {
    switch (textAlign) {
      case 0:
        return Alignment.topLeft;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.topRight;
      case 3:
        return Alignment.center;
    }
    return defaultAlignment;
  }
}
