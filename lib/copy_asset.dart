/// A Flutter package that transforms and copies assets from a config directory to destinations
/// specified in pubspec.yaml. This library provides utilities for managing
/// asset files in Flutter projects by automatically copying and transforming them from a
/// centralized configuration directory to their final destinations.
library copy_asset;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Represents an asset transformation configuration.
/// 
/// This class holds the configuration for how an asset should be transformed
/// including the transformation type and its parameters.
class AssetTransformer {
  /// The type of transformation to apply (e.g., 'image_resize', 'copy', 'optimize')
  final String type;
  
  /// Additional parameters for the transformation
  final Map<String, dynamic> parameters;
  
  /// List of variants to generate (for transformations that create multiple outputs)
  final List<Map<String, dynamic>> variants;
  
  /// Creates an [AssetTransformer] with the specified configuration.
  /// 
  /// Parameters:
  /// - [type]: The transformation type identifier
  /// - [parameters]: Optional parameters for the transformation
  /// - [variants]: Optional list of variants to generate
  AssetTransformer({
    required this.type,
    this.parameters = const {},
    this.variants = const [],
  });
  
  /// Creates an [AssetTransformer] from a YAML configuration map.
  /// 
  /// This factory method parses the transformer configuration from pubspec.yaml
  /// and creates the appropriate transformer instance.
  factory AssetTransformer.fromYaml(Map<String, dynamic> config) {
    return AssetTransformer(
      type: config['type'] as String? ?? 'copy',
      parameters: Map<String, dynamic>.from(config['parameters'] as Map? ?? {}),
      variants: List<Map<String, dynamic>>.from(
        (config['variants'] as List?)?.map((v) => Map<String, dynamic>.from(v as Map)) ?? []
      ),
    );
  }
}

/// Represents an asset entry with its path, destination, and optional transformer.
/// 
/// This class encapsulates both simple asset paths (strings) and complex
/// asset configurations with transformation parameters and custom destinations.
class AssetEntry {
  /// The destination path for the asset (where it will be placed in the Flutter project)
  final String path;
  
  /// The destination path for the asset (defaults to path if not specified)
  /// This allows assets to be placed in different locations than their source names
  final String destination;
  
  /// Optional transformer configuration for this asset
  final AssetTransformer? transformer;
  
  /// Creates an [AssetEntry] with the specified path, destination, and transformer.
  AssetEntry({
    required this.path,
    String? destination,
    this.transformer,
  }) : destination = destination ?? path;
  
  /// Creates an [AssetEntry] from a YAML asset configuration.
  /// 
  /// This factory method handles both simple string assets and complex
  /// asset configurations with transformer parameters and custom destinations.
  /// 
  /// Examples:
  /// - Simple: `"assets/images/logo.png"`
  /// - With transformer: `{path: "assets/icons/app_icon.png", transformer: {...}}`
  /// - With destination: `{path: "assets/icons/app_icon.png", destination: "assets/icons/icon.png", transformer: {...}}`
  factory AssetEntry.fromYaml(dynamic assetConfig) {
    if (assetConfig is String) {
      // Simple asset path without transformer or custom destination
      return AssetEntry(path: assetConfig);
    } else if (assetConfig is Map) {
      // Complex asset configuration with optional transformer and destination
      final config = Map<String, dynamic>.from(assetConfig);
      return AssetEntry(
        path: config['path'] as String,
        destination: config['destination'] as String?,
        transformer: config['transformer'] != null
            ? AssetTransformer.fromYaml(Map<String, dynamic>.from(config['transformer'] as Map))
            : null,
      );
    } else {
      throw ArgumentError('Invalid asset configuration: $assetConfig');
    }
  }
}

