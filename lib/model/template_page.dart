import 'package:flutter/material.dart';

import '../flyer.dart';

// class TemplatePage {
//   String? bgImage = 'assets/extra/bg.png';
//   String? bgColor = '';
//   double? posterWidth = 1000;
//   double? posterHeight = 1400;
//
//   List<Sticker>? stickers;
//
//   TemplatePage(this.bgImage, this.bgColor, this.posterWidth, this.posterHeight, this.stickers);
//
//   TemplatePage.fromJson(Map<String, dynamic> json) {
//     bgImage = json['bgImage'];
//     bgColor = json['bgColor'];
//     posterWidth = json['posterWidth'];
//     posterHeight = json['posterHeight'];
//
//     if (json['stickers'] != null) {
//       stickers = List<Sticker>.from(json['stickers'].map((x) => TextSticker.fromJson(x)));
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['bgImage'] = bgImage;
//     data['bgColor'] = bgColor;
//     data['posterWidth'] = posterWidth;
//     data['posterHeight'] = posterHeight;
//
//     if (stickers != null) {
//       data['stickers'] = stickers?.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
//
//   TemplatePage.copy(TemplatePage other) {
//     bgImage = other.bgImage;
//     bgColor = other.bgColor;
//     posterWidth = other.posterWidth;
//     posterHeight = other.posterHeight;
//     stickers = other.stickers;
//   }
// }

class TemplatePage {
  String? bgImage;
  String? bgColor;
  double? posterWidth;
  double? posterHeight;
  List<Sticker>? stickers;

  TemplatePage(this.bgImage, this.bgColor, this.posterWidth, this.posterHeight, this.stickers);

  factory TemplatePage.fromJson(Map<String, dynamic> json, double newPosterWidth, double newPosterHeight) {
    final List<Sticker> loadedStickers = [];
    double originalW = (json['posterWidth'] as num?)?.toDouble() ?? 1000;
    double originalH = (json['posterHeight'] as num?)?.toDouble() ?? 1400;
    // Parse text stickers
    if (json['text_sticker'] != null) {
      for (var t in json['text_sticker']) {
        loadedStickers.add(
          Sticker(
            uniqueId: generateRandomKey(16),
            stickerType: 'TEXT',
            iBorderVisible: false,
            posX: scaleX((t['posX'] as num?)?.toDouble() ?? 0, originalW, newPosterWidth),
            posY: scaleY((t['posY'] as num?)?.toDouble() ?? 0, originalH, newPosterHeight),
            width: scaleX((t['width'] as num?)?.toDouble() ?? 0, originalW, newPosterWidth),
            height: scaleY((t['height'] as num?)?.toDouble() ?? 0, originalH, newPosterHeight),
            rotation: (t['rotation'] as num?)?.toDouble() ?? 0,
            scaleX: 1.0,
            scaleY: 1.0,
            textSticker: TextSticker(
              text: t['textString'] ?? '',
              textColor: t['textColor'] ?? '#000000',
              font: t['fontName'] ?? '',
              textOpacity: ((t['textAlpha'] ?? 255) / 255).toDouble(),
              letterSpacing: (t['letterSpacing'] as num?)?.toDouble(),
              lineHeight: (t['lineHeight'] as num?)?.toDouble() ?? 1.2,
              isBold: (t['isBold'] == 1),
              isItalic: (t['isItalic'] == 1),
              isCapitalize: (t['isCapitalize'] == 1),
              isUnderline: false,
              textAlignHorizontally: TextAlign.center,
              textAlignVertically: Alignment.center,
            ),
          ),
        );
      }
    }

    // Parse image stickers
    if (json['image_sticker'] != null) {
      for (var i in json['image_sticker']) {
        loadedStickers.add(
          Sticker(
            uniqueId: generateRandomKey(16),
            stickerType: 'IMAGE',
            iBorderVisible: false,
            posX: scaleX((i['posX'] as num?)?.toDouble() ?? 0, originalW, newPosterWidth),
            posY: scaleY((i['posY'] as num?)?.toDouble() ?? 0, originalH, newPosterHeight),
            width: scaleX((i['width'] as num?)?.toDouble() ?? 0, originalW, newPosterWidth),
            height: scaleY((i['height'] as num?)?.toDouble() ?? 0, originalH, newPosterHeight),
            rotation: (i['rotation'] as num?)?.toDouble() ?? 0,
            scaleX: 1.0,
            scaleY: 1.0,
            imageSticker: ImageSticker(
              path: i['path'] ?? '',
              opacity: ((i['opacity'] ?? 255) / 255).toDouble(),
              tint: i['tint'],
              link: i['link'],
            ),
          ),
        );
      }
    }

    return TemplatePage(
      json['bgImage'],
      json['bgColor'],
      (json['posterWidth'] as num?)?.toDouble(),
      (json['posterHeight'] as num?)?.toDouble(),
      loadedStickers,
    );
  }
}

double scaleX(double value, double originalPosterWidth, double newPosterWidth) {
  return (value / originalPosterWidth) * newPosterWidth;
}

double scaleY(double value, double originalPosterHeight, double newPosterHeight) {
  return (value / originalPosterHeight) * newPosterHeight;
}
