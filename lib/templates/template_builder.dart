import 'dart:async';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

/// Creates a template builder
Builder templateBuilder(BuilderOptions options) => TemplateBuilder();

/// Builder that generates template code from template directories
class TemplateBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
        r'$lib$': ['templates.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    log.info('Starting template build...');
    final templateDirs = await _findTemplateDirs(buildStep);
    final buffer = StringBuffer();

    // Write file header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln('import "package:neo_cli/templates/template.dart";');
    buffer.writeln();

    // Generate template constants
    buffer.writeln('/// Generated template constants');
    buffer.writeln('class GeneratedTemplates {');

    // Generate template definitions
    for (final dir in templateDirs) {
      final templateName = path.basename(dir);
      await _generateTemplateCode(buffer, templateName, dir, buildStep);
    }

    // Generate template list
    buffer.writeln('  /// List of all available templates');
    buffer.writeln('  static final List<Template> templates = [');
    for (final dir in templateDirs) {
      final templateName = path.basename(dir);
      buffer.writeln('    ${templateName}Template,');
    }
    buffer.writeln('  ];');

    buffer.writeln('}');

    // Write the generated file
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/templates.g.dart'),
      buffer.toString(),
    );
  }

  Future<List<String>> _findTemplateDirs(BuildStep buildStep) async {
    final dirs = <String>[];
    // Use forward slashes for glob patterns
    await for (final input in buildStep.findAssets(Glob('lib/templates/*/config.dart'))) {
      final dir = path.dirname(input.path);
      if (!dirs.contains(dir)) dirs.add(dir);
    }
    return dirs;
  }

  Future<void> _generateTemplateCode(
    StringBuffer buffer,
    String templateName,
    String templateDir,
    BuildStep buildStep,
  ) async {
    buffer.writeln('  /// Template files for $templateName');
    buffer.writeln('  static const Map<String, String> _${templateName}Files = {');

    // Add template files
    // Always use forward slashes for glob patterns
    final filesDir = path.join(templateDir, 'files').replaceAll(r'\', '/');

    await for (final file in buildStep.findAssets(Glob('$filesDir/**'))) {
      // Always normalize paths to use forward slashes
      final normalizedPath = path.relative(file.path, from: filesDir).replaceAll(r'\', '/');
      final content = await buildStep.readAsString(file);

      buffer.writeln("    '$normalizedPath': '''");
      buffer.writeln(content);
      buffer.writeln("''',");
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Read config file
    final configAsset = AssetId(buildStep.inputId.package, '$templateDir/config.dart'.replaceAll(r'\', '/'));
    final configContent = await buildStep.readAsString(configAsset);

    // Extract dependencies using more robust regex
    final depRegex = RegExp(r'dependencies:\s*{([^}]*)},', multiLine: true);
    final devDepRegex = RegExp(r'devDependencies:\s*{([^}]*)},', multiLine: true);

    String? deps = depRegex.firstMatch(configContent)?.group(1)?.trim();
    String? devDeps = devDepRegex.firstMatch(configContent)?.group(1)?.trim();

    // Add template definition
    buffer.writeln('  /// The $templateName template');
    buffer.writeln('  static final Template ${templateName}Template = Template(');
    buffer.writeln('    name: "$templateName",');
    buffer.writeln('    files: _${templateName}Files,');
    if (deps != null && deps.isNotEmpty) {
      buffer.writeln('    dependencies: {');
      for (final dep in deps.split('\n')) {
        final trimmed = dep.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('//')) {
          buffer.writeln('      $trimmed');
        }
      }
      buffer.writeln('    },');
    }
    if (devDeps != null && devDeps.isNotEmpty) {
      buffer.writeln('    devDependencies: {');
      for (final dep in devDeps.split('\n')) {
        final trimmed = dep.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('//')) {
          buffer.writeln('      $trimmed');
        }
      }
      buffer.writeln('    },');
    }
    buffer.writeln('  );');
    buffer.writeln();
  }
}
