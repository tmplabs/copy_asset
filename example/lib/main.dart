/// Example Flutter application demonstrating the usage of the asset_copy package.
/// 
/// This app provides a simple UI to test the asset copying functionality,
/// allowing users to copy assets from a config directory to their designated
/// locations as specified in pubspec.yaml.

import 'package:flutter/material.dart';
import 'package:copy_asset/copy_asset.dart';

/// Entry point of the Flutter application.
/// 
/// Initializes and runs the main app widget [MyApp].
void main() {
  runApp(const MyApp());
}

/// Root widget of the application.
/// 
/// This is a stateless widget that sets up the MaterialApp with basic
/// configuration including theme, title, and the home page widget.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  /// 
  /// The [key] parameter is optional and is passed to the super constructor
  /// for widget identification purposes.
  const MyApp({Key? key}) : super(key: key);

  /// Builds the widget tree for the application.
  /// 
  /// Returns a [MaterialApp] with:
  /// - Application title: 'Asset Copy Example'
  /// - Blue primary theme color
  /// - [MyHomePage] as the home widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Copy Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Asset Copy Example'),
    );
  }
}

/// Main page widget that demonstrates asset copying functionality.
/// 
/// This stateful widget provides a user interface with a button to trigger
/// asset copying operations and displays the current status of the operation.
class MyHomePage extends StatefulWidget {
  /// Creates a [MyHomePage] widget.
  /// 
  /// Parameters:
  /// - [key]: Optional widget key for identification
  /// - [title]: Required title to be displayed in the app bar
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  /// The title text displayed in the app bar.
  final String title;

  /// Creates the mutable state for this widget.
  /// 
  /// Returns an instance of [_MyHomePageState] that manages the widget's
  /// state and handles user interactions.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Private state class for [MyHomePage].
/// 
/// This class manages the state of the home page, including the current
/// status of asset copying operations and handling user interactions.
class _MyHomePageState extends State<MyHomePage> {
  /// Current status message displayed to the user.
  /// 
  /// This string is updated throughout the asset transformation process to inform
  /// the user about the current state of the operation.
  String _status = 'Ready to transform assets';

  /// Initiates the asset transformation and copying process.
  /// 
  /// This async method:
  /// 1. Updates the UI to show "Transforming assets..." status
  /// 2. Calls the AssetCopy.copyAssetsFromConfig method which now handles transformations
  /// 3. Updates the UI with success or error message based on the result
  /// 
  /// The method handles exceptions and displays appropriate error messages
  /// to the user if the transformation process fails.
  Future<void> _copyAssets() async {
    // Update UI to show transformation is in progress
    setState(() {
      _status = 'Transforming assets...';
    });

    try {
      // Attempt to transform and copy assets from the config directory
      // This will now process assets according to their transformer configurations
      await AssetCopy.copyAssetsFromConfig(
        configPath: 'config',
      );
      
      // Update UI with success message
      setState(() {
        _status = 'Asset transformation completed!\n'
            'Check the console for details.\n'
            'Generated files:\n'
            '• app_icon.png variants (3x)\n'
            '• AndroidManifest.xml (from config.json)\n'
            '• icon_small.png, icon_medium.png';
      });
    } catch (e) {
      // Handle errors and display error message to user
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  /// Builds the UI for the home page.
  /// 
  /// Creates a scaffold with:
  /// - App bar displaying the widget title
  /// - Centered column layout containing:
  ///   - Title text for the example app
  ///   - Current status display
  ///   - Button to trigger asset copying
  /// 
  /// Returns a [Scaffold] widget with the complete page layout.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with the page title
      appBar: AppBar(
        title: Text(widget.title),
      ),
      
      // Main body with centered content
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Main title of the example app
            const Text(
              'Asset Copy Package Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            // Spacing between elements
            const SizedBox(height: 20),
            
            // Status text that updates based on operation state
            Text(
              _status,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            
            // More spacing before the button
            const SizedBox(height: 40),
            
            // Button to trigger asset transformation operation
            ElevatedButton(
              onPressed: _copyAssets,
              child: const Text('Transform Assets with Config'),
            ),
          ],
        ),
      ),
    );
  }
}