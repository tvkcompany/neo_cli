import 'package:args/command_runner.dart';
import 'dart:io' show Process, Directory;
import '../core/task_runner.dart';
import '../core/styling.dart';
import '../core/input_utils.dart';
import '../core/validators.dart';
import '../core/config_service.dart';
import '../core/terminal_utils.dart';

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
  }

  List<Task> _createTasks(String projectName, String orgIdentifier) {
    return [
      Task(
        name: 'Directory Creation',
        loadingMessage: 'Creating project directory...',
        completedMessage: 'Project directory created',
        execute: () async {
          final dir = Directory(projectName);
          if (await dir.exists()) {
            throw 'Project directory already exists';
          }
          await dir.create();
        },
      ),
      Task(
        name: 'Flutter Project Creation',
        loadingMessage: 'Creating Flutter project...',
        completedMessage: 'Flutter project created',
        execute: () async {
          // final result = await Process.run('flutter', [
          //   'create',
          //   '--org',
          //   orgIdentifier,
          //   '--project-name',
          //   projectName,
          //   projectName,
          // ]);

          // if (result.exitCode != 0) {
          //   throw result.stderr.toString();
          // }

          await Future.delayed(const Duration(seconds: 3)); // Simulate the creation
        },
      ),
    ];
  }

  @override
  Future<void> run() async {
    // Check if Neo is configured
    if (!await ConfigService.configExists()) {
      print(TerminalStyling.error("\nThe Neo CLI is not configured. Please run 'neo config' first."));
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
      // Use the configured organization identifier
      final config = await ConfigService.readConfig();
      if (config == null || config.organizationIdentifier.isEmpty) {
        print(
            TerminalStyling.error("\nNo organization identifier found in configuration. Please run 'neo config' to set it up."));
        return;
      }
      orgIdentifier = config.organizationIdentifier;
      print(TerminalStyling.info("\nUsing configured organization identifier: ") +
          TerminalStyling.colorBold(orgIdentifier, TerminalStyling.cyan));
    }

    print(""); // Add spacing between input and tasks

    // Get and execute tasks
    final tasks = _createTasks(projectName, orgIdentifier);
    final success = await _taskRunner.executeTasks(tasks);

    if (success) {
      print(
          "\n🎉 ${TerminalStyling.success("Neo project")} ${TerminalStyling.colorBold(projectName, TerminalStyling.cyan)} ${TerminalStyling.success("created. Welcome to the future.")}\n");
    }
  }
}
