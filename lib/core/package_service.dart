import 'styling.dart';

/// Service class to handle package-related operations
class PackageService {
  /// Handles package installation errors with appropriate user feedback
  void handlePackageInstallError(String errorOutput) {
    final lowerError = errorOutput.toLowerCase();
    if (lowerError.contains('permission denied (publickey)') ||
        lowerError.contains('host key verification failed') ||
        lowerError.contains('could not resolve host')) {
      print(TerminalStyling.warning("\n⚠️ Could not fetch the Neo package due to SSH key configuration issues."));
      print(TerminalStyling.info(
          "Please follow the installation guide at: https://github.com/tvkcompany/neo/blob/production/docs/installation.md"));
      print(TerminalStyling.info(
          "Once your SSH key is properly configured, run 'flutter pub get' in the project directory to fetch the Neo package."));
      return;
    }
    throw errorOutput;
  }
}
