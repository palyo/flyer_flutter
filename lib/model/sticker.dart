import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../flyer.dart';

class Sticker {
  String? uniqueId = generateRandomKey(16);
  double? posX = 100.0;
  double? posY = 100.0;
  double? scaleX = 1.0;
  double? scaleY = 1.0;
  double? width = 100.0;
  double? height = 100.0;
  double? rotation = 0.0;
  String? stickerType = '';
  bool iBorderVisible = false;
  TextSticker? textSticker;
  ImageSticker? imageSticker;

  Sticker({required this.uniqueId, required this.stickerType, required this.iBorderVisible, required this.posX, required this.posY, required this.width, required this.height, this.scaleX, this.scaleY, this.rotation, this.textSticker, this.imageSticker});

  Sticker.fromJson(Map<String, dynamic> json) {
    uniqueId = json['uniqueId'];
    stickerType = json['stickerType'];
    iBorderVisible = json['iBorderVisible'];
    posX = json['posX'];
    posY = json['posY'];
    scaleX = json['scaleX'];
    scaleY = json['scaleY'];
    width = json['width'];
    height = json['height'];
    rotation = json['rotation'];
    textSticker = json['textSticker'] != null ? TextSticker.fromJson(json['textSticker']) : null;
    imageSticker = json['imageSticker'] != null ? ImageSticker.fromJson(json['imageSticker']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uniqueId'] = uniqueId;
    data['stickerType'] = stickerType;
    data['iBorderVisible'] = iBorderVisible;
    data['posX'] = posX;
    data['posY'] = posY;
    data['scaleX'] = scaleX;
    data['scaleY'] = scaleY;
    data['width'] = width;
    data['height'] = height;
    data['rotation'] = rotation;
    data['textSticker'] = textSticker?.toJson();
    data['imageSticker'] = imageSticker?.toJson();
    return data;
  }

  Sticker.copy(Sticker other) {
    uniqueId = other.uniqueId;
    posX = other.posX;
    posY = other.posY;
    scaleX = other.scaleX;
    scaleY = other.scaleY;
    width = other.width;
    height = other.height;
    rotation = other.rotation;
    stickerType = other.stickerType;
    iBorderVisible = other.iBorderVisible;
    textSticker = other.textSticker != null ? TextSticker.copy(other.textSticker!) : null;
    imageSticker = other.imageSticker != null ? ImageSticker.copy(other.imageSticker!) : null;
  }
}

class TextSticker {
  String text = 'Hello';
  String textColor = '#FFFFFF';
  String font = '';
  double? textOpacity = 1.0;
  TextAlign? textAlignHorizontally = TextAlign.center;
  Alignment? textAlignVertically = Alignment.center;
  double? letterSpacing = 0.0;
  double? lineHeight = 1.2;
  int? bgColor = 0;
  String? link = '';
  bool? isBold = false;
  bool? isItalic = false;
  bool? isCapitalize = false;
  bool? isUnderline = false;
  TextSpan? textSpan;
  double? fontSize = 10;
  TextPainter? textPainter;

  TextSticker({required this.text, required this.textColor, required this.font, this.textOpacity, this.textAlignHorizontally, this.textAlignVertically, this.letterSpacing, this.lineHeight, this.bgColor, this.link, this.isBold, this.isItalic, this.isCapitalize, this.isUnderline});

  TextSticker.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    textColor = json['textColor'];
    font = json['font'];
    textOpacity = json['textOpacity'];
    textAlignHorizontally = json['textAlignHorizontally'];
    textAlignVertically = json['textAlignVertically'];
    lineHeight = json['lineHeight'];
    letterSpacing = json['letterSpacing'];
    bgColor = json['bgColor'];
    link = json['link'];
    isBold = json['isBold'];
    isItalic = json['isItalic'];
    isCapitalize = json['isCapitalize'];
    isUnderline = json['isUnderline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['textColor'] = textColor;
    data['font'] = font;
    data['textOpacity'] = textOpacity;
    data['textAlignHorizontally'] = textAlignHorizontally;
    data['textAlignVertically'] = textAlignVertically;
    data['lineHeight'] = lineHeight;
    data['letterSpacing'] = letterSpacing;
    data['bgColor'] = bgColor;
    data['link'] = link;
    data['isBold'] = isBold;
    data['isItalic'] = isItalic;
    data['isCapitalize'] = isCapitalize;
    data['isUnderline'] = isUnderline;
    return data;
  }

  TextSticker.copy(TextSticker other) {
    text = other.text;
    textColor = other.textColor;
    font = other.font;
    textOpacity = other.textOpacity;
    textAlignHorizontally = other.textAlignHorizontally;
    textAlignVertically = other.textAlignVertically;
    letterSpacing = other.letterSpacing;
    lineHeight = other.lineHeight;
    bgColor = other.bgColor;
    link = other.link;
    isBold = other.isBold;
    isItalic = other.isItalic;
    isCapitalize = other.isCapitalize;
    isUnderline = other.isUnderline;
  }
}

class ImageSticker {
  String path = '';
  String? mask = '';
  double? opacity = 1.0;
  int? tint = 0;
  String? link = '';

  ImageSticker({required this.path, this.mask, this.opacity, this.tint, this.link});

  ImageSticker.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    mask = json['mask'];
    opacity = json['opacity'];
    tint = json['tint'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['mask'] = mask;
    data['opacity'] = opacity;
    data['tint'] = tint;
    data['link'] = link;
    return data;
  }

  ImageSticker.copy(ImageSticker other) {
    path = other.path;
    mask = other.mask;
    opacity = other.opacity;
    tint = other.tint;
    link = other.link;
  }
}
