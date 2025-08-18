# Simple Printer

The `SimplePrinter` is a basic implementation of `LogPrinter` that outputs log messages in a straightforward, minimal format. It's designed for scenarios where you want clean, uncluttered log output without any additional formatting.

## Features

- Minimal, clean output
- No colors or additional formatting
- Fast and lightweight
- Thread-safe
- Configurable line breaks

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a simple printer
  final printer = SimplePrinter();
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log some messages
  logger.i('This is an info message');
  logger.d('Debug information');
  logger.e('An error occurred', error: 'Something went wrong');
}
```

## Output Format

The default output format is:
```
[LEVEL] Message
```

Example:
```
[INFO] This is an info message
[DEBUG] Debug information
[ERROR] An error occurred
```

## Configuration Options

### `printTime`
Whether to include timestamps in the output.

```dart
final printer = SimplePrinter(
  printTime: true,
);

// Output: [2023-01-01T12:00:00.000] [INFO] Message
```

### `printLevel`
Whether to include the log level in the output.

```dart
final printer = SimplePrinter(
  printLevel: false,
);

// Output: Message
```

### `printTag`
Whether to include the log tag in the output.

```dart
final printer = SimplePrinter(
  printTag: true,
);

// With logger.tag = 'App'
// Output: [App] [INFO] Message
```

### `printEmojis`
Whether to include emojis for log levels.

```dart
final printer = SimplePrinter(
  printEmojis: true,
);

// Output: ℹ️ [INFO] Message
```

### `lineLength`
Maximum line length before wrapping. Set to `null` to disable wrapping.

```dart
final printer = SimplePrinter(
  lineLength: 80,
);
```

## Custom Formatting

You can customize the output format by extending `SimplePrinter` and overriding the `format` method:

```dart
class CustomSimplePrinter extends SimplePrinter {
  @override
  String format(LogEvent event) {
    final buffer = StringBuffer();
    
    if (printTime) {
      buffer.write('${event.time.toIso8601String()} | ');
    }
    
    if (printEmojis) {
      buffer.write('${_getEmoji(event.level)} ');
    }
    
    if (printLevel) {
      buffer.write('${event.level.name.toUpperCase().padRight(5)} | ');
    }
    
    if (printTag && event.tag != null) {
      buffer.write('${event.tag} | ');
    }
    
    buffer.write(event.message);
    
    if (event.error != null) {
      buffer.write(' | ${event.error}');
    }
    
    return buffer.toString();
  }
  
  String _getEmoji(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => '🔍',
      LogLevel.debug => '🐛',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '❌',
      LogLevel.fatal => '💀',
      _ => ' ', 
    };
  }
}
```

## Best Practices

1. **Use for Production**: `SimplePrinter` is ideal for production environments where you want minimal overhead.

2. **Combine with Other Printers**: Use with `PrefixPrinter` or `HybridPrinter` for more complex scenarios.

3. **Consider Performance**: For high-volume logging, `SimplePrinter` is more efficient than `PrettyPrinter`.

4. **Log Rotation**: When writing to files, implement log rotation to manage log file sizes.

## Example with All Options

```dart
final printer = SimplePrinter(
  printTime: true,
  printLevel: true,
  printTag: true,
  printEmojis: true,
  lineLength: 120,
);

final logger = Logger(
  name: 'MyApp',
  printer: printer,
);

logger.i('Application started');
```

## Output Example

```
2023-01-01T12:00:00.000 [INFO] [MyApp] ℹ️ Application started
```

## Error Handling

By default, `SimplePrinter` includes error information when available:

```dart
try {
  // Some code that throws
} catch (e, stackTrace) {
  logger.e('Operation failed', error: e, stackTrace: stackTrace);
}
```

Output:
```
[ERROR] Operation failed: Exception: Something went wrong
#0      main (file:///example.dart:5:7)
#1      _startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:301:19)
```

## Customizing Error Output

Override the `formatError` method to customize error formatting:

```dart
class CustomSimplePrinter extends SimplePrinter {
  @override
  String formatError(LogEvent event) {
    if (event.error == null) return '';
    
    final buffer = StringBuffer(' | ERROR: ${event.error}');
    
    if (event.stackTrace != null) {
      final trace = event.stackTrace.toString().split('\n').take(3).join('\n');
      buffer.write('\n$trace');
    }
    
    return buffer.toString();
  }
}
```
