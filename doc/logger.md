# Logger

The `Logger` class is the main interface for logging messages in your application. It provides methods for logging at different levels and supports custom printers.

## Features

- Log messages at different levels (debug, info, warning, error, etc.)
- Support for custom log printers
- Structured logging with metadata
- Exception and error logging with stack traces

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a logger
  final logger = Logger();
  
  // Log messages at different levels
  logger.v('Verbose message');
  logger.d('Debug message');
  logger.i('Info message');
  logger.w('Warning message');
  logger.e('Error message', error: 'Something went wrong');
  logger.wtf('WTF message');
  
  // Log with metadata
  logger.i('User logged in', data: {'userId': 123, 'username': 'johndoe'});
  
  // Log with a custom printer
  final customPrinter = PrettyPrinter(
    colors: true,
    printEmojis: true,
  );
  logger.d('Custom formatted message', printer: customPrinter);
}
```

## Methods

### `v(String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log a verbose message.

### `d(String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log a debug message.

### `i(String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log an info message.

### `w(String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log a warning message.

### `e(String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log an error message.

### `wtf(String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log a "What a Terrible Failure" message. Use this for critical errors.

### `log(LogLevel level, String message, {dynamic error, StackTrace? stackTrace, dynamic data, LogPrinter? printer})`
Log a message at the specified level.

## Configuration

The logger can be configured using the `LogConfig` class. You can set the default log level, enable/disable colors, and more.

```dart
// Configure the logger
Logger.configure(
  LogConfig(
    level: LogLevel.debug,
    colors: true,
    printTime: true,
  ),
);
```

## Best Practices

1. **Use appropriate log levels**:
   - `v` - Verbose (noisy, development only)
   - `d` - Debug (development only)
   - `i` - Info (production-visible, but verbose)
   - `w` - Warning (potentially harmful situations)
   - `e` - Error (errors that should be fixed)
   - `wtf` - Critical failures (should never happen)

2. **Use structured logging** when possible to make log analysis easier:
   ```dart
   logger.i('User action', data: {
     'action': 'login',
     'userId': user.id,
     'timestamp': DateTime.now().toIso8601String(),
   });
   ```

3. **Pass exceptions** with the `error` parameter to include stack traces:
   ```dart
   try {
     // Some code that might throw
   } catch (e, stackTrace) {
     logger.e('Failed to process request', error: e, stackTrace: stackTrace);
   }
   ```
