import 'package:coderspace/coderspace.dart';
import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  double get stickerControlSize => screenWidth < 600
      ? 16.0
      : screenWidth >= 600 && screenWidth < 1000
      ? 18.0
      : 20.0;

  double get stickerControlPadding => screenWidth < 600
      ? 2.5
      : screenWidth >= 600 && screenWidth < 1000
      ? 4.0
      : 5.0;
}
