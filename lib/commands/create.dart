import 'package:args/command_runner.dart';
import 'dart:io' show Process, File;
import '../core/task_runner.dart';
import '../core/styling.dart';
import '../core/input_utils.dart';
import '../core/validators.dart';
import '../core/config_service.dart';
import '../core/terminal_utils.dart';
import 'package:path/path.dart' as path;

class CreateCommand extends Command {
  final TaskRunner _taskRunner = TaskRunner();

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter project using Neo';

  CreateCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Name of the project to create',
    );
    argParser.addOption(
      'org',
      abbr: 'o',
      help: 'Organization identifier in reverse domain notation (e.g., com.example)',
    );
    argParser.addOption(
      'platforms',
      abbr: 'p',
      help: 'Comma-separated list of platforms to enable (e.g., ios,web,macos)',
    );
  }

  List<Task> _createTasks(String projectName, String orgIdentifier, List<String> enabledPlatforms) {
    return [
      Task(
        name: 'Flutter Project Creation',
        loadingMessage: 'Creating Flutter project...',
        completedMessage: 'Flutter project created',
        execute: () async {
          final args = [
            'create',
            '--org',
            orgIdentifier,
            '--project-name',
            projectName,
            '--platforms',
            enabledPlatforms.join(','),
            projectName,
          ];

          final result = await Process.run('flutter', args);

          if (result.exitCode != 0) {
            throw result.stderr.toString();
          }
        },
      ),
      Task(
        name: 'Neo Package Addition',
        loadingMessage: 'Adding Neo package...',
        completedMessage: 'Neo package added',
        execute: () async {
          final pubspecPath = path.join(projectName, 'pubspec.yaml');
          final pubspecFile = File(pubspecPath);

          if (!await pubspecFile.exists()) {
            throw 'pubspec.yaml not found in the created project';
          }

          final content = await pubspecFile.readAsString();
          final lines = content.split('\n');

          // Find the dependencies section
          final dependenciesIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
          if (dependenciesIndex == -1) {
            throw 'Could not find dependencies section in pubspec.yaml';
          }

          // Add neo dependency while preserving indentation
          final baseIndentation = '  '; // Standard YAML indentation
          final neoDependency = '''${baseIndentation}neo:
$baseIndentation  git:
$baseIndentation    url: git@github.com:tvkcompany/neo.git
$baseIndentation    ref: production''';

          // Insert the neo dependency after the dependencies: line
          lines.insert(dependenciesIndex + 1, neoDependency);

          // Write the updated content back to the file
          await pubspecFile.writeAsString(lines.join('\n'));
        },
      ),
      Task(
        name: 'Package Installation',
        loadingMessage: 'Installing packages...',
        completedMessage: 'Packages installed successfully',
        execute: () async {
          final result = await Process.run('flutter', ['pub', 'get'], workingDirectory: projectName);

          if (result.exitCode != 0) {
            final errorOutput = result.stderr.toString().toLowerCase();

            // Check if the error is related to SSH key/authentication
            if (errorOutput.contains('permission denied (publickey)') ||
                errorOutput.contains('host key verification failed') ||
                errorOutput.contains('could not resolve host')) {
              print(TerminalStyling.warning("\n⚠️ Could not fetch the Neo package due to SSH key configuration issues."));
              print(TerminalStyling.info(
                  "Please follow the installation guide at: https://github.com/tvkcompany/neo/blob/production/docs/installation.md"));
              print(TerminalStyling.info(
                  "Once your SSH key is properly configured, run 'flutter pub get' in the project directory to fetch the Neo package."));
              // Don't throw an error, just warn the user
              return;
            }

            // For other errors, throw normally
            throw result.stderr.toString();
          }
        },
      ),
    ];
  }

  Future<bool> _isFlutterInstalled() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> run() async {
    // Check if Neo is configured
    final config = await ConfigService.readConfig();
    if (config == null) {
      print(TerminalStyling.error("\nThe Neo CLI is not configured. Please run 'neo config' first."));
      return;
    }

    // Check if Flutter is installed
    if (!await _isFlutterInstalled()) {
      print(TerminalStyling.error(
          "\nFlutter is not installed. Please install Flutter first: https://flutter.dev/docs/get-started/install"));
      return;
    }

    TerminalUtils.clearAndPrintLogo();

    final projectName = InputUtils.getValidInput(
      fieldName: "Project name",
      argValue: argResults!['name'],
      promptMessage: "What should the project be called? (e.g., my_project_name)",
      validator: Validators.validateProjectName,
    );

    // Get organization identifier
    String orgIdentifier;
    if (argResults!['org'] != null) {
      // Validate and use the provided override
      orgIdentifier = InputUtils.getValidInput(
        fieldName: "Organization identifier",
        argValue: argResults!['org'],
        promptMessage: "", // Not used when argValue is provided
        validator: Validators.validateOrgIdentifier,
      );
    } else {
      if (config.organizationIdentifier.isEmpty) {
        print(
            TerminalStyling.error("\nNo organization identifier found in configuration. Please run 'neo config' to set it up."));
        return;
      }
      orgIdentifier = config.organizationIdentifier;
      print(TerminalStyling.info("\nUsing configured organization identifier: ") +
          TerminalStyling.colorBold(orgIdentifier, TerminalStyling.cyan));
    }

    // Get platforms
    List<String> enabledPlatforms;
    if (argResults!['platforms'] != null) {
      // Validate and use the provided override
      final enabledPlatformsInput = InputUtils.getValidInput(
        fieldName: "Enabled platforms",
        argValue: argResults!['platforms'],
        promptMessage: "", // Not used when argValue is provided
        validator: Validators.validatePlatforms,
      );
      enabledPlatforms = enabledPlatformsInput.split(',');
    } else {
      if (config.enabledPlatforms.isEmpty) {
        print(TerminalStyling.error("\nNo enabled platforms found in configuration. Please run 'neo config' to set them up."));
        return;
      }
      enabledPlatforms = config.enabledPlatforms;
      print(TerminalStyling.info("\nUsing configured enabled platforms: ") +
          TerminalStyling.colorBold(enabledPlatforms.join(','), TerminalStyling.cyan));
    }

    print(""); // Add spacing between input and tasks

    // Get and execute tasks
    final tasks = _createTasks(projectName, orgIdentifier, enabledPlatforms);
    final success = await _taskRunner.executeTasks(tasks);

    if (success) {
      print(
          "\n🎉 ${TerminalStyling.success("Neo project")} ${TerminalStyling.colorBold(projectName, TerminalStyling.cyan)} ${TerminalStyling.success("created. Welcome to the future.")}\n");
    }
  }
}
