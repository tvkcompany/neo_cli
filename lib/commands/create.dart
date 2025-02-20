import 'package:args/command_runner.dart';
import '../core/task_runner.dart';
import '../core/styling.dart';
import '../core/input_utils.dart';
import '../core/validators.dart';
import '../core/config_service.dart';
import '../core/terminal_utils.dart';
import '../core/flutter_service.dart';
import '../core/dart_service.dart';
import '../core/package_service.dart';
import '../core/pubspec_service.dart';
import '../templates/template_manager.dart';
import '../templates/template.dart';
import '../templates/template_variables.dart';

class CreateCommand extends Command {
  final TaskRunner _taskRunner = TaskRunner();
  final FlutterService _flutterService = FlutterService();
  final DartService _dartService = DartService();
  final PackageService _packageService = PackageService();
  final PubspecService _pubspecService = PubspecService();

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
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'Template to use for project creation',
    );
  }

  List<Task> _createTasks(String projectName, String orgIdentifier, List<String> enabledPlatforms, Template template) {
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
            '--description',
            'A new Neo project.',
            projectName,
          ];

          final result = await _flutterService.runFlutter(args);
          if (result.exitCode != 0) {
            throw result.stderr.toString();
          }
        },
      ),
      Task(
        name: 'Neo Installation',
        loadingMessage: 'Installing Neo package...',
        completedMessage: 'Neo package installed',
        execute: () async {
          // Update pubspec.yaml with Neo configurations
          await _pubspecService.updatePubspec(projectName);

          // Install Neo package
          final result = await _flutterService.runFlutter(['pub', 'get'], workingDirectory: projectName);
          if (result.exitCode != 0) {
            _packageService.handlePackageInstallError(result.stderr.toString());
          }
        },
      ),
      Task(
        name: 'Template Setup',
        loadingMessage: 'Setting up template...',
        completedMessage: 'Template setup completed',
        execute: () async {
          // Get all packages to install
          final packages = TemplateManager.getPackagesToInstall(template);

          // Install regular dependencies in one command
          if (packages.regular.isNotEmpty) {
            final result = await _flutterService.runFlutter(
              ['pub', 'add', ...packages.regular],
              workingDirectory: projectName,
            );
            if (result.exitCode != 0) {
              throw result.stderr.toString();
            }
          }

          // Install dev dependencies in one command
          if (packages.dev.isNotEmpty) {
            final result = await _flutterService.runFlutter(
              ['pub', 'add', '--dev', ...packages.dev],
              workingDirectory: projectName,
            );
            if (result.exitCode != 0) {
              throw result.stderr.toString();
            }
          }

          // Apply template files
          await TemplateManager.applyTemplate(
            template: template,
            projectPath: projectName,
            variables: TemplateVariable.createVariableMap(
              projectName: projectName,
            ),
          );

          // Run pub get to ensure all dependencies are properly installed
          final result = await _flutterService.runFlutter(['pub', 'get'], workingDirectory: projectName);
          if (result.exitCode != 0) {
            print(TerminalStyling.warning("\n⚠️ Some packages could not be installed completely."));
            print(TerminalStyling.info(
                "You may need to run 'flutter pub get' manually in the project directory to resolve any remaining issues."));
            print(TerminalStyling.info("Error details: ${result.stderr}"));
            // Don't throw, just continue
          }

          // Run build runner to generate code
          final buildResult = await _dartService.runDart(
            ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
            workingDirectory: projectName,
          );
          if (buildResult.exitCode != 0) {
            print(TerminalStyling.warning("\n⚠️ Code generation could not be completed."));
            print(TerminalStyling.info("You may need to run 'dart run build_runner build' manually in the project directory."));
            print(TerminalStyling.info("Error details: ${buildResult.stderr}"));
            // Don't throw, just continue
          }
        },
      ),
    ];
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
    if (!await _flutterService.isFlutterInstalled()) {
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

    // Get template
    String templateName;
    if (argResults!['template'] != null) {
      templateName = InputUtils.getValidInput(
        fieldName: "Template",
        argValue: argResults!['template'],
        promptMessage: "", // Not used when argValue is provided
        validator: Validators.validateTemplate,
      );
    } else {
      if (config.defaultTemplate.isEmpty) {
        print(TerminalStyling.error("\nNo default template found in configuration. Please run 'neo config' to set it up."));
        return;
      }
      templateName = config.defaultTemplate;
      print(
          TerminalStyling.info("\nUsing configured template: ") + TerminalStyling.colorBold(templateName, TerminalStyling.cyan));
    }

    final template = TemplateManager.getTemplate(templateName);

    print(""); // Add spacing between input and tasks

    final tasks = _createTasks(projectName, orgIdentifier, enabledPlatforms, template);
    final success = await _taskRunner.executeTasks(tasks);

    if (success) {
      print(
          "\n🎉 ${TerminalStyling.success("Neo project")} ${TerminalStyling.colorBold(projectName, TerminalStyling.cyan)} ${TerminalStyling.success("created. Welcome to the future.")}\n");
    }
  }
}
