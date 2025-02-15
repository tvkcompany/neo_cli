import 'package:args/command_runner.dart';
import 'package:neo_cli/commands/commands.dart';
import 'package:neo_cli/core/constants.dart';

void main(List<String> arguments) {
  // Create command runner with global flags
  final runner = CommandRunner('neo', 'Neo CLI')
    ..addCommand(CreateCommand())
    ..addCommand(ConfigCommand())
    ..argParser.addFlag(
      'version',
      abbr: 'v',
      help: 'Print the current version of the Neo CLI.',
      negatable: false,
    );

  // Handle version flag
  final args = runner.argParser.parse(arguments);
  if (args['version']) {
    print(NeoConstants.version);
    return;
  }

  // Run the command
  runner.run(arguments);
}
