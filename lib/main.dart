import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, isHovered, isDragging) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isDragging ? 0 : (isHovered ? 64 : 48),
                width: isDragging ? 0 : (isHovered ? 64 : 48),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(
                  child: Icon(
                    e,
                    color: Colors.white,
                    size: isHovered ? 32 : 24,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T, bool isHovered, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  int? draggingIndex;
  int? hoveringIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          bool isDragging = draggingIndex == index;
          bool isHovered = hoveringIndex == index;

          return DragTarget<int>(
            builder: (context, candidateData, rejectedData) {
              return Draggable<int>(
                data: index,
                feedback: Material(
                  type: MaterialType.transparency,
                  child: widget.builder(item, true, false),
                ),
                childWhenDragging: const SizedBox.shrink(),
                onDragStarted: () {
                  setState(() {
                    draggingIndex = index;
                  });
                },
                onDragCompleted: () {
                  setState(() {
                    draggingIndex = null;
                    hoveringIndex = null;
                  });
                },
                onDraggableCanceled: (_, __) {
                  setState(() {
                    draggingIndex = null;
                    hoveringIndex = null;
                  });
                },
                child: widget.builder(item, isHovered, isDragging),
              );
            },
            onWillAccept: (draggedIndex) {
              setState(() {
                hoveringIndex = index;
              });
              return true;
            },
            onLeave: (_) {
              setState(() {
                hoveringIndex = null;
              });
            },
            onAccept: (draggedIndex) {
              setState(() {
                final draggedItem = _items[draggedIndex];
                _items.removeAt(draggedIndex);
                _items.insert(index, draggedItem);
                draggingIndex = null;
                hoveringIndex = null;
              });
            },
          );
        }),
      ),
    );
  }
}
