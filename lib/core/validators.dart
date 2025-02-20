import '../templates/template_manager.dart';

/// Utility class for input validation
class Validators {
  /// Validates project name format
  static String? validateProjectName(String value) {
    if (value.isEmpty) {
      return 'Project name cannot be empty';
    }

    if (!RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$').hasMatch(value)) {
      return 'Project name must be in snake_case format (e.g., my_project_name)';
    }

    return null;
  }

  /// Validates organization identifier format
  static String? validateOrgIdentifier(String value) {
    if (value.isEmpty) {
      return 'Organization identifier cannot be empty';
    }

    if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$').hasMatch(value)) {
      return 'Organization identifier must be in reverse domain notation (e.g., com.example)';
    }

    return null;
  }

  /// List of valid Flutter platforms
  static const List<String> validPlatforms = [
    'ios',
    'android',
    'web',
    'macos',
    'windows',
    'linux',
  ];

  /// Gets a list of all available template names
  static List<String> get availableTemplates => TemplateManager.availableTemplates.map((t) => t.name).toList();

  /// Validates platforms format and values
  static String? validatePlatforms(String value) {
    if (value.isEmpty) {
      return 'Platforms list cannot be empty';
    }

    final platforms = value.split(',').map((p) => p.trim()).toSet();
    final invalidPlatforms = platforms.difference(validPlatforms.toSet());
    if (invalidPlatforms.isNotEmpty) {
      return 'Invalid platform(s): ${invalidPlatforms.join(', ')}. Valid platforms are: ${validPlatforms.join(', ')}';
    }

    return null;
  }

  /// Validates a template name
  static String? validateTemplate(String value) {
    if (value.isEmpty) {
      return 'Template name cannot be empty';
    }

    if (!TemplateManager.isValidTemplate(value)) {
      return 'Invalid template: $value. Available templates are: ${availableTemplates.join(", ")}';
    }

    return null;
  }
}
