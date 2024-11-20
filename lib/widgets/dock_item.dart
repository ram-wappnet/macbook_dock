import 'package:flutter/material.dart';

/// A draggable item in the macOS-style dock that supports smooth animations and reordering.
class DockItem extends StatefulWidget {
  const DockItem({
    super.key,
    required this.child,
    required this.index,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isDragged,
    required this.position,
  });

  final Widget child;
  final int index;
  final VoidCallback onDragStarted;
  final Function(DragUpdateDetails) onDragUpdate;
  final void Function(DraggableDetails) onDragEnd;
  final bool isDragged;
  final double position;

  @override
  State<DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<DockItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isSettling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = _controller.drive(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 1,
        ),
      ]),
    );

    _controller.addListener(() {
      if (_isSettling && _controller.isCompleted) {
        _isSettling = false;
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startBounceAnimation() {
    _isSettling = true;
    /* _controller.animateWith(
      SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 500.0,
        ratio: 0.6,
      ),
    ); */
  }

  @override
  void didUpdateWidget(DockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragged != oldWidget.isDragged) {
      if (widget.isDragged) {
        _controller.forward();
      } else {
        _startBounceAnimation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      left: widget.position,
      child: Draggable<int>(
        data: widget.index,
        feedback: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: widget.child,
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: widget.onDragStarted,
        onDragUpdate: widget.onDragUpdate,
        onDragEnd: (details) {
          widget.onDragEnd(details);
          _startBounceAnimation();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
