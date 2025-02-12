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
  String get name => 'config';

  @override
  String get description => 'Configure the Neo CLI';

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
      help:
          'Organization identifier in reverse domain notation (e.g., com.example). This will be used as the default when creating new projects.',
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
          final config = NeoConfig(organizationIdentifier: orgIdentifier);
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
        print(
            "  ${TerminalStyling.info("Organization identifier")}: ${TerminalStyling.colorBold(config.organizationIdentifier, TerminalStyling.cyan)}");
        print(""); // Add spacing at the end
        return;
      }
      print(TerminalStyling.error("\nNo configuration found."));
      return;
    }

    // Check if config already exists
    if (await ConfigService.configExists() && argResults!['org'] == null) {
      if (!InputUtils.confirm(TerminalStyling.warning(
          "\nNeo is already configured. Running this command will overwrite your current configuration."))) {
        print("\nConfiguration unchanged.");
        return;
      }
    }

    final orgIdentifier = InputUtils.getValidInput(
      fieldName: "Organization identifier",
      argValue: argResults!['org'],
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
