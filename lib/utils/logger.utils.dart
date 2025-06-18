import "package:paw/paw.dart";

///
/// Global instance of singleton [Logger] class
///
final kLogger = Logger();

///
/// Singleton [Logger] class.
///
class Logger extends PawInterface {
  // Private constructor to prevent external instantiation.
  Logger._({
    required super.name,
    required super.maxStackTraces,
    required super.shouldIncludeSourceInfo,
    required super.shouldPrintLogs,
    required super.shouldPrintName,
    required super.currentTheme,
    required super.logLevel,
  });

  // Static instance for external access.
  static Logger? _instance;

  // Public factory constructor.
  factory Logger() {
    // Initialize the instance if it hasn't been already.
    _instance ??= Logger._(
      name: "AroundU",
      maxStackTraces: 5,
      shouldIncludeSourceInfo: true,
      shouldPrintLogs: true,
      shouldPrintName: true,
      currentTheme: PawDarkTheme(),
      logLevel: null,
    );

    return _instance!;
  }
}
