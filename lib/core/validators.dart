/// Utility class for input validation
class Validators {
  /// Validates project name format
  static String? validateProjectName(String name) {
    final RegExp snakeCaseRegex = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');
    if (!snakeCaseRegex.hasMatch(name)) {
      return "Project name must be in snake_case format (e.g., my_project_name)";
    }
    return null;
  }

  /// Validates organization identifier format
  static String? validateOrgIdentifier(String identifier) {
    final RegExp reverseDomainRegex = RegExp(r'^[a-z0-9]+(\.[a-z0-9]+)+$');
    if (!reverseDomainRegex.hasMatch(identifier)) {
      return "Organization identifier must be in reverse domain notation (e.g., com.example)";
    }
    return null;
  }
}
