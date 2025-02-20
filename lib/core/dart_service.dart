import 'dart:io' show Platform, Process, ProcessResult;

/// Service class to handle Dart-specific operations across the application
class DartService {
  /// Helper method to run Dart commands consistently across platforms
  Future<ProcessResult> runDart(List<String> args, {String? workingDirectory}) async {
    final command = Platform.isWindows ? 'dart.exe' : 'dart';
    final result = await Process.run(
      command,
      args,
      environment: Platform.environment,
      workingDirectory: workingDirectory,
    );
    return result;
  }
}
