import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

import '../flyer.dart';

/// Export the current flyer to PNG and save in gallery.
/// [stickerPoints] → live user-edited stickers (with size, pos, etc.)
/// [bgImagePath]   → background file path
/// [widgetWidth]   → actual flyer widget width (constraints.maxWidth)
/// [widgetHeight]  → actual flyer widget height (constraints.maxHeight)
/// [exportWidth]   → desired export width (e.g. 1000)
/// [exportHeight]  → desired export height (e.g. 1400)
Future<void> exportPosterToGallery({
  required Map<String, Sticker> stickerPoints,
  required String bgImagePath,
  required double widgetWidth,
  required double widgetHeight,
  double exportWidth = 1000,
  double exportHeight = 1400,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Calculate scale ratio
  final scaleX = exportWidth / widgetWidth;
  final scaleY = exportHeight / widgetHeight;
  canvas.scale(scaleX, scaleY);

  // Draw background image
  final bgFile = File(bgImagePath);
  if (bgFile.existsSync()) {
    final bgBytes = await bgFile.readAsBytes();
    final bgCodec = await ui.instantiateImageCodec(bgBytes);
    final bgFrame = await bgCodec.getNextFrame();
    canvas.drawImageRect(
      bgFrame.image,
      Rect.fromLTWH(0, 0, bgFrame.image.width.toDouble(), bgFrame.image.height.toDouble()),
      Rect.fromLTWH(0, 0, widgetWidth, widgetHeight),
      Paint(),
    );
  }

  // Draw stickers
  for (final sticker in stickerPoints.values) {
    if (sticker.stickerType == "IMAGE") {
      final file = File(sticker.imageSticker?.path != null
          ? "${bgFile.parent.path}/${sticker.imageSticker?.path}"
          : "");
      if (!file.existsSync()) continue;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      canvas.drawImageRect(
        frame.image,
        Rect.fromLTWH(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
        Rect.fromLTWH(
          sticker.posX ?? 0,
          sticker.posY ?? 0,
          sticker.width ?? frame.image.width.toDouble(),
          sticker.height ?? frame.image.height.toDouble(),
        ),
        Paint(),
      );
    } else if (sticker.stickerType == "TEXT") {
      // Use TextPainter to mimic AutoSizeText
      final tp = TextPainter(
        text: TextSpan(
          text: sticker.textSticker?.text ?? '',
          style: TextStyle(
            fontSize: 1000, // Start huge → will shrink by layout
            fontFamily: sticker.textSticker?.font.split(".").first,
            fontWeight: FontWeight.w900,
            color: sticker.textSticker?.textColor.toColor,
            height: sticker.textSticker?.lineHeight,
            letterSpacing: sticker.textSticker?.letterSpacing,
          ),
        ),
        textAlign: sticker.textSticker?.textAlignHorizontally ?? TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 10,
      );

      // Layout within sticker box to auto-scale (like AutoSizeText)
      final maxWidth = sticker.width ?? widgetWidth;
      final maxHeight = sticker.height ?? widgetHeight;

      double fontSize = 1000;
      while (fontSize > 5) {
        tp.text = TextSpan(
          text: sticker.textSticker?.text ?? '',
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: sticker.textSticker?.font.split(".").first,
            fontWeight: FontWeight.w900,
            color: sticker.textSticker?.textColor.toColor,
            height: sticker.textSticker?.lineHeight,
            letterSpacing: sticker.textSticker?.letterSpacing,
          ),
        );
        tp.layout(maxWidth: maxWidth);
        if (tp.height <= maxHeight) break;
        fontSize -= 2; // shrink step
      }

      // Paint text inside sticker box
      tp.paint(canvas, Offset(sticker.posX ?? 0, sticker.posY ?? 0));
    }
  }

  // Finish recording
  final picture = recorder.endRecording();
  final img = await picture.toImage(exportWidth.toInt(), exportHeight.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  // Save to gallery
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes);
  final result = await GallerySaver.saveImage(file.path, albumName: "Invitations");
}
