import 'dart:io';
import 'dart:ui' as ui;

Future<ui.Image> loadUiImageFromFile(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}
