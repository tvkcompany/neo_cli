import 'package:args/command_runner.dart';
import '../core/task_runner.dart';
import '../core/styling.dart';
import '../core/input_utils.dart';
import '../core/validators.dart';
import '../core/config_service.dart';
import '../core/terminal_utils.dart';

class ConfigCommand extends Command {
  final TaskRunner _taskRunner = TaskRunner();

  @override
  String get name => "config";

  @override
  String get description =>
      "Configure default values for the Neo CLI. These values will be used as defaults when creating new projects, but can be overridden per project.";

  ConfigCommand() {
    argParser.addFlag(
      'list',
      abbr: 'l',
      help: 'List all configuration values',
      negatable: false,
    );

    argParser.addOption(
      'org',
      abbr: 'o',
      help: 'Organization identifier in reverse domain notation (e.g., com.example)',
      valueHelp: 'identifier',
    );
  }

  List<Task> _createTasks(String orgIdentifier) {
    return [
      Task(
        name: 'Configuration',
        loadingMessage: 'Saving configuration...',
        completedMessage: 'Configuration saved',
        execute: () async {
          final config = NeoConfig(
            organizationIdentifier: orgIdentifier,
          );
          await ConfigService.writeConfig(config);
        },
      ),
    ];
  }

  @override
  Future<void> run() async {
    TerminalUtils.clearAndPrintLogo();

    // List all config values if requested
    if (argResults!['list']) {
      final config = await ConfigService.readConfig();
      if (config != null) {
        print("\nConfiguration:");
      if (config.organizationIdentifier.isNotEmpty) {
        print(
              "  ${TerminalStyling.info("Organization identifier")}: ${TerminalStyling.colorBold(config.organizationIdentifier, TerminalStyling.cyan)}");
        }
        print(""); // Add spacing at the end
        return;
      }
      print(TerminalStyling.error("\nNo configuration found."));
      return;
    }

    // Read existing config if any
    final existingConfig = await ConfigService.readConfig() ?? NeoConfig();

    // If using CLI flags, only configure specified values
    if (argResults!['org'] != null) {
      final orgIdentifier = InputUtils.getValidInput(
        fieldName: "Organization identifier",
        argValue: argResults!['org'],
        promptMessage: "", // Not used when argValue is provided
        validator: Validators.validateOrgIdentifier,
      );

      // Create and save the config
      final config = NeoConfig(
        organizationIdentifier: orgIdentifier,
      );
      await ConfigService.writeConfig(config);
      print("\n🎉 ${TerminalStyling.success("Neo configuration updated successfully.")}\n");
      return;
    }

    // Always show prompts in interactive mode
    final orgIdentifier = InputUtils.getValidInput(
      fieldName: "Organization identifier",
      argValue: null,
      defaultValue: existingConfig.organizationIdentifier,
      promptMessage:
          "What should be the default organization identifier for new projects? (reverse domain notation, e.g., com.example)",
      validator: Validators.validateOrgIdentifier,
    );

    print(""); // Add spacing between input and tasks

    // Get and execute tasks
    final tasks = _createTasks(orgIdentifier);
    final success = await _taskRunner.executeTasks(tasks);

    if (success) {
      print("\n🎉 ${TerminalStyling.success("Neo configuration saved successfully.")}\n");
    }
  }
}
