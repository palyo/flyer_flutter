import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../template/downloader.dart';
import '../../utils/font_loader.dart';
import '../flyer.dart';
import 'flyer_event.dart';
import 'flyer_state.dart';

class FlyerBloc extends Bloc<FlyerEvent, FlyerState> {
  FlyerBloc() : super(FlyerInitial()) {
    on<InitializeTemplate>(_onInitializeTemplate);
    on<UpdateCanvasSize>((event, emit) {
      if (state is FlyerLoaded) {
        final s = state as FlyerLoaded;
        emit(s.copyWith(
          canvasWidth: event.width,
          canvasHeight: event.height,
        ));
      }
    });
    on<SelectSticker>(_onSelectSticker);
    on<DeselectSticker>(_onDeselectSticker);
    on<UpdateSticker>(_onUpdateSticker);
    on<DeleteSticker>(_onDeleteSticker);

  }

  Future<void> _onInitializeTemplate(
      InitializeTemplate event, Emitter<FlyerState> emit) async {
    emit(FlyerLoading());
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final categoryPath = extractCategoryFromUrl(event.url);
      final downloadDir = Directory("${appDir.path}/$categoryPath");

      String extractedPath;
      if (await downloadDir.exists()) {
        extractedPath = downloadDir.path;
      } else {
        extractedPath = await downloadAndUnzipInvitation(event.url, categoryPath);
      }

      final templateJsonFile = File("$extractedPath/index.json");
      if (!await templateJsonFile.exists()) {
        throw Exception("Template JSON not found at $extractedPath/index.json");
      }

      final jsonString = await templateJsonFile.readAsString();
      final jsonData = jsonDecode(jsonString);

      // 🔑 Scale with widget size
      final template = TemplateData.fromJson(jsonData, event.widgetWidth, event.widgetHeight);
      final templatePage = template.pages!.first;

      final Map<String, Sticker> stickers = {
        for (var s in templatePage.stickers ?? [])
          (s.uniqueId ?? generateRandomKey(16)): s
      };

      // Load fonts
      for (var s in templatePage.stickers ?? []) {
        if (s.stickerType == "TEXT" && s.textSticker?.font != null) {
          final fontFile = s.textSticker!.font;
          final family = fontFile.split(".").first;
          await FontsLoader.loadFontFromFile("$extractedPath/$fontFile", family);
        }
      }

      emit(FlyerLoaded(
        stickers: stickers,
        templatePage: templatePage,
        extractedPath: extractedPath,
        canvasWidth: event.widgetWidth,   // pass actual width
        canvasHeight: event.widgetHeight, // pass actual height
      ));
    } catch (e) {
      emit(FlyerError(e.toString()));
    }
  }

  void _onSelectSticker(SelectSticker event, Emitter<FlyerState> emit) {
    if (state is FlyerLoaded) {
      final s = state as FlyerLoaded;
      emit(s.copyWith(selectedStickerId: event.stickerId));
    }
  }

  void _onDeselectSticker(DeselectSticker event, Emitter<FlyerState> emit) {
    if (state is FlyerLoaded) {
      final s = state as FlyerLoaded;
      emit(s.copyWith(selectedStickerId: null));
    }
  }

  void _onUpdateSticker(UpdateSticker event, Emitter<FlyerState> emit) {
    if (state is FlyerLoaded) {
      final s = state as FlyerLoaded;
      final newStickers = Map<String, Sticker>.from(s.stickers);
      newStickers[event.id] = event.sticker;
      emit(s.copyWith(stickers: newStickers));
    }
  }

  void _onDeleteSticker(DeleteSticker event, Emitter<FlyerState> emit) {
    if (state is FlyerLoaded) {
      final s = state as FlyerLoaded;
      final newStickers = Map<String, Sticker>.from(s.stickers);
      newStickers.remove(event.id);
      emit(s.copyWith(stickers: newStickers, selectedStickerId: null));
    }
  }
}