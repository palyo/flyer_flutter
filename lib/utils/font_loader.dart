import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class FontsLoader {
  static Future<void> loadFontFromFile(String fontFilePath, String fontFamily) async {
    final file = File(fontFilePath);
    if (!await file.exists()) {
      throw Exception("Font file not found: $fontFilePath");
    }

    final Uint8List fontBytes = await file.readAsBytes();
    final FontLoader fontLoader = FontLoader(fontFamily);
    fontLoader.addFont(Future.value(ByteData.view(fontBytes.buffer)));
    await fontLoader.load();
  }

  static Future<void> loadFontFromAssets(String assetPath, String fontFamily) async {
    final ByteData fontData = await rootBundle.load(assetPath);
    final FontLoader fontLoader = FontLoader(fontFamily);
    fontLoader.addFont(Future.value(fontData));
    await fontLoader.load();
  }
}