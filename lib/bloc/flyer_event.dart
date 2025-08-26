import 'package:equatable/equatable.dart';

import '../flyer.dart';

abstract class FlyerEvent extends Equatable {
  const FlyerEvent();
  @override
  List<Object?> get props => [];
}

class InitializeTemplate extends FlyerEvent {
  final String url;
  final double widgetWidth;
  final double widgetHeight;
  const InitializeTemplate(this.url, this.widgetWidth, this.widgetHeight);
}

class UpdateCanvasSize extends FlyerEvent {
  final double width;
  final double height;

  const UpdateCanvasSize({required this.width, required this.height});
}

class SelectSticker extends FlyerEvent {
  final String stickerId;
  const SelectSticker(this.stickerId);
}

class DeselectSticker extends FlyerEvent {}
class UpdateSticker extends FlyerEvent {
  final String id;
  final Sticker sticker;
  const UpdateSticker(this.id, this.sticker);
}
class DeleteSticker extends FlyerEvent {
  final String id;
  const DeleteSticker(this.id);
}

