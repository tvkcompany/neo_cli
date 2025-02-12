import 'dart:async';
import 'dart:io' show stdout;

/// Represents a single task in the task runner system
class Task {
  final String name;
  final Future<void> Function() execute;
  final String loadingMessage;
  final String completedMessage;

  Task({
    required this.name,
    required this.execute,
    required this.loadingMessage,
    required this.completedMessage,
  });
}

/// A utility class to run tasks with progress indicators and error handling
class TaskRunner {
  /// The list of spinner characters for the loading animation
  static const List<String> _spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  /// Current spinner index
  int _spinnerIndex = 0;

  /// Shows a spinner with the given message
  Future<void> _showSpinner(String message) async {
    stdout.write('\r${_spinner[_spinnerIndex]} $message');
    await Future.delayed(Duration(milliseconds: 100));
    _spinnerIndex = (_spinnerIndex + 1) % _spinner.length;
  }

  /// Clears the current line in the terminal
  void _clearLine() {
    stdout.write('\r${' ' * 100}\r');
  }

  /// Executes a single task with progress indication and error handling
  Future<void> executeTask(Task task) async {
    Timer? spinnerTimer;
    try {
      // Show spinner while task is running
      bool isRunning = true;
      spinnerTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (!isRunning) {
          timer.cancel();
          return;
        }
        _showSpinner(task.loadingMessage);
      });

      // Execute the task
      await task.execute();

      isRunning = false;
      spinnerTimer.cancel();
      _clearLine();

      // Show success message
      print('\x1B[92m✓ ${task.completedMessage}\x1B[0m');
    } catch (e) {
      spinnerTimer?.cancel();
      _clearLine();
      print('\x1B[91m✗ ${task.name} failed: $e\x1B[0m');
      rethrow;
    }
  }

  /// Executes a list of tasks in sequence
  /// Returns true if all tasks completed successfully, false otherwise
  Future<bool> executeTasks(List<Task> tasks) async {
    for (var task in tasks) {
      try {
        await executeTask(task);
      } catch (e) {
        print('\n\x1B[91mExecution failed!\x1B[0m');
        return false;
      }
    }
    return true;
  }
}
