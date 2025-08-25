import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:coderspace/coderspace.dart';
import 'package:flutter/material.dart';
import 'package:flyer/presentation/theme/colors.dart';
import 'package:flyer/utils/font_loader.dart';
import 'package:path_provider/path_provider.dart';
import '../../flyer.dart';
import '../../template/downloader.dart';
import '../../template/template_saver.dart';
import '../widgets/draggable_sticker.dart';

class ScreenFlyerMaker extends StatefulWidget {
  const ScreenFlyerMaker({super.key});

  @override
  State<ScreenFlyerMaker> createState() => _ScreenFlyerMakerState();
}

class _ScreenFlyerMakerState extends State<ScreenFlyerMaker> {
  final Map<String, Sticker> stickerPoints = {};
  String _selectedStickerId = '';
  String _previousSelectedStickerId = '';
  double? _imageWidth, _imageHeight;
  bool _isTemplateInit = false;
  TemplatePage? _templatePage;
  final GlobalKey _flyerKey = GlobalKey();
  String? extractedPath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initTemplate() async {
    if (_isTemplateInit) return;

    final url = "https://phpstack-1170423-4093607.cloudwaysapps.com/InvitationCard/Cards/Invitation%20Cards/Wedding%20Card/13/source.zip";

    // Local path where we’ll store extracted templates
    final appDir = await getApplicationDocumentsDirectory();
    final categoryPath = extractCategoryFromUrl(url);
    final downloadDir = Directory("${appDir.path}/$categoryPath");

    // If already extracted, just use it
    if (await downloadDir.exists()) {
      extractedPath = downloadDir.path;
      print("Using cached template at $extractedPath");
    } else {
      // Else download + unzip
      extractCategoryFromUrl(url);
      extractedPath = await downloadAndUnzipInvitation(url, categoryPath);
      print("Extracted to: $extractedPath");
    }

    // Now load the template JSON
    final templateJsonFile = File("$extractedPath/index.json");
    if (!await templateJsonFile.exists()) {
      throw Exception("Template JSON not found at $extractedPath/index.json");
    }

    final jsonString = await templateJsonFile.readAsString();
    final jsonData = jsonDecode(jsonString);

    // Parse template
    final template = TemplateData.fromJson(jsonData, _imageWidth ?? 1, _imageHeight ?? 1);

    _templatePage = template.pages?.first;

    // Register stickers
    for (var sticker in _templatePage?.stickers ?? []) {
      stickerPoints[sticker.uniqueId ?? generateRandomKey(16)] = sticker;
    }

    // Load fonts
    await ensureStickerFontsLoaded(_templatePage?.stickers ?? []);

    _isTemplateInit = true;
  }

  Future<void> ensureStickerFontsLoaded(List<Sticker> stickers) async {
    for (var sticker in stickers) {
      if (sticker.stickerType == "TEXT" && sticker.textSticker?.font != null) {
        final fontFile = sticker.textSticker!.font;
        final family = fontFile.split(".").first;
        final path = "$extractedPath/$fontFile";

        await FontsLoader.loadFontFromFile(path, family);
      }
    }
  }

  void _deselectSticker() {
    if (_selectedStickerId.isNotEmpty) {
      final prevSticker = stickerPoints[_selectedStickerId];
      if (prevSticker != null) prevSticker.iBorderVisible = false;
    }
    _previousSelectedStickerId = _selectedStickerId;
    _selectedStickerId = '';
  }

  void _selectSticker(String key, Sticker sticker) {
    _previousSelectedStickerId = _selectedStickerId;
    _selectedStickerId = key;

    if (_previousSelectedStickerId.isNotEmpty) {
      final prevSticker = stickerPoints[_previousSelectedStickerId];
      if (prevSticker != null) prevSticker.iBorderVisible = false;
    }

    sticker.iBorderVisible = true;
    stickerPoints[key] = sticker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorAppBackground,
      resizeToAvoidBottomInset: false,
      appBar: CoderBar(
        title: "Flyer Maker",
        isBack: false,
        centerTitle: true,
        backgroundColor: colorAppBackground,
        textColor: colorAppText,
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt, color: colorAppAccent, size: 28),
            onPressed: () async {
              await exportPosterToGallery(
                stickerPoints: stickerPoints,
                bgImagePath: "$extractedPath/${_templatePage!.bgImage}",
                widgetWidth: _imageWidth ?? 1000,
                widgetHeight: _imageHeight ?? 1400,
                exportWidth: 1000,
                // original template width
                exportHeight: 1400, // original template height
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.screenWidth * 0.05),
          child: Center(child: _buildFlyer()),
        ),
      ),
    );
  }

  Widget _buildFlyer() {
    return RepaintBoundary(
      key: _flyerKey,
      child: Card(
        color: colorAppCard,
        elevation: 1,
        child: AspectRatio(
          aspectRatio: 1000 / 1400,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _imageWidth ??= constraints.maxWidth;
              _imageHeight ??= constraints.maxHeight;

              return FutureBuilder<void>(
                future: _initTemplate(), // load after size is known
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => setState(_deselectSticker),
                        child: Image.file(
                          File('$extractedPath/${_templatePage?.bgImage}'),
                          fit: BoxFit.contain,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        ),
                      ),
                      ...stickerPoints.values.map(
                        (sticker) => RepaintBoundary(
                          child: DraggableStickerView(
                            key: Key(sticker.uniqueId ?? ''),
                            index: sticker.uniqueId ?? '',
                            sticker: sticker,
                            onEdit: (key, sticker) {},
                            onDelete: (key) => setState(() => stickerPoints.remove(key)),
                            onUpdate: (key, sticker) => setState(() => stickerPoints[key] = sticker!),
                            onSelection: (key, sticker) {
                              if (_selectedStickerId != key) {
                                setState(() => _selectSticker(key, sticker!));
                              }
                            },
                            child: _buildStickerChild(sticker),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStickerChild(Sticker sticker) {
    if (sticker.stickerType == "IMAGE") {
      return Image.file(File('$extractedPath/${sticker.imageSticker?.path}'));
    } else if (sticker.stickerType == "TEXT") {
      return Align(
        alignment: sticker.textSticker?.textAlignVertically ?? Alignment.center,
        child: AutoSizeText(
          sticker.textSticker?.text ?? '',
          textAlign: sticker.textSticker?.textAlignHorizontally,
          style: TextStyle(
            fontSize: 1000,
            fontFamily: sticker.textSticker?.font.split(".").first,
            fontWeight: FontWeight.w900,
            color: sticker.textSticker?.textColor.toColor,
            height: sticker.textSticker?.lineHeight,
            letterSpacing: sticker.textSticker?.letterSpacing,
          ),
          minFontSize: 5,
          maxLines: 10,
          maxFontSize: 500,
          wrapWords: false,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
