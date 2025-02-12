class TerminalStyling {
  // Colors
  static const String green = '\x1B[92m';
  static const String red = '\x1B[91m';
  static const String cyan = '\x1B[96m';
  static const String yellow = '\x1B[93m';

  // Special
  static const String reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';

  /// Wraps text with a color and automatically resets after
  static String wrap(String text, String color) {
    return '$color$text$reset';
  }

  /// Makes text bold
  static String bold(String text) {
    return wrap(text, _bold);
  }

  /// Makes text bold and colored
  static String colorBold(String text, String color) {
    return '$color$_bold$text$reset';
  }

  /// Wraps text in bright green (success color)
  static String success(String text) {
    return wrap(text, green);
  }

  /// Wraps text in bright red (error color)
  static String error(String text) {
    return colorBold(text, red);
  }

  /// Wraps text in bright cyan
  static String info(String text) {
    return wrap(text, cyan);
  }

  /// Wraps text in bright yellow (warning color)
  static String warning(String text) {
    return wrap(text, yellow);
  }
}
