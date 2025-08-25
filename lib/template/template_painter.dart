import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../flyer.dart';

class PosterPainter extends CustomPainter {
  final TemplatePage page;
  final ui.Image background;
  final Map<String, ui.Image> stickerImages;

  PosterPainter({
    required this.page,
    required this.background,
    required this.stickerImages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final src = Rect.fromLTWH(0, 0, background.width.toDouble(), background.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(background, src, dst, paint);

    for (final sticker in page.stickers ?? <Sticker>[]) {
      final rot = (sticker.rotation ?? 0.0);
      final sx = (sticker.scaleX ?? 1.0);
      final sy = (sticker.scaleY ?? 1.0);
      final w  = (sticker.width  ?? 0) * sx;
      final h  = (sticker.height ?? 0) * sy;
      final left = (sticker.posX ?? 0);
      final top  = (sticker.posY ?? 0);

      final cx = left + w / 2;
      final cy = top  + h / 2;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      canvas.translate(-w / 2, -h / 2);

      if (sticker.stickerType == "IMAGE") {
        final path = sticker.imageSticker?.path ?? '';
        final uiImage = stickerImages[path];
        if (uiImage != null) {
          final imgSrc = Rect.fromLTWH(0, 0, uiImage.width.toDouble(), uiImage.height.toDouble());
          final imgDst = Rect.fromLTWH(0, 0, w, h);
          canvas.drawImageRect(uiImage, imgSrc, imgDst, paint);
        }
      } else if (sticker.stickerType == "TEXT") {
        _drawText(canvas, w, h, sticker);
      }

      canvas.restore();
    }
  }

  void _drawText(Canvas canvas, double w, double h, Sticker sticker) {
    final ts = sticker.textSticker!;
    final family = (ts.font).split('.').first;
    final color  = ts.textColor.toColor;
    final fs     = (ts.fontSize ?? 14).toDouble();
    final weight = (ts.isBold ?? false) ? FontWeight.w700 : FontWeight.w400;
    final italic = (ts.isItalic ?? false) ? FontStyle.italic : FontStyle.normal;
    final align  = ts.textAlignHorizontally ?? TextAlign.center;
    final height = ts.lineHeight ?? 1.2;
    final letter = ts.letterSpacing ?? 0.0;

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontFamily: family,
      fontSize: fs,
      fontWeight: weight,
      fontStyle: italic,
      textAlign: align,
      height: height,
      maxLines: null,
    ))
      ..pushStyle(ui.TextStyle(
        color: color,
        letterSpacing: letter,
      ))
      ..addText(ts.text);

    final paragraph = pb.build();
    paragraph.layout(ui.ParagraphConstraints(width: w));

    double dy = 0;
    final valign = ts.textAlignVertically ?? Alignment.center;
    if (valign == Alignment.topCenter) {
      dy = 0;
    } else if (valign == Alignment.center) {
      dy = (h - paragraph.height) / 2;
    } else if (valign == Alignment.bottomCenter) {
      dy = (h - paragraph.height);
    } else {
      dy = (h - paragraph.height) / 2;
    }

    canvas.drawParagraph(paragraph, Offset(0, dy));
  }

  @override
  bool shouldRepaint(covariant PosterPainter oldDelegate) {
    return oldDelegate.page != page ||
        oldDelegate.background != background ||
        oldDelegate.stickerImages.length != stickerImages.length;
  }
}
