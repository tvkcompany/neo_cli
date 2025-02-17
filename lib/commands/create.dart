import 'package:args/command_runner.dart';
import '../core/task_runner.dart';
import '../core/styling.dart';
import '../core/input_utils.dart';
import '../core/validators.dart';
import '../core/config_service.dart';
import '../core/terminal_utils.dart';
import '../core/flutter_service.dart';
import '../core/package_service.dart';

class CreateCommand extends Command {
  final TaskRunner _taskRunner = TaskRunner();
  final FlutterService _flutterService = FlutterService();
  final PackageService _packageService = PackageService();

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

          final result = await _flutterService.runFlutter(args);
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
          await _packageService.addNeoPackage(projectName);
        },
      ),
      Task(
        name: 'Package Installation',
        loadingMessage: 'Installing packages...',
        completedMessage: 'Packages installed successfully',
        execute: () async {
          final result = await _flutterService.runFlutter(['pub', 'get'], workingDirectory: projectName);
          if (result.exitCode != 0) {
            _packageService.handlePackageInstallError(result.stderr.toString());
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

    print(""); // Add spacing between input and tasks

    final tasks = _createTasks(projectName, orgIdentifier, enabledPlatforms);
    final success = await _taskRunner.executeTasks(tasks);

    if (success) {
      print(
          "\n🎉 ${TerminalStyling.success("Neo project")} ${TerminalStyling.colorBold(projectName, TerminalStyling.cyan)} ${TerminalStyling.success("created. Welcome to the future.")}\n");
    }
  }
}
