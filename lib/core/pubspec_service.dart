import 'dart:io' show File;
import 'package:path/path.dart' as path;
import 'package:yaml_edit/yaml_edit.dart';

/// Service class to handle pubspec.yaml modifications
class PubspecService {
  /// Updates the pubspec.yaml file with Neo-specific configurations
  Future<void> updatePubspec(String projectPath) async {
    final pubspecPath = path.join(projectPath, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);

    if (!await pubspecFile.exists()) {
      throw 'pubspec.yaml not found in the project';
    }

    final content = await pubspecFile.readAsString();
    final yamlEditor = YamlEditor(content);

    // Update SDK version
    yamlEditor.update(['environment', 'sdk'], '^3.6.0');

    // Add Neo package dependency
    yamlEditor.update([
      'dependencies',
      'neo'
    ], {
      'git': {'url': 'git@github.com:tvkcompany/neo.git', 'ref': 'production'}
    });

    // Add font configurations
    final fonts = [
      {
        'family': 'Inter',
        'fonts': [
          {'asset': 'packages/neo/assets/fonts/Inter-Regular.otf', 'weight': 400},
          {'asset': 'packages/neo/assets/fonts/Inter-Medium.otf', 'weight': 500},
          {'asset': 'packages/neo/assets/fonts/Inter-Bold.otf', 'weight': 700}
        ]
      },
      {
        'family': 'Geist Mono',
        'fonts': [
          {'asset': 'packages/neo/assets/fonts/GeistMono-Regular.otf', 'weight': 400}
        ]
      }
    ];

    yamlEditor.update(['flutter', 'fonts'], fonts);

    // Write the updated content back to the file
    await pubspecFile.writeAsString(yamlEditor.toString());
  }
}