/// Main class for handling asset transformation and copying operations.
/// 
/// This class provides static methods to copy assets from a configuration
/// directory to the destinations specified in the Flutter project's pubspec.yaml
/// file. It's particularly useful for maintaining centralized asset management
/// in Flutter applications.
class AssetCopy {
  /// Transforms and copies assets from a configuration directory to destinations specified
  /// in pubspec.yaml.
  /// 
  /// This method reads the pubspec.yaml file to get the list of assets and
  /// processes them according to their transformer configurations. Assets without
  /// transformers are copied as-is, while assets with transformers are processed
  /// according to their transformation rules.
  /// 
  /// Parameters:
  /// - [configPath]: Required path to the directory containing source assets
  /// - [pubspecPath]: Optional path to pubspec.yaml file (defaults to 'pubspec.yaml')
  /// 
  /// Throws:
  /// - [Exception] if pubspec.yaml is not found at the specified path
  /// - [Exception] if the config directory doesn't exist
  /// 
  /// Example:
  /// ```dart
  /// await AssetCopy.copyAssets(
  ///   configPath: 'assets/config',
  ///   pubspecPath: 'pubspec.yaml',
  /// );
  /// ```
  static Future<void> copyAssets({
    required String configPath,
    String? pubspecPath,
  }) async {
    // Set default pubspec path if not provided
    pubspecPath ??= 'pubspec.yaml';
    
    // Verify that pubspec.yaml exists at the specified location
    final pubspecFile = File(pubspecPath);
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found at $pubspecPath');
    }

    // Read and parse the pubspec.yaml file content
    final pubspecContent = await pubspecFile.readAsString();
    final pubspecYaml = loadYaml(pubspecContent) as Map;
    
    // Extract Flutter configuration and assets list from pubspec
    final flutterConfig = pubspecYaml['flutter'] as Map?;
    final assetsConfig = flutterConfig?['assets'] as List?;
    
    // Check if any assets are defined in pubspec.yaml
    if (assetsConfig == null || assetsConfig.isEmpty) {
      print('No assets found in pubspec.yaml');
      return;
    }

    // Verify that the config directory exists
    final configDir = Directory(configPath);
    if (!configDir.existsSync()) {
      throw Exception('Config directory not found at $configPath');
    }

    // Counter to track successfully processed files
    int processedCount = 0;
    
    // Parse asset configurations and process each one
    for (final assetConfig in assetsConfig) {
      try {
        final assetEntry = AssetEntry.fromYaml(assetConfig);
        
        // Only process assets that have transformers
        if (assetEntry.transformer != null) {
          final success = await _processAssetWithTransformer(
            assetEntry,
            configPath,
          );
          if (success) processedCount++;
        } else {
          // Skip assets without transformers (they remain static)
          print('Skipping static asset: ${assetEntry.destination}');
        }
      } catch (e) {
        print('Error processing asset $assetConfig: $e');
      }
    }
    
