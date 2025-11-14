import 'dart:io' show File;
import 'package:path/path.dart' as path;

/// Service class to handle analysis_options.yaml modifications
class AnalysisOptionsService {
  /// Updates the analysis_options.yaml file with Neo-specific configurations
  Future<void> updateAnalysisOptions(String projectPath) async {
    final analysisOptionsPath = path.join(projectPath, 'analysis_options.yaml');
    final analysisOptionsFile = File(analysisOptionsPath);

    if (!await analysisOptionsFile.exists()) {
      throw 'analysis_options.yaml not found in the project';
    }

    final content = await analysisOptionsFile.readAsString();

    // Append Neo-specific configurations to the end of the file
    final updatedContent =
        '''
$content

analyzer:
  errors:
    invalid_annotation_target: ignore

formatter:
  trailing_commas: preserve
''';

    // Write the updated content back to the file
    await analysisOptionsFile.writeAsString(updatedContent.trim());
  }
}
