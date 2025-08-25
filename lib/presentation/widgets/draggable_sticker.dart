import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flyer/extensions/size.dart';

import '../../flyer.dart';

class DraggableStickerView extends StatefulWidget {
  final Widget child;
  final String index;
  final Function(String) onDelete;
  final Function(String, Sticker?) onUpdate;
  final Function(String, Sticker?) onSelection;
  final Function(String, Sticker?) onEdit;
  final Sticker? sticker;

  const DraggableStickerView({
    super.key,
    required this.child,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
    required this.onSelection,
    required this.onEdit,
    this.sticker,
  });

  @override
  State<DraggableStickerView> createState() => _DraggableStickerViewState();
}

class _DraggableStickerViewState extends State<DraggableStickerView> {
  Sticker? sticker;
  bool _isScaling = false;

  Offset _rotationStartOffset = Offset.zero;
  double _rotationStartAngle = 0.0;
  double _initialRotation = 0.0;

  Offset? _scaleStartPosition;
  double _startScaleX = 1.0;
  double _startScaleY = 1.0;

  @override
  void initState() {
    super.initState();
    sticker = widget.sticker;
  }

  final GlobalKey _stickerKey = GlobalKey();

  double _calculateAngle(Offset center, Offset touchPoint) {
    return atan2(touchPoint.dy - center.dy, touchPoint.dx - center.dx);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (sticker?.posX ?? 0) - (context.stickerControlSize / 2),
      top: (sticker?.posY ?? 0) - (context.stickerControlSize / 2),
      child: Transform.rotate(
        angle: (sticker?.rotation ?? 0),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (widget.sticker?.iBorderVisible == false) {
                  widget.onSelection(widget.index, sticker);
                }
              },
              onDoubleTap: () {
                widget.onEdit(widget.index, sticker);
              },
              onPanStart: (details) {
                if (widget.sticker?.iBorderVisible == false) {
                  widget.onSelection(widget.index, sticker);
                }
              },
              onPanUpdate: (details) {
                if (_isScaling) return;
                final cosRotation = cos(sticker?.rotation ?? 0);
                final sinRotation = sin(sticker?.rotation ?? 0);
                final dx = details.delta.dx * cosRotation - details.delta.dy * sinRotation;
                final dy = details.delta.dx * sinRotation + details.delta.dy * cosRotation;
                setState(() {
                  sticker?.posX = (sticker?.posX ?? 0) + dx;
                  sticker?.posY = (sticker?.posY ?? 0) + dy;
                });
              },
              onPanEnd: (details) {
                widget.onUpdate(widget.index, sticker);
              },
              child: Padding(
                padding: EdgeInsets.all(context.stickerControlSize / 2),
                child: Container(
                  width: (sticker?.width ?? 0) * (sticker?.scaleX ?? 1.0),
                  height: (sticker?.height ?? 0) * (sticker?.scaleY ?? 1.0),
                  key: _stickerKey,
                  decoration: BoxDecoration(
                    border: (widget.sticker?.iBorderVisible ?? false)
                        ? Border.all(color: Colors.blue, width: 1)
                        : Border.all(color: Colors.transparent, width: 1),
                  ),
                  child: widget.child,
                ),
              ),
            ),
            if (widget.sticker?.iBorderVisible ?? false) ...[
              // Delete button
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => widget.onDelete(sticker?.uniqueId ?? ""),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    padding: EdgeInsets.all(context.stickerControlPadding),
                    child: Icon(Icons.delete, color: Colors.red, size: context.stickerControlSize),
                  ),
                ),
              ),

              // Scale button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _isScaling = true;
                    });

                    _scaleStartPosition = details.globalPosition;
                    _startScaleX = sticker?.scaleX ?? 1.0;
                    _startScaleY = sticker?.scaleY ?? 1.0;
                  },
                  onPanUpdate: (details) {
                    if (!_isScaling || _scaleStartPosition == null) return;

                    final dx = details.globalPosition.dx - _scaleStartPosition!.dx;
                    final dy = details.globalPosition.dy - _scaleStartPosition!.dy;

                    // Rotate delta into the sticker's local coordinates
                    final rotation = sticker?.rotation ?? 0;
                    final cosR = cos(-rotation);
                    final sinR = sin(-rotation);

                    final localDx = dx * cosR - dy * sinR;
                    final localDy = dx * sinR + dy * cosR;

                    // Apply scaling based on local coordinates
                    final scaleXChange = localDx / 100;
                    final scaleYChange = localDy / 100;

                    setState(() {
                      sticker?.scaleX = (_startScaleX + scaleXChange).clamp(0.5, 7.0);
                      sticker?.scaleY = (_startScaleY + scaleYChange).clamp(0.5, 7.0);
                    });
                  },
                  onPanEnd: (details) {
                    widget.onUpdate(widget.index, sticker);
                    setState(() {
                      _isScaling = false;
                      _scaleStartPosition = null;
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    padding: EdgeInsets.all(context.stickerControlPadding),
                    child: Icon(Icons.open_in_full, color: Colors.blue, size: context.stickerControlSize),
                  ),
                ),
              ),

              // Rotate button
              Positioned(
                top: 0,
                left: 0,
                child: GestureDetector(
                  onPanStart: (details) {
                    final renderBox = _stickerKey.currentContext?.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final center = renderBox.localToGlobal(Offset(renderBox.size.width / 2, renderBox.size.height / 2));
                    _rotationStartOffset = details.globalPosition;
                    _rotationStartAngle = _calculateAngle(center, _rotationStartOffset);
                    _initialRotation = sticker?.rotation ?? 0;
                  },
                  onPanUpdate: (details) {
                    final renderBox = _stickerKey.currentContext?.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final center = renderBox.localToGlobal(Offset(renderBox.size.width / 2, renderBox.size.height / 2));
                    final currentAngle = _calculateAngle(center, details.globalPosition);
                    setState(() {
                      sticker?.rotation = _initialRotation + (currentAngle - _rotationStartAngle);
                    });
                    widget.onUpdate(widget.index, sticker);
                  },
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    padding: EdgeInsets.all(context.stickerControlPadding),
                    child: Icon(Icons.rotate_right, color: Colors.blue, size: context.stickerControlSize),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
