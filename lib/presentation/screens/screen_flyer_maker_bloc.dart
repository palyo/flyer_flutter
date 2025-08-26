import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:coderspace/coderspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flyer/presentation/theme/colors.dart';
import '../../bloc/flyer_bloc.dart';
import '../../bloc/flyer_event.dart';
import '../../bloc/flyer_state.dart';
import '../../flyer.dart';
import '../../template/template_saver.dart';
import '../widgets/draggable_sticker.dart';

class ScreenFlyerMakerBloc extends StatelessWidget {
  const ScreenFlyerMakerBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlyerBloc(),
      child: Scaffold(
        backgroundColor: colorAppBackground,
        resizeToAvoidBottomInset: false,
        appBar: CoderBar(
          title: "Flyer Maker",
          isBack: false,
          centerTitle: true,
          backgroundColor: colorAppBackground,
          textColor: colorAppText,
          actions: [
            BlocBuilder<FlyerBloc, FlyerState>(
              builder: (context, state) {
                if (state is FlyerLoaded) {
                  return IconButton(
                    icon: Icon(Icons.save_alt, color: colorAppAccent, size: 28),
                    onPressed: () async {
                      await exportPosterToGallery(
                        stickerPoints: state.stickers,
                        bgImagePath: "${state.extractedPath}/${state.templatePage.bgImage}",
                        widgetWidth: state.canvasWidth,   // actual canvas size from InitializeTemplate
                        widgetHeight: state.canvasHeight, // actual canvas size from InitializeTemplate
                        exportWidth: 1000,  // desired saved resolution
                        exportHeight: 1400,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.screenWidth * 0.05),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return BlocBuilder<FlyerBloc, FlyerState>(
                    builder: (context, state) {
                      if (state is FlyerInitial) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final aspectRatio =  (1000 / 1400);
                          final availableWidth = constraints.maxWidth;
                          final availableHeight = constraints.maxHeight;

                          double canvasWidth, canvasHeight;

                          if (availableWidth / availableHeight > aspectRatio) {
                            // Height is limiting
                            canvasHeight = availableHeight;
                            canvasWidth = canvasHeight * aspectRatio;
                          } else {
                            // Width is limiting
                            canvasWidth = availableWidth;
                            canvasHeight = canvasWidth / aspectRatio;
                          }

                          context.read<FlyerBloc>().add(
                            InitializeTemplate(
                              "https://phpstack-1170423-4093607.cloudwaysapps.com/InvitationCard/Cards/Invitation%20Cards/Wedding%20Card/13/source.zip",
                              canvasWidth,
                              canvasHeight,
                            ),
                          );
                          context.read<FlyerBloc>().add(UpdateCanvasSize(
                            width: canvasWidth,
                            height: canvasHeight,
                          ));
                        });
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is FlyerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is FlyerError) {
                        return Text("Error: ${state.message}");
                      } else if (state is FlyerLoaded) {
                        return Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {

                              return Card(
                                color: colorAppCard,
                                elevation: 1,
                                child: AspectRatio(
                                  aspectRatio: (state.templatePage.posterWidth??1000.0) / (state.templatePage.posterHeight??1400.0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () => context.read<FlyerBloc>().add(DeselectSticker()),
                                        child: Image.file(
                                          File('${state.extractedPath}/${state.templatePage.bgImage}'),
                                          fit: BoxFit.contain,
                                          width:constraints.maxWidth,
                                          height:constraints.maxHeight,
                                        ),
                                      ),
                                      ...state.stickers.values.map(
                                        (sticker) => DraggableStickerView(
                                          key: Key(sticker.uniqueId ?? ''),
                                          index: sticker.uniqueId ?? '',
                                          sticker: sticker,
                                          onEdit: (id, s) {},
                                          onDelete: (id) => context.read<FlyerBloc>().add(DeleteSticker(id)),
                                          onUpdate: (id, s) => context.read<FlyerBloc>().add(UpdateSticker(id, s!)),
                                          onSelection: (id, s) => context.read<FlyerBloc>().add(SelectSticker(id)),
                                          child: _buildStickerChild(sticker, state.extractedPath),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerChild(Sticker sticker, String extractedPath) {
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
    }
    return const SizedBox.shrink();
  }
}
