import 'package:equatable/equatable.dart';

import '../flyer.dart';

abstract class FlyerState extends Equatable {
  const FlyerState();
  @override
  List<Object?> get props => [];
}

class FlyerInitial extends FlyerState {}
class FlyerLoading extends FlyerState {}
class FlyerError extends FlyerState {
  final String message;
  const FlyerError(this.message);
  @override
  List<Object?> get props => [message];
}

class FlyerLoaded extends FlyerState {
  final Map<String, Sticker> stickers;
  final TemplatePage templatePage;
  final String extractedPath;
  final String? selectedStickerId;
  final double canvasWidth;
  final double canvasHeight;

  const FlyerLoaded({
    required this.stickers,
    required this.templatePage,
    required this.extractedPath,
    this.selectedStickerId,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  FlyerLoaded copyWith({
    Map<String, Sticker>? stickers,
    TemplatePage? templatePage,
    String? extractedPath,
    String? selectedStickerId,
    double? canvasWidth,
    double? canvasHeight,
  }) {
    return FlyerLoaded(
      stickers: stickers ?? this.stickers,
      templatePage: templatePage ?? this.templatePage,
      extractedPath: extractedPath ?? this.extractedPath,
      selectedStickerId: selectedStickerId ?? this.selectedStickerId,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
    );
  }

  @override
  List<Object?> get props => [
    stickers,
    templatePage,
    extractedPath,
    selectedStickerId,
    canvasWidth,
    canvasHeight,
  ];
}


