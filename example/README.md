# Asset Copy Example

This Flutter example demonstrates the usage of the `asset_copy` package for copying and transforming assets.

## Features

- Asset copying from a config directory
- Image resizing with multiple variants
- Custom destination mapping
- Simple UI to test the functionality

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)

### Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### How it Works

The example app includes:

- **Static assets**: `logo.png` managed normally
- **Transformed assets**: `app_icon.png` with automatic resizing to create @2x and @3x variants
- **Custom destinations**: `config.json` copied to Android manifest location
- **Multiple transformations**: Different resize variants for the same source file

Tap the "Transform Assets with Config" button to execute the asset transformation process.

## Configuration

Asset transformations are configured in `pubspec.yaml` under the `flutter.assets` section. See the file for examples of:

- Image resizing with variants
- Custom destination paths
- Different transformer types