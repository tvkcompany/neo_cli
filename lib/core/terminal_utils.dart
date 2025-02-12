import 'styling.dart';
import 'constants.dart';

/// Utility class for terminal operations
class TerminalUtils {
  /// Clears the terminal screen and prints the Neo logo
  static void clearAndPrintLogo() {
    // Clear the terminal screen
    print('\x1B[2J\x1B[H');

    // Print logo in bright green
    print(TerminalStyling.success(NeoConstants.logo));
  }
}
