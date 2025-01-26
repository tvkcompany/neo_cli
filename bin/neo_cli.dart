// bin/neo_cli.dart
import 'package:args/command_runner.dart';
import 'package:neo_cli/commands/commands.dart';

void main(List<String> arguments) {
  CommandRunner('neo', 'Neo CLI')
    ..addCommand(HelloCommand())
    ..run(arguments);
}
