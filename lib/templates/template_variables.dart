/// Variables that can be used in template files
enum TemplateVariable {
  /// The name of the project (e.g., my_project_name)
  projectName('_PROJECT_NAME_');

  /// The string to use in template files (e.g., {{_PROJECT_NAME_}})
  final String placeholder;

  const TemplateVariable(this.placeholder);

  /// Gets the full placeholder syntax (e.g., {{_PROJECT_NAME_}})
  String get syntax => '{{$placeholder}}';

  /// Creates a map of variables with their values
  static Map<String, String> createVariableMap({
    required String projectName,
  }) {
    // Ensure we're using the enum values to prevent typos
    return {
      TemplateVariable.projectName.placeholder: projectName,
    };
  }

  /// Validates if a placeholder is valid
  static bool isValidPlaceholder(String placeholder) {
    return values.any((v) => v.placeholder == placeholder);
  }

  /// Gets all available placeholders
  static List<String> get availablePlaceholders => values.map((v) => v.placeholder).toList();
}
