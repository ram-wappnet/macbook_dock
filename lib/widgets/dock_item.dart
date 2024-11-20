import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A widget representing an item in a macOS-style dock that supports drag-and-drop,
/// smooth scaling animations, and reordering functionality.
class DockItem extends StatefulWidget {
  /// Creates a [DockItem] widget.
  ///
  /// [child] represents the visual content of the dock item.
  /// [index] is the item's position in the dock.
  /// [onDragStarted], [onDragUpdate], and [onDragEnd] are callbacks for handling drag events.
  /// [isDragged] indicates whether the item is being dragged.
  /// [position] specifies the current position of the item.
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

  /// The visual content of the dock item.
  final Widget child;

  /// The item's index in the dock.
  final int index;

  /// Callback invoked when the drag starts.
  final VoidCallback onDragStarted;

  /// Callback invoked when the item is being dragged.
  final Function(DragUpdateDetails) onDragUpdate;

  /// Callback invoked when the drag ends.
  final void Function(DraggableDetails) onDragEnd;

  /// Indicates whether the item is currently being dragged.
  final bool isDragged;

  /// The current position of the item in the dock.
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

    // Initializes the animation controller with a 300ms duration.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Defines the scaling animation sequence.
    _scaleAnimation = _controller.drive(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 1,
        ),
      ]),
    );

    // Listens to animation updates and resets the controller after settling.
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

  /// Starts the bounce animation using a spring simulation.
  void _startBounceAnimation() {
    _isSettling = true;

    // Defines a spring simulation with mass, stiffness, and damping.
    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 300.0,
      damping: 15.0,
    );

    // Animates the bounce-back effect.
    final simulation = SpringSimulation(spring, 1.3, 1.0, -5.0);
    _controller.animateWith(simulation);
  }

  @override
  void didUpdateWidget(DockItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Triggers the scaling animation when the dragging state changes.
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
              scale: widget.isDragged ? _scaleAnimation.value : 1.0,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
