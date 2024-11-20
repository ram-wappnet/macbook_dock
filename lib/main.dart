import 'package:flutter/material.dart';
import 'widgets/dock.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application that sets up the MaterialApp with theming and initial screen.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, // Enables Material Design 3 features.
        brightness:
            Brightness.light, // Sets the application theme to light mode.
      ),
      home: const DockDemo(), // The initial screen of the app.
    );
  }
}

/// A demo screen that showcases the usage of the custom Dock widget with example items.
class DockDemo extends StatelessWidget {
  /// Creates the dock demo screen.
  const DockDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Provides the main visual structure of the screen.
      body: Center(
        child: Dock(
          // Defines a list of icons to display in the dock.
          items: const [
            Icons.person, // Represents a person icon.
            Icons.message, // Represents a message icon.
            Icons.call, // Represents a call icon.
            Icons.camera, // Represents a camera icon.
            Icons.photo, // Represents a photo icon.
          ],
          builder: (icon) {
            // Builds the UI for each item in the dock.
            return Container(
              constraints: const BoxConstraints(minWidth: 48),
              height: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // Assigns a color based on the icon's hash code for variety.
                color:
                    Colors.primaries[icon.hashCode % Colors.primaries.length],
              ),
              child: Center(
                // Displays the icon at the center of the container.
                child: Icon(icon, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
