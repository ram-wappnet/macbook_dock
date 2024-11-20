import 'package:flutter/material.dart';
import 'dock_item.dart';

/// A macOS-style dock widget that displays a row of draggable and reorderable items
/// with smooth animations and physics-based interactions.
///
/// [T] is the type of data each dock item represents.
class Dock<T> extends StatefulWidget {
  /// Creates a dock widget with the specified list of items and a builder function.
  ///
  /// [items] is the list of items to display in the dock.
  /// [builder] is a function that builds the widget for each item.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// The list of items to be displayed in the dock.
  final List<T> items;

  /// The builder function that constructs a widget for each item.
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

  /// Base width for each dock item.
  final double _baseItemWidth = 64.0;

  /// Horizontal padding around the dock.
  final double _horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    // Initializes the animation controller for smooth rearrangements.
    _rearrangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // Disposes of the animation controller to free resources.
    _rearrangeController.dispose();
    super.dispose();
  }

  /// Calculates the total width of the dock based on the number of items.
  double get _dockWidth {
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
            // Handles the item being dragged.
            return DockItem(
              key: ValueKey(_items[index]),
              index: index,
              position: (_dragPosition ?? 0)
                  .clamp(0, _dockWidth - _itemWidth - (_horizontalPadding * 2)),
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
                  if (targetIndex != _draggedIndex) {
                    final item = _items.removeAt(_draggedIndex!);
                    _items.insert(targetIndex, item);
                  }
                  _draggedIndex = null;
                  _dragPosition = null;
                });
              },
              isDragged: true,
            );
          }

          // Handles the positioning of static items.
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

  /// Calculates the position of an item in the dock based on its index and drag status.
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

  /// Determines the target index for a dragged item based on its position.
  int _getTargetIndex(double dx) {
    int index = (dx / _itemWidth).round();
    return index.clamp(0, _items.length - 1);
  }
}
