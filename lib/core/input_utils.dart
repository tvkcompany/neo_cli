import 'dart:io' show stdin, stdout, exit;
import 'styling.dart';

/// Utility class for handling user input
class InputUtils {
  /// Gets and validates input, either from arguments or prompt
  static String getValidInput({
    required String fieldName,
    required String? argValue,
    required String promptMessage,
    required String? Function(String) validator,
    String? defaultValue,
  }) {
    // If argument is provided, validate it
    if (argValue != null) {
      final error = validator(argValue);
      if (error != null) {
        print(TerminalStyling.error("\n$error"));
        exit(64); // Exit with code 64 (command line usage error)
      }
      print(TerminalStyling.info("\nUsing provided ${fieldName.toLowerCase()}: ") +
          TerminalStyling.colorBold(argValue, TerminalStyling.cyan));
      return argValue;
    }

    // Otherwise, prompt for input
    while (true) {
      if (defaultValue != null && defaultValue.isNotEmpty) {
        print("\n$promptMessage");
        print("Press enter to keep current value: ${TerminalStyling.colorBold(defaultValue, TerminalStyling.cyan)}");
      } else {
        print("\n$promptMessage");
      }
      stdout.write("> ");
      final input = stdin.readLineSync()?.trim();

      // Return default value if input is empty and default exists
      if ((input == null || input.isEmpty) && defaultValue != null && defaultValue.isNotEmpty) {
        return defaultValue;
      }

      if (input == null || input.isEmpty) {
        print(TerminalStyling.error("$fieldName is required"));
        continue;
      }

      final error = validator(input);
      if (error != null) {
        print(TerminalStyling.error(error));
        continue;
      }

      return input;
    }
  }

  /// Prompts for yes/no confirmation
  static bool confirm(String message) {
    print(message);
    print("Do you want to continue? (y/N)");

    final response = stdin.readLineSync()?.toLowerCase();
    return response == 'y';
  }
}
