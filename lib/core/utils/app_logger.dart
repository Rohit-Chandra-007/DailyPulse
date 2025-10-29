import 'package:logger/logger.dart';

/// Global logger instance for the application
///
/// Usage:
/// - appLogger.d('Debug message');
/// - appLogger.i('Info message');
/// - appLogger.w('Warning message');
/// - appLogger.e('Error message', error: error, stackTrace: stackTrace);
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug,
);

/// Logger for production with minimal output
final productionLogger = Logger(
  printer: SimplePrinter(colors: false, printTime: true),
  level: Level.warning,
);
