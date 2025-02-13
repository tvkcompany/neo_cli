import 'package:args/command_runner.dart';
import 'package:neo_cli/commands/commands.dart';
import 'package:neo_cli/core/constants.dart';

void main(List<String> arguments) {
  // Handle version flag directly
  if (arguments.contains('--version') || arguments.contains('-v')) {
    print(NeoConstants.version);
    return;
  }

  // Otherwise, proceed with normal command handling
  CommandRunner('neo', 'Neo CLI')
    ..addCommand(CreateCommand())
    ..addCommand(ConfigCommand())
    ..run(arguments);
}
