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
    print('[DEBUG] Creating file: $relativePath in $projectPath');
    print('[DEBUG] Template: $name');
    print('[DEBUG] Available files in template: ${files.keys.join(', ')}');

    final content = files[relativePath];
    if (content == null) {
      print('[DEBUG] No content found for $relativePath');
      return;
    }

    // Validate variables
    for (final key in variables.keys) {
      if (!TemplateVariable.isValidPlaceholder(key)) {
        final error =
            'Invalid template variable: $key. Available variables: ${TemplateVariable.availablePlaceholders.join(", ")}';
        print('[DEBUG] Variable validation failed: $error');
        throw ArgumentError(error);
      }
    }

    final destinationPath = path.join(projectPath, relativePath);
    final destFile = File(destinationPath);

    print('[DEBUG] Creating directories for: ${destFile.parent.path}');
    try {
      // Create parent directories if they don't exist
      await destFile.parent.create(recursive: true);
    } catch (e) {
      print('[DEBUG] Failed to create directories: $e');
      rethrow;
    }

    // Process content with variables
    String processedContent = content;
    for (final entry in variables.entries) {
      processedContent = processedContent.replaceAll('{{${entry.key}}}', entry.value);
    }

    print('[DEBUG] Writing file: ${destFile.path}');
    try {
      // Write the file
      await destFile.writeAsString(processedContent);
      print('[DEBUG] Successfully wrote file: ${destFile.path}');
    } catch (e) {
      print('[DEBUG] Failed to write file: $e');
      rethrow;
    }
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
