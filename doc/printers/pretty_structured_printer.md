# Pretty Structured Printer

The `PrettyStructuredPrinter` is an implementation of `LogPrinter` that outputs logs in a structured, human-readable format with syntax highlighting and proper indentation. It's ideal for development and debugging purposes where readability is important.

## Features

- Colorful, formatted output
- Nested object visualization
- Syntax highlighting
- Configurable indentation
- Thread-safe

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a pretty structured printer
  final printer = PrettyStructuredPrinter(
    colors: true,      // Enable colors
    printTime: true,   // Show timestamps
    printLevel: true,  // Show log levels
  );
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log structured data
  logger.i('User logged in', data: {
    'userId': 123,
    'email': 'user@example.com',
    'roles': ['admin', 'user'],
    'preferences': {
      'theme': 'dark',
      'notifications': true,
    },
  });
  
  // Log with error
  try {
    throw Exception('Invalid operation');
  } catch (e, stackTrace) {
    logger.e('Operation failed', 
      error: e,
      stackTrace: stackTrace,
      data: {'attempt': 3},
    );
  }
}
```

## Output Example

```
ℹ️ 2023-01-01T12:00:00.000Z [INFO] User logged in
{
  "userId": 123,
  "email": "user@example.com",
  "roles": [
    "admin",
    "user"
  ],
  "preferences": {
    "theme": "dark",
    "notifications": true
  }
}

❌ 2023-01-01T12:00:01.000Z [ERROR] Operation failed
Error: Exception: Invalid operation
Stack Trace:
#0      main (file:///example.dart:10:5)
#1      _startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:301:19)

{
  "attempt": 3
}
```

## Configuration Options

### Basic Configuration

```dart
final printer = PrettyStructuredPrinter(
  colors: true,               // Enable/disable colors
  printTime: true,            // Show/hide timestamps
  printLevel: true,           // Show/hide log levels
  printTag: true,             // Show/hide log tags
  printEmojis: true,          // Show/hide emojis
  lineLength: 80,             // Wrap lines longer than this
  indent: '  ',               // Indentation string
  errorMethodCount: 8,        // Number of stack trace methods to show
  excludeBox: [               // Exclude packages from stack traces
    'package:stack_trace',
    'dart:async',
  ],
  noBoxingByDefault: false,   // Disable box drawing
);
```

### Color Customization

```dart
final printer = PrettyStructuredPrinter(
  colors: {
    LogLevel.verbose: AnsiColor.fg(8),     // Gray
    LogLevel.debug: AnsiColor.fg(14),     // Cyan
    LogLevel.info: AnsiColor.fg(12),      // Blue
    LogLevel.warning: AnsiColor.fg(11),   // Yellow
    LogLevel.error: AnsiColor.fg(9),      // Red
    LogLevel.fatal: AnsiColor.fg(196),    // Bright red
  },
  emojis: {
    LogLevel.verbose: '🔍',
    LogLevel.debug: '🐛',
    LogLevel.info: 'ℹ️',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
    LogLevel.fatal: '💀',
  },
);
```

## Advanced Usage

### Custom Object Formatting

```dart
class User {
  final int id;
  final String name;
  final String email;
  
  User(this.id, this.name, this.email);
  
  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}

class CustomPrettyPrinter extends PrettyStructuredPrinter {
  @override
  String formatData(dynamic data) {
    if (data is User) {
      return 'User:\n' +
             '  id: ${data.id}\n' +
             '  name: ${data.name}\n' +
             '  email: ${data.email}';
    }
    return super.formatData(data);
  }
}

