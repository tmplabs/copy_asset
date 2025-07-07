# Copy Asset

A Flutter package for build-time asset management that copies and transforms assets from a config directory to destinations specified in pubspec.yaml. This library is designed for copying files to platform-specific locations (like Android/iOS directories) during the build process, separate from Flutter's bundled assets.

## Features

- Copy individual files and entire directories during build time
- Support for multiple transformation types (copy, copy_directory, optimize)
- Flexible asset configuration with custom destinations
- Build-time asset processing (not bundled with your app)
- Automatically creates destination directories if they don't exist
- Provides detailed logging of transformation operations
- Perfect for managing platform-specific files (Android manifests, Kotlin files, etc.)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  copy_asset: ^1.0.0
```

## Usage

### Typical Build Script Setup

Create a build script (e.g., `lib/utils/build_assets.dart`):

```dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:copy_asset/copy_asset.dart';

// Run with: dart run lib/utils/build_assets.dart

Future<void> main() async {
  try {
    print('Building assets...');

    // Get the absolute path to pubspec.yaml in the project root
    final pubspecPath = p.join(Directory.current.path, 'pubspec.yaml');

    // Use the build_assets section for build-time asset processing
    await AssetCopy.copyAssets(
      configPath: 'assets/data',
      pubspecPath: pubspecPath,
      useBuildAssetsSection: true, // Key parameter for build-time assets
    );

    print('Assets built successfully!');
  } catch (e) {
    print('Asset build failed: $e');
    exit(1);
  }
}
```

### Asset Configuration

Configure your assets in `pubspec.yaml` using the `build_assets` section:

```yaml
flutter:
    uses-material-design: true
    generate: true

    # Regular Flutter assets (these get bundled with your app)
    assets:
        - .env
        - assets/images/
        - assets/images/folder logo.svg
        - assets/data/

# Separate section for build-time asset transformations
# These are NOT bundled with your app, they're copied during build time
build_assets:
    # Directory copy - copies entire directory structure
    - path: assets/data/your_package
      destination: android/app/src/main/kotlin/com/your_package
      transformer:
          type: copy_directory

    # Individual file copies
    - path: assets/data/build.gradle.kts
      destination: android/app/build.gradle.kts
      transformer:
          type: copy

    - path: assets/data/AndroidManifest.xml
      destination: android/app/src/main/AndroidManifest.xml
      transformer:
          type: copy
```

### Transformation Types

#### Copy Transformer
Copies individual files from the config directory to the destination:
```yaml
transformer:
  type: copy
```

#### Copy Directory Transformer
Copies entire directories with their structure:
```yaml
transformer:
  type: copy_directory
```

#### Optimize Transformer
Optimizes files based on their type:
```yaml
transformer:
  type: optimize
```

## How it works

1. The package reads your `pubspec.yaml` file to find assets listed under `build_assets`
2. For each asset, it parses the configuration to determine the transformation type
3. Files are copied from the config directory to their specified destinations
4. Directory structures are preserved when using `copy_directory`
5. Creates destination directories automatically if they don't exist
6. Processes assets according to their transformer configuration

## Real-World Example

This configuration structure allows you to manage platform-specific files:

### Project Structure
```
your_flutter_project/
├── assets/
│   └── data/
│       ├── your_package/           # Kotlin package directory
│       │   ├── MainActivity.kt
│       │   └── Utils.kt
│       ├── build.gradle.kts      # Android build file
│       └── AndroidManifest.xml   # Android manifest
├── pubspec.yaml
└── lib/
    └── utils/
        └── build_assets.dart     # Build script
```

### Running the Build
```bash
# Run the build script
dart run lib/utils/build_assets.dart

# Or integrate into your build process
flutter create .
dart run lib/utils/build_assets.dart
flutter build apk
```

### Result
After running the build script:
- `assets/data/your_package/` → `android/app/src/main/kotlin/com/your_package/`
- `assets/data/build.gradle.kts` → `android/app/build.gradle.kts`
- `assets/data/AndroidManifest.xml` → `android/app/src/main/AndroidManifest.xml`

## API Reference

### AssetCopy.copyAssets()

```dart
static Future<void> copyAssets({
  required String configPath,
  String? pubspecPath,
  bool useBuildAssetsSection = false,
})
```

Transforms and copies assets from a configuration directory to destinations specified in pubspec.yaml.

**Parameters:**
- `configPath`: Required path to the directory containing source assets
- `pubspecPath`: Optional path to pubspec.yaml file (defaults to 'pubspec.yaml')
- `useBuildAssetsSection`: Use `build_assets` section instead of `flutter.assets`

**Throws:**
- `Exception` if pubspec.yaml is not found at the specified path
- `Exception` if the config directory doesn't exist

### AssetCopy.copyAssetsFromConfig()

```dart
static Future<void> copyAssetsFromConfig({
  String configPath = 'config',
})
```

Convenience method to copy assets from a default 'config' directory.

**Parameters:**
- `configPath`: Path to the config directory (defaults to 'config')

## Classes

### AssetEntry

Represents an asset entry with its path, destination, and optional transformer.

**Properties:**
- `path`: The source path for the asset
- `destination`: The destination path for the asset (defaults to path if not specified)
- `transformer`: Optional transformer configuration for this asset

### AssetTransformer

Represents an asset transformation configuration.

**Properties:**
- `type`: The transformation type (`copy`, `copy_directory`, `optimize`)
- `parameters`: Additional parameters for the transformation
- `variants`: List of variants to generate (for transformations that create multiple outputs)

## Use Cases

- **Android/iOS Platform Files**: Copy platform-specific files during build
- **Configuration Management**: Manage different configs for different environments
- **Build Automation**: Automate file copying as part of your build process
- **Template Management**: Maintain template files and copy them when needed

## Notes

- Build assets are processed during build time, not bundled with your Flutter app
- The `copy_directory` transformer preserves directory structure
- All transformer types ensure destination directories are created if they don't exist
- Perfect for managing platform-specific files that need to be in exact locations

## License

This project is licensed under the MIT License.