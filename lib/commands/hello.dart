import 'package:args/command_runner.dart';

class HelloCommand extends Command {
  @override
  String get name => 'hello';

  @override
  String get description => 'Test command that prints Hello, Terminal!';

  @override
  void run() {
    print('Hello, Terminal!');
  }
}
