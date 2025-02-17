import 'dart:io' show Platform, Process, ProcessResult;

/// Service class to handle Flutter-specific operations across the application
class FlutterService {
  /// Helper method to run Flutter commands consistently across platforms
  Future<ProcessResult> runFlutter(List<String> args, {String? workingDirectory}) async {
    final command = Platform.isWindows ? 'flutter.bat' : 'flutter';
    final result = await Process.run(
      command,
      args,
      environment: Platform.environment,
      workingDirectory: workingDirectory,
    );
    return result;
  }

  /// Checks if Flutter is installed and available in the system
  Future<bool> isFlutterInstalled() async {
    try {
      final result = await runFlutter(['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}
