# Copy Asset

A Flutter package that transforms and copies assets from a config directory to destinations specified in pubspec.yaml. This library provides utilities for managing asset files in Flutter projects by automatically copying and transforming them from a centralized configuration directory to their final destinations.

## Features

- Transform and copy assets from a source config directory to destinations defined in pubspec.yaml
- Support for multiple asset transformation types (copy, image_resize, optimize)
- Generate multiple variants of assets (e.g., different image sizes)
- Flexible asset configuration with custom destinations
- Automatically creates destination directories if they don't exist
- Provides detailed logging of transformation operations
- Simple and easy-to-use API

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  copy_asset: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:copy_asset/copy_asset.dart';

// Copy assets from 'config' directory to destinations in pubspec.yaml
await AssetCopy.copyAssetsFromConfig();

// Or specify a custom config path
await AssetCopy.copyAssetsFromConfig(configPath: 'my_config');
```

### Advanced Usage

```dart
import 'package:copy_asset/copy_asset.dart';

// Copy with custom config and pubspec paths
await AssetCopy.copyAssets(
  configPath: 'config',
  pubspecPath: 'pubspec.yaml',
);
```

### Asset Configuration

Assets can be configured in your `pubspec.yaml` file in two ways:

#### Simple Asset Configuration
```yaml
flutter:
  assets:
    - assets/images/logo.png
    - assets/data/config.json
```

#### Advanced Asset Configuration with Transformers
```yaml
flutter:
  assets:
    - path: assets/images/logo.png
      transformer:
        type: copy
    - path: assets/icons/app_icon.png
      destination: assets/icons/icon.png
      transformer:
        type: image_resize
        variants:
          - suffix: "@2x"
            width: 100
            height: 100
          - suffix: "@3x"
            width: 150
            height: 150
    - path: assets/data/large_file.json
      transformer:
        type: optimize
```

### Transformation Types

#### Copy Transformer
Simply copies files from the config directory to the destination:
```yaml
transformer:
  type: copy
```

#### Image Resize Transformer
Creates multiple variants of images with different sizes:
```yaml
transformer:
  type: image_resize
  variants:
    - suffix: "@2x"
      width: 100
      height: 100
    - suffix: "@3x"
      width: 150
      height: 150
```

#### Optimize Transformer
Optimizes files based on their type:
```yaml
transformer:
  type: optimize
```

## How it works

1. The package reads your `pubspec.yaml` file to find assets listed under `flutter.assets`
2. For each asset, it parses the configuration to determine if it's a simple path or has transformer configuration
3. Only assets with transformer configurations are processed (static assets are skipped)
4. For each asset with a transformer, it looks for the source file in the specified config directory
5. The asset is transformed according to its transformer type and configuration
6. Creates destination directories automatically if they don't exist
7. Processes variants if specified (e.g., multiple image sizes)

## Example

### Simple Asset Copying
Given this `pubspec.yaml`:

```yaml
flutter:
  assets:
    - path: assets/images/logo.png
      transformer:
        type: copy
    - path: assets/data/config.json
      transformer:
        type: optimize
```

And a config directory structure:
```
config/
  ├── logo.png
  └── config.json
```

Running `AssetCopy.copyAssetsFromConfig()` will:
- Copy `config/logo.png` to `assets/images/logo.png`
- Optimize and copy `config/config.json` to `assets/data/config.json`

### Image Variants Example
Given this `pubspec.yaml`:

```yaml
flutter:
  assets:
    - path: assets/icons/app_icon.png
      transformer:
        type: image_resize
        variants:
          - suffix: "@2x"
            width: 100
            height: 100
          - suffix: "@3x"
            width: 150
            height: 150
```

And a config directory structure:
```
config/
  └── app_icon.png
```

Running `AssetCopy.copyAssetsFromConfig()` will:
- Create `assets/icons/app_icon@2x.png` (100x100)
- Create `assets/icons/app_icon@3x.png` (150x150)

## API Reference

### AssetCopy.copyAssets()

```dart
static Future<void> copyAssets({
  required String configPath,
  String? pubspecPath,
})
```

Transforms and copies assets from a configuration directory to destinations specified in pubspec.yaml.

**Parameters:**
- `configPath`: Required path to the directory containing source assets
- `pubspecPath`: Optional path to pubspec.yaml file (defaults to 'pubspec.yaml')

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
- `type`: The type of transformation to apply (e.g., 'copy', 'image_resize', 'optimize')
- `parameters`: Additional parameters for the transformation
- `variants`: List of variants to generate (for transformations that create multiple outputs)

## Notes

- Assets without transformer configurations are skipped during processing
- The image_resize transformer currently creates placeholder copies (actual image processing requires an image processing library)
- The optimize transformer is a placeholder implementation
- All transformer types ensure destination directories are created if they don't exist

## License

This project is licensed under the MIT License.