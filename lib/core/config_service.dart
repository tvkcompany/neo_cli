import 'dart:io' show Platform, Directory, File;
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Model class for Neo configuration
class NeoConfig {
  final String organizationIdentifier;
  final List<String> enabledPlatforms;
  final String defaultTemplate;

  NeoConfig({
    this.organizationIdentifier = '',
    this.enabledPlatforms = const [],
    this.defaultTemplate = '',
  });

  /// Creates a config from JSON, handling missing fields for migration support
  factory NeoConfig.fromJson(Map<String, dynamic> json) {
    return NeoConfig(
      organizationIdentifier: json['organizationIdentifier'] as String? ?? '',
      enabledPlatforms: json.containsKey('enabledPlatforms') ? List<String>.from(json['enabledPlatforms'] as List) : [],
      defaultTemplate: json['defaultTemplate'] as String? ?? '',
    );
  }

  /// Converts config to JSON, only including non-empty values
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (organizationIdentifier.isNotEmpty) {
      json['organizationIdentifier'] = organizationIdentifier;
    }
    if (enabledPlatforms.isNotEmpty) {
      json['enabledPlatforms'] = enabledPlatforms;
    }
    if (defaultTemplate.isNotEmpty) {
      json['defaultTemplate'] = defaultTemplate;
    }
    return json;
  }

  /// Creates a new config by merging with another, keeping existing values if not provided in other
  NeoConfig merge(NeoConfig other) {
    return NeoConfig(
      organizationIdentifier: other.organizationIdentifier.isNotEmpty ? other.organizationIdentifier : organizationIdentifier,
      enabledPlatforms: other.enabledPlatforms.isNotEmpty ? other.enabledPlatforms : enabledPlatforms,
      defaultTemplate: other.defaultTemplate.isNotEmpty ? other.defaultTemplate : defaultTemplate,
    );
  }
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
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(config.toJson())}\n');
  }

  /// Checks if configuration exists
  static Future<bool> configExists() async {
    final file = File(configFile);
    return await file.exists();
  }
}
