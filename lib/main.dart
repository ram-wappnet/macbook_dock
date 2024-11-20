import 'package:flutter/material.dart';

import 'widgets/dock.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application that sets up the material app and theme.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const DockDemo(),
    );
  }
}

/// A demo screen that showcases the dock widget with example items.
class DockDemo extends StatelessWidget {
  /// Creates the dock demo screen.
  const DockDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Dock(
          items: const [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
          ],
          builder: (icon) {
            return Container(
              constraints: const BoxConstraints(minWidth: 48),
              height: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color:
                    Colors.primaries[icon.hashCode % Colors.primaries.length],
              ),
              child: Center(child: Icon(icon, color: Colors.white)),
            );
          },
        ),
      ),
    );
  }
}