    // Print summary of transformation operation
    print('Asset transformation completed. $processedCount assets processed.');
  }

  /// Processes a single asset with its transformer configuration.
  /// 
  /// This method handles the transformation of individual assets based on
  /// their transformer type and configuration parameters. It uses the
  /// destination path from the asset entry to determine where the processed
  /// asset should be placed.
  /// 
  /// Parameters:
  /// - [assetEntry]: The asset entry with transformer configuration and destination
  /// - [configPath]: Path to the config directory containing source files
  /// 
  /// Returns:
  /// - `true` if the asset was successfully processed
  /// - `false` if processing failed
  static Future<bool> _processAssetWithTransformer(
    AssetEntry assetEntry,
    String configPath,
  ) async {
    final transformer = assetEntry.transformer!;
    
    // Build source file path by combining config path with asset filename
    // Use the path (source) to find the file in config, but destination for output
    final sourcePath = path.join(configPath, path.basename(assetEntry.path));
    final sourceFile = File(sourcePath);
    
    // Check if source file exists in config directory
    if (!sourceFile.existsSync()) {
      print('Source file not found: $sourcePath');
      return false;
    }

    // Create destination directory if it doesn't exist (using destination path)
    final destinationDir = Directory(path.dirname(assetEntry.destination));
    if (!destinationDir.existsSync()) {
      await destinationDir.create(recursive: true);
    }

    // Process based on transformer type
    switch (transformer.type) {
      case 'copy':
        return await _performSimpleCopy(sourceFile, assetEntry.destination);
      
      case 'image_resize':
        return await _performImageResize(sourceFile, assetEntry, transformer);
      
      case 'optimize':
        return await _performOptimization(sourceFile, assetEntry.destination);
      
      default:
        print('Unknown transformer type: ${transformer.type}');
        return false;
    }
  }

  /// Performs a simple file copy operation.
  /// 
  /// This method copies the source file to the destination without any
  /// modifications or transformations.
  static Future<bool> _performSimpleCopy(File sourceFile, String destinationPath) async {
    try {
      await sourceFile.copy(destinationPath);
      print('Copied: ${sourceFile.path} -> $destinationPath');
      return true;
    } catch (e) {
      print('Error copying file: $e');
      return false;
    }
  }

  /// Performs image resizing transformation.
  /// 
  /// This method creates multiple variants of an image based on the
  /// transformer configuration, generating different sizes as specified.
  /// Uses the destination path from the asset entry as the base for variants.
  /// 
  /// Note: This is a placeholder implementation. In a real-world scenario,
  /// you would use an image processing library like 'image' package.
  static Future<bool> _performImageResize(
    File sourceFile,
    AssetEntry assetEntry,
    AssetTransformer transformer,
  ) async {
    try {
      // For now, we'll copy the file for each variant
      // In a real implementation, you would use an image processing library
      // to actually resize the images
      
      if (transformer.variants.isEmpty) {
        // No variants specified, just copy the original to destination
        await sourceFile.copy(assetEntry.destination);
        print('Image copied (no resize): ${sourceFile.path} -> ${assetEntry.destination}');
        return true;
      }

      bool allSuccessful = true;
      for (final variant in transformer.variants) {
        final suffix = variant['suffix'] as String? ?? '';
        final width = variant['width'] as int?;
        final height = variant['height'] as int?;
        
        // Generate variant filename using destination path as base
        final baseName = path.basenameWithoutExtension(assetEntry.destination);
        final extension = path.extension(assetEntry.destination);
        final directory = path.dirname(assetEntry.destination);
        final variantPath = path.join(directory, '$baseName$suffix$extension');
        
        // For now, just copy the file (placeholder for actual image resizing)
        // TODO: Implement actual image resizing using image processing library
        await sourceFile.copy(variantPath);
        print('Image variant created: ${sourceFile.path} -> $variantPath (${width}x$height)');
      }
      
      return allSuccessful;
    } catch (e) {
      print('Error resizing image: $e');
      return false;
    }
  }

  /// Performs file optimization.
  /// 
  /// This method optimizes files based on their type (e.g., compressing images,
  /// minifying JSON, etc.).
  /// 
  /// Note: This is a placeholder implementation.
  static Future<bool> _performOptimization(File sourceFile, String destinationPath) async {
    try {
      // For now, just copy the file (placeholder for actual optimization)
      // In a real implementation, you would optimize based on file type
      await sourceFile.copy(destinationPath);
      print('Optimized: ${sourceFile.path} -> $destinationPath');
      return true;
    } catch (e) {
      print('Error optimizing file: $e');
      return false;
    }
  }

  /// Convenience method to copy assets from a default 'config' directory.
  /// 
  /// This is a simplified version of [copyAssets] that uses sensible defaults
  /// for common use cases. It copies assets from the specified config directory
  /// (defaults to 'config') to destinations defined in pubspec.yaml.
  /// 
  /// Parameters:
  /// - [configPath]: Path to config directory (defaults to 'config')
  /// 
  /// Example:
  /// ```dart
  /// // Copy from default 'config' directory
  /// await AssetCopy.copyAssetsFromConfig();
  /// 
  /// // Copy from custom config directory
  /// await AssetCopy.copyAssetsFromConfig(configPath: 'my_assets');
  /// ```
  static Future<void> copyAssetsFromConfig({
    String configPath = 'config',
  }) async {
    // Delegate to the main copyAssets method with default pubspec path
    await copyAssets(configPath: configPath);
  }
}