// Usage
final user = User(123, 'John Doe', 'john@example.com');
logger.i('User data', data: user);
```

### Custom JSON Serialization

```dart
class CustomPrettyPrinter extends PrettyStructuredPrinter {
  @override
  String toJson(dynamic data) {
    if (data is DateTime) {
      return '"${data.toIso8601String()}"';
    }
    if (data is Duration) {
      return '"${data.inMilliseconds}ms"';
    }
    return super.toJson(data);
  }
}
```

### Custom Error Formatting

```dart
class CustomPrettyPrinter extends PrettyStructuredPrinter {
  @override
  String formatError(LogEvent event) {
    if (event.error == null) return '';
    
    final buffer = StringBuffer();
    
    // Custom error formatting
    buffer.writeln('🚨 ${event.error.runtimeType}');
    buffer.writeln('   ${event.error}');
    
    // Custom stack trace formatting
    if (event.stackTrace != null) {
      buffer.writeln('Stack Trace:');
      final lines = event.stackTrace.toString().split('\n');
      for (var i = 0; i < math.min(5, lines.length); i++) {
        buffer.writeln('   ${lines[i]}');
      }
      if (lines.length > 5) {
        buffer.writeln('   ... ${lines.length - 5} more');
      }
    }
    
    return buffer.toString();
  }
}
```

## Best Practices

1. **Development Use**: Use `PrettyStructuredPrinter` in development for better readability.
2. **Performance**: For production, consider using `FlatStructuredPrinter` for better performance.
3. **Sensitive Data**: Be cautious with sensitive information in development logs.
4. **Customization**: Extend the printer to match your team's preferred style.

## Example Configurations

### Development Configuration

```dart
final printer = PrettyStructuredPrinter(
  colors: !kReleaseMode,
  printTime: true,
  printLevel: true,
  printTag: true,
  printEmojis: !kReleaseMode,
  lineLength: 100,
  indent: '  ',
  errorMethodCount: 5,
  excludeBox: [
    'package:stack_trace',
    'dart:async',
    'package:flutter/',
  ],
  noBoxingByDefault: false,
);
```

### Test Configuration

```dart
final printer = PrettyStructuredPrinter(
  colors: false,
  printTime: false,
  printLevel: true,
  printTag: false,
  printEmojis: false,
  lineLength: 80,
  indent: '  ',
  errorMethodCount: 0, // Don't show stack traces in tests
  noBoxingByDefault: true,
);
```

### Custom Theme

```dart
class CustomTheme extends PrettyPrinterTheme {
  @override
  AnsiColor getColor(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => AnsiColor.fg(8),     // Gray
      LogLevel.debug => AnsiColor.fg(14),     // Cyan
      LogLevel.info => AnsiColor.fg(12),      // Blue
      LogLevel.warning => AnsiColor.fg(11),   // Yellow
      LogLevel.error => AnsiColor.fg(9),      // Red
      LogLevel.fatal => AnsiColor.fg(196),    // Bright red
    };
  }
  
  @override
  String getEmoji(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => '🔍',
      LogLevel.debug => '🐛',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '❌',
      LogLevel.fatal => '💀',
    };
  }
  
  @override
  String formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}.${time.millisecond.toString().padLeft(3, '0')}';
  }
}

// Usage
final printer = PrettyStructuredPrinter(
  theme: CustomTheme(),
);
```

### Logging to File with Rotation

```dart
class RotatingFilePrinter extends LogPrinter {
  final String path;
  final int maxSize;
  final PrettyStructuredPrinter _printer;
  
  RotatingFilePrinter({
    required this.path,
    this.maxSize = 10 * 1024 * 1024, // 10MB
  }) : _printer = PrettyStructuredPrinter(
          colors: false,
          printEmojis: false,
        );
  
  @override
  void log(LogEvent event) {
    _rotateIfNeeded();
    final output = _printer.format(event);
    File(path).writeAsStringSync('$output\n', mode: FileMode.append);
  }
  
  void _rotateIfNeeded() {
    final file = File(path);
    if (!file.existsSync()) return;
    
    final length = file.lengthSync();
    if (length < maxSize) return;
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFile = File('$path.$timestamp');
    
    // Rename current file
    file.renameSync(backupFile.path);
    
    // Start a new log file
    file.writeAsStringSync('');
  }
  
  @override
  void dispose() {
    _printer.dispose();
  }
}
```
