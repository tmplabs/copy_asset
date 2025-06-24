# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-06-24

### Added
- Initial release of copy_asset package
- Asset copying from config directory to destinations specified in pubspec.yaml
- Support for image transformation and resizing with multiple variants
- Custom destination path mapping
- Automatic directory creation for destination paths
- Comprehensive logging of copy operations
- Support for copy and image_resize transformer types
- Flutter example app demonstrating package usage

### Features
- `AssetCopy.copyAssetsFromConfig()` method for easy asset copying
- `AssetCopy.copyAssets()` method with custom paths
- Image resizing with suffix variants (@2x, @3x, custom suffixes)
- Configuration through pubspec.yaml flutter.assets section
- Error handling and detailed console output