import 'package:flutter/material.dart';

import 'dock_item.dart';

/// A macOS-style dock widget that displays a row of draggable and reorderable items
/// with smooth animations and physics-based interactions.
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  late final List<T> _items = widget.items.toList();
  int? _draggedIndex;
  double? _dragPosition;
  late double _itemWidth;
  late AnimationController _rearrangeController;
  final double _baseItemWidth = 64.0; // Base width for each item
  final double _horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _rearrangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _rearrangeController.dispose();
    super.dispose();
  }

  double get _dockWidth {
    // Calculate total width based on number of visible items
    final visibleItemCount =
        _draggedIndex != null ? _items.length - 1 : _items.length;
    return (_baseItemWidth * visibleItemCount) + (_horizontalPadding * 2);
  }

  @override
  Widget build(BuildContext context) {
    _itemWidth = _baseItemWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding:
          EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: 4),
      width: _dockWidth,
      height: 72,
      child: Stack(
        children: List.generate(_items.length, (index) {
          if (_draggedIndex == index) {
            return DockItem(
              key: ValueKey(_items[index]),
              index: index,
              position: (_dragPosition ?? 0)
                  .clamp(0, _dockWidth - _itemWidth - (_horizontalPadding * 2)),
              onDragStarted: () => setState(() => _draggedIndex = index),
              onDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(details.globalPosition);
                setState(() {
                  _dragPosition = offset.dx - _itemWidth / 2;
                  _rearrangeController.forward(from: 0);
                });
              },
              onDragEnd: (details) {
                final targetIndex = _getTargetIndex(_dragPosition ?? 0);
                setState(() {
                  if (targetIndex != _draggedIndex) {
                    final item = _items.removeAt(_draggedIndex!);
                    _items.insert(targetIndex, item);
                  }
                  _draggedIndex = null;
                  _dragPosition = null;
                });
              },
              isDragged: true,
              child: widget.builder(_items[index]),
            );
          }

          double position = _calculateItemPosition(index);

          return DockItem(
            key: ValueKey(_items[index]),
            index: index,
            position: position,
            child: widget.builder(_items[index]),
            onDragStarted: () => setState(() => _draggedIndex = index),
            onDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              final offset = box.globalToLocal(details.globalPosition);
              setState(() {
                _dragPosition = offset.dx - _itemWidth / 2;
                _rearrangeController.forward(from: 0);
              });
            },
            onDragEnd: (details) {
              final targetIndex = _getTargetIndex(_dragPosition ?? 0);
              setState(() {
                if (_draggedIndex != null && targetIndex != _draggedIndex) {
                  final item = _items.removeAt(_draggedIndex!);
                  _items.insert(targetIndex, item);
                }
                _draggedIndex = null;
                _dragPosition = null;
              });
            },
            isDragged: false,
          );
        }),
      ),
    );
  }

  double _calculateItemPosition(int index) {
    if (_draggedIndex == null) {
      return index * _itemWidth;
    }

    double position;
    if (index < _draggedIndex!) {
      position = index * _itemWidth;
    } else {
      position = (index - 1) * _itemWidth;
    }

    if (_dragPosition != null) {
      final dragCenter = _dragPosition! + _itemWidth / 2;
      final currentCenter = position + _itemWidth / 2;

      if (dragCenter < currentCenter && index > _draggedIndex!) {
        position = (index - 1) * _itemWidth;
      } else if (dragCenter > currentCenter && index < _draggedIndex!) {
        position = index * _itemWidth;
      }
    }

    return position;
  }

  int _getTargetIndex(double dx) {
    int index = (dx / _itemWidth).round();
    return index.clamp(0, _items.length - 1);
  }
}
