# Copy Asset

A Flutter package that copies assets from a config directory to destinations specified in pubspec.yaml.

## Features

- Copy assets from a source config directory to destinations defined in pubspec.yaml
- Automatically creates destination directories if they don't exist
- Provides detailed logging of copy operations
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

## How it works

1. The package reads your `pubspec.yaml` file to find assets listed under `flutter.assets`
2. For each asset, it looks for a file with the same name in the specified config directory
3. If found, it copies the file from the config directory to the asset destination
4. Creates destination directories automatically if they don't exist

## Example

Given this `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/logo.png
    - assets/data/config.json
```

And a config directory structure:
```
config/
  ├── logo.png
  └── config.json
```

Running `AssetCopy.copyAssetsFromConfig()` will:
- Copy `config/logo.png` to `assets/images/logo.png`
- Copy `config/config.json` to `assets/data/config.json`

## API Reference

### AssetCopy.copyAssets()

```dart
static Future<void> copyAssets({
  required String configPath,
  String? pubspecPath,
})
```

- `configPath`: Path to the directory containing source assets
- `pubspecPath`: Path to pubspec.yaml file (defaults to 'pubspec.yaml')

### AssetCopy.copyAssetsFromConfig()

```dart
static Future<void> copyAssetsFromConfig({
  String configPath = 'config',
})
```

- `configPath`: Path to the config directory (defaults to 'config')

## License

This project is licensed under the MIT License.