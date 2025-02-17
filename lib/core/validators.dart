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

  /// List of valid Flutter platforms
  static const List<String> validPlatforms = [
    'ios',
    'android',
    'web',
    'macos',
    'windows',
    'linux',
  ];

  /// Validates platforms format and values
  static String? validatePlatforms(String platforms) {
    if (platforms.isEmpty) {
      return "Platforms list cannot be empty";
    }

    // Check format (comma-separated, no spaces)
    if (platforms.contains(' ')) {
      return "Platforms must be comma-separated without spaces (e.g., ios,web,macos)";
    }

    final platformList = platforms.split(',');
    if (platformList.isEmpty) {
      return "At least one platform must be specified";
    }

    // Check for duplicates
    if (platformList.length != platformList.toSet().length) {
      return "Duplicate platforms are not allowed";
    }

    // Validate each platform
    for (final platform in platformList) {
      if (!validPlatforms.contains(platform)) {
        return "Invalid platform: $platform. Valid platforms are: ${validPlatforms.join(', ')}";
      }
    }

    return null;
  }
}
