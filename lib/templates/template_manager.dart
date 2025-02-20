import '../core/styling.dart';
import 'template.dart';
import '../templates.g.dart';

/// Manages template operations and configuration
class TemplateManager {
  /// All available templates (including internal ones like base)
  static final List<Template> templates = _validateTemplates(GeneratedTemplates.templates);

  /// Gets all available templates for users to select from
  /// This excludes internal templates like the base template
  static List<Template> get availableTemplates => templates.where((t) => !t.isBase).toList();

  /// Validates all templates and returns them if valid
  /// Throws if any template is invalid
  static List<Template> _validateTemplates(List<Template> templates) {
    // Ensure we have a base template
    if (!templates.any((t) => t.isBase)) {
      throw StateError('No base template found in templates');
    }

    // Ensure all template names are unique and not empty
    final names = templates.map((t) => t.name);
    if (names.any((name) => name.isEmpty)) {
      throw StateError('Template names cannot be empty');
    }
    if (names.toSet().length != names.length) {
      throw StateError('Duplicate template names found');
    }

    // Validate template variables in all templates
    for (final template in templates) {
      template.validateTemplateVariables();
    }

    return templates;
  }

  /// Gets a template by name
  /// Throws if template is not found
  static Template getTemplate(String name) {
    // Don't allow getting the base template directly
    if (name == 'base') {
      throw 'The base template cannot be used directly. Available templates: ${availableTemplates.map((t) => t.name).join(", ")}';
    }
    return templates.firstWhere(
      (template) => template.name == name,
      orElse: () => throw 'Template "$name" not found. Available templates: ${availableTemplates.map((t) => t.name).join(", ")}',
    );
  }

  /// Validates if a template name exists and is available for use
  static bool isValidTemplate(String name) {
    return availableTemplates.any((template) => template.name == name);
  }

  /// Gets all dependencies for a template (including base dependencies)
  static Map<String, String?> getAllDependencies(Template template) {
    final baseTemplate = templates.firstWhere((t) => t.isBase);
    return {
      ...baseTemplate.dependencies,
      ...template.dependencies,
    };
  }

  /// Gets all dev dependencies for a template (including base dev dependencies)
  static Map<String, String?> getAllDevDependencies(Template template) {
    final baseTemplate = templates.firstWhere((t) => t.isBase);
    return {
      ...baseTemplate.devDependencies,
      ...template.devDependencies,
    };
  }

  /// Applies a template to a project
  static Future<void> applyTemplate({
    required Template template,
    required String projectPath,
    required Map<String, String> variables,
  }) async {
    final baseTemplate = templates.firstWhere((t) => t.isBase);

    // Apply base template first
    await _applyTemplateFiles(
      template: baseTemplate,
      projectPath: projectPath,
      variables: variables,
    );

    // Apply selected template if not base
    if (!template.isBase) {
      await _applyTemplateFiles(
        template: template,
        projectPath: projectPath,
        variables: variables,
      );
    }
  }

  /// Gets all packages to install for a template
  static ({List<String> regular, List<String> dev}) getPackagesToInstall(Template template) {
    final dependencies = getAllDependencies(template);
    final devDependencies = getAllDevDependencies(template);

    // Filter out packages with specific versions for separate installation
    final regularWithoutVersion = dependencies.entries.where((e) => e.value == null).map((e) => e.key).toList();
    final regularWithVersion = dependencies.entries.where((e) => e.value != null).map((e) => '${e.key}:${e.value}').toList();

    final devWithoutVersion = devDependencies.entries.where((e) => e.value == null).map((e) => e.key).toList();
    final devWithVersion = devDependencies.entries.where((e) => e.value != null).map((e) => '${e.key}:${e.value}').toList();

    return (
      regular: [...regularWithoutVersion, ...regularWithVersion],
      dev: [...devWithoutVersion, ...devWithVersion],
    );
  }

  /// Creates files from a template in the project
  static Future<void> _applyTemplateFiles({
    required Template template,
    required String projectPath,
    required Map<String, String> variables,
  }) async {
    for (final entry in template.files.entries) {
      final relativePath = entry.key;
      try {
        await template.createFile(relativePath, projectPath, variables);
      } catch (e) {
        print(TerminalStyling.error("Error creating $relativePath: $e"));
      }
    }
  }
}
