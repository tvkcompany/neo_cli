import 'dart:io' show Platform, Directory, File;
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Model class for Neo configuration
class NeoConfig {
  final String organizationIdentifier;

  NeoConfig({required this.organizationIdentifier});

  /// Creates a config from JSON
  factory NeoConfig.fromJson(Map<String, dynamic> json) {
    return NeoConfig(
      organizationIdentifier: json['organizationIdentifier'] as String,
    );
  }

  /// Converts config to JSON
  Map<String, dynamic> toJson() => {
        'organizationIdentifier': organizationIdentifier,
      };
}

/// Service for handling Neo configuration
class ConfigService {
  /// Gets the path to the Neo config directory
  static String get configDir {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
    return path.join(home, '.config', 'Neo');
  }

  /// Gets the path to the config file
  static String get configFile => path.join(configDir, 'config.json');

  /// Ensures the config directory exists
  static Future<void> ensureConfigDir() async {
    final dir = Directory(configDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Reads the current configuration
  static Future<NeoConfig?> readConfig() async {
    final file = File(configFile);
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return NeoConfig.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Writes the configuration to file
  static Future<void> writeConfig(NeoConfig config) async {
    await ensureConfigDir();
    final file = File(configFile);
    await file.writeAsString(jsonEncode(config.toJson()));
  }

  /// Checks if configuration exists
  static Future<bool> configExists() async {
    final file = File(configFile);
    return await file.exists();
  }
}
