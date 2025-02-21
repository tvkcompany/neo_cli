import 'dart:io';
import 'package:path/path.dart' as path;
import 'template_variables.dart';

/// Represents a Neo project template
class Template {
  /// The name of the template
  final String name;

  /// Regular dependencies required by this template
  final Map<String, String?> dependencies;

  /// Development dependencies required by this template
  final Map<String, String?> devDependencies;

  /// The template files as a map of relative path to content
  final Map<String, String> files;

  /// Creates a new template
  ///
  /// Throws if any file content contains invalid template variables
  const Template({
    required this.name,
    this.dependencies = const {},
    this.devDependencies = const {},
    this.files = const {},
  });

  /// Whether this is the base template
  bool get isBase => name == 'base';

  /// Creates a file in the project from a template file
  ///
  /// [relativePath] is the path relative to the project root
  /// [projectPath] is the absolute path to the project root
  /// [variables] is a map of template variables to their values
  ///
  /// Throws if the file cannot be created or if any variable is invalid
  Future<void> createFile(String relativePath, String projectPath, Map<String, String> variables) async {
    final content = files[relativePath];
    if (content == null) return;

    // Validate variables
    for (final key in variables.keys) {
      if (!TemplateVariable.isValidPlaceholder(key)) {
        throw ArgumentError(
            'Invalid template variable: $key. Available variables: ${TemplateVariable.availablePlaceholders.join(", ")}');
      }
    }

    final destinationPath = path.join(projectPath, relativePath);
    final destFile = File(destinationPath);

    // Create parent directories if they don't exist
    await destFile.parent.create(recursive: true);

    // Process content with variables
    String processedContent = content;
    for (final entry in variables.entries) {
      processedContent = processedContent.replaceAll('{{${entry.key}}}', entry.value);
    }

    // Write the file
    await destFile.writeAsString(processedContent);
  }

  /// Validates that all template variables in all files are valid
  /// Returns true if all variables are valid, throws otherwise
  bool validateTemplateVariables() {
    final regex = RegExp(r'{{([^}]+)}}');
    for (final entry in files.entries) {
      final matches = regex.allMatches(entry.value);
      for (final match in matches) {
        final variable = match.group(1)!;
        if (!TemplateVariable.isValidPlaceholder(variable)) {
          throw ArgumentError('Invalid template variable in ${entry.key}: $variable. '
              'Available variables: ${TemplateVariable.availablePlaceholders.join(", ")}');
        }
      }
    }
    return true;
  }
}
