import 'dart:io' show File;
import 'package:path/path.dart' as path;
import 'styling.dart';

/// Service class to handle package-related operations
class PackageService {
  /// Adds the Neo package to the project's pubspec.yaml file
  Future<void> addNeoPackage(String projectName) async {
    final pubspecPath = path.join(projectName, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);

    if (!await pubspecFile.exists()) {
      throw 'pubspec.yaml not found in the created project';
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    final dependenciesIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
    if (dependenciesIndex == -1) {
      throw 'Could not find dependencies section in pubspec.yaml';
    }

    final baseIndentation = '  ';
    final neoDependency = '''${baseIndentation}neo:
$baseIndentation  git:
$baseIndentation    url: git@github.com:tvkcompany/neo.git
$baseIndentation    ref: production''';

    lines.insert(dependenciesIndex + 1, neoDependency);
    await pubspecFile.writeAsString(lines.join('\n'));
  }

  /// Handles package installation errors with appropriate user feedback
  void handlePackageInstallError(String errorOutput) {
    final lowerError = errorOutput.toLowerCase();
    if (lowerError.contains('permission denied (publickey)') ||
        lowerError.contains('host key verification failed') ||
        lowerError.contains('could not resolve host')) {
      print(TerminalStyling.warning("\n⚠️ Could not fetch the Neo package due to SSH key configuration issues."));
      print(TerminalStyling.info(
          "Please follow the installation guide at: https://github.com/tvkcompany/neo/blob/production/docs/installation.md"));
      print(TerminalStyling.info(
          "Once your SSH key is properly configured, run 'flutter pub get' in the project directory to fetch the Neo package."));
      return;
    }
    throw errorOutput;
  }
}
