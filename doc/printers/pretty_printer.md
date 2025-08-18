# Pretty Printer

The `PrettyPrinter` is a feature-rich implementation of `LogPrinter` that formats log messages with colors, emojis, and a clean layout. It's ideal for development environments where readability is important.

## Features

- Colorful output with syntax highlighting
- Emoji support for log levels
- Stack trace formatting
- Pretty-printed JSON for structured data
- Customizable colors and styles
- Thread-safe

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a pretty printer with default settings
  final printer = PrettyPrinter(
    colors: true,      // Enable colors
    printEmojis: true, // Enable emojis
    printTime: true,   // Show timestamps
  );
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log messages with different levels
  logger.v('Verbose message');
  logger.d('Debug information');
  logger.i('Informational message');
  logger.w('Warning message');
  logger.e('Error message', error: 'Something went wrong');
  
  // Log structured data
  logger.i('User data', data: {
    'id': 123,
    'name': 'John Doe',
    'email': 'john@example.com',
    'roles': ['admin', 'user'],
    'preferences': {
      'theme': 'dark',
      'notifications': true,
    },
  });
}
```

## Output Example

```
💡 12:00:00.000 [VERBOSE] Verbose message
🐛 12:00:01.000 [DEBUG] Debug information
ℹ️  12:00:02.000 [INFO] Informational message
⚠️  12:00:03.000 [WARNING] Warning message
❌ 12:00:04.000 [ERROR] Error message: Something went wrong
ℹ️  12:00:05.000 [INFO] User data
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "roles": [
    "admin",
    "user"
  ],
  "preferences": {
    "theme": "dark",
    "notifications": true
  }
}
```

## Configuration Options

### Colors and Styling

```dart
final printer = PrettyPrinter(
  colors: true,           // Enable/disable all colors
  colorFn: (level) => ..., // Custom color function
  printEmojis: true,      // Show/hide emojis
  emojiFn: (level) => ..., // Custom emoji function
  printTime: true,        // Show/hide timestamps
  timeFormat: 'HH:mm:ss.S', // Custom time format
  printLevel: true,       // Show/hide log level
  printTag: true,         // Show/hide log tag
  methodCount: 2,         // Number of method calls to show in stack traces
  errorMethodCount: 8,    // Number of method calls for error stack traces
  lineLength: 80,         // Wrap lines longer than this
  colors: {
    LogLevel.verbose: AnsiColor.fg(8),     // Gray
    LogLevel.debug: AnsiColor.fg(14),     // Cyan
    LogLevel.info: AnsiColor.fg(12),      // Blue
    LogLevel.warning: AnsiColor.fg(11),   // Yellow
    LogLevel.error: AnsiColor.fg(9),      // Red
    LogLevel.fatal: AnsiColor.fg(196),    // Bright red
  },
);
```

### Stack Trace Handling

```dart
final printer = PrettyPrinter(
  methodCount: 2,          // Number of method calls to show
  errorMethodCount: 8,     // Number of method calls for errors
  lineLength: 120,         // Wrap stack trace lines
  excludeBox: [            // Exclude specific boxes from stack traces
    'package:stack_trace',
    'dart:async',
  ],
  noBoxingByDefault: true, // Disable box drawing
);
```

## Custom Formatting

### Custom Line Format

```dart
class CustomPrettyPrinter extends PrettyPrinter {
  @override
  String format(LogEvent event) {
    final buffer = StringBuffer();
    
    // Custom time format
    final time = event.time;
    final timeStr = '[${time.hour}:${time.minute}:${time.second}.${time.millisecond}]';
    
    // Custom level format
    final levelStr = event.level.name.toUpperCase().substring(0, 1);
    
    // Build the log line
    buffer.write('$timeStr $levelStr ');
    
    // Add tag if present
    if (event.tag != null) {
      buffer.write('${event.tag} ');
    }
    
    // Add message
    buffer.write(event.message);
    
    // Add error if present
    if (event.error != null) {
      buffer.write(': ${event.error}');
    }
    
    return buffer.toString();
  }
}
```

### Custom Data Formatting

```dart
class CustomPrettyPrinter extends PrettyPrinter {
  @override
  String formatData(dynamic data) {
    if (data is Map) {
      // Custom map formatting
      return _formatMap(data);
    } else if (data is Iterable) {
      // Custom iterable formatting
      return _formatIterable(data);
    }
    return super.formatData(data);
  }
  
  String _formatMap(Map<dynamic, dynamic> map) {
    // Custom map formatting logic
    return map.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }
  
  String _formatIterable(Iterable iterable) {
    // Custom iterable formatting logic
    return iterable.join(' | ');
  }
}
```

## Best Practices

1. **Development Use**: `PrettyPrinter` is best suited for development environments due to its colorful output.

2. **Performance**: For production, consider using `SimplePrinter` or `FlatPrinter` for better performance.

3. **Customization**: Extend `PrettyPrinter` to match your team's preferred logging style.

4. **Error Handling**: Always include error and stack trace information for error logs.

## Advanced Usage

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
}

// Usage
final printer = PrettyPrinter(
  theme: CustomTheme(),
);
```

### Custom Stack Trace Filtering

```dart
class CustomPrettyPrinter extends PrettyPrinter {
  @override
  String formatStackFrame(StackFrame frame, {bool isError = false}) {
    // Skip frames from specific packages
    if (frame.package?.startsWith('package:flutter/') ?? false) {
      return '';
    }
    
    // Custom frame formatting
    return '${frame.library} - ${frame.function}:${frame.line}';
  }
}
```

### Logging to File

```dart
void logToFile(String message) {
  final file = File('app.log');
  final sink = file.openWrite(mode: FileMode.append);
  
  // Create a printer that writes to the file
  final printer = PrettyPrinter(
    colors: false,  // Disable colors for file output
    noBoxingByDefault: true,
    methodCount: 0,  // Don't include stack traces in file
    output: sink.writeln,
  );
  
  // Log the message
  printer.log(LogEvent(
    level: LogLevel.info,
    message: message,
    time: DateTime.now(),
  ));
  
  // Close the file
  sink.close();
}
```
