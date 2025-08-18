# FMT Printer

The `FmtPrinter` is a flexible implementation of `LogPrinter` that allows you to define custom log formats using format strings. It's ideal for when you need complete control over the log message format.

## Features

- Custom format strings
- Support for all log event properties
- Extensible with custom formatters
- Thread-safe
- High performance

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a FMT printer with a custom format
  final printer = FmtPrinter(
    format: '[{time}] [{level}] {message}',
  );
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log messages
  logger.i('User logged in');
  logger.e('Failed to connect', error: 'Connection timeout');
}
```

## Format String Syntax

The format string can contain placeholders enclosed in curly braces `{}`. The following placeholders are available:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{time}` | Log timestamp | 2023-01-01T12:00:00.000Z |
| `{level}` | Log level | INFO, ERROR, etc. |
| `{message}` | Log message | User logged in |
| `{tag}` | Log tag | AuthService |
| `{error}` | Error message | Connection timeout |
| `{data}` | Structured data | {"userId": 123} |
| `{stackTrace}` | Stack trace | #0 main (file:///example.dart:5:7) |

## Configuration Options

### Basic Configuration

```dart
final printer = FmtPrinter(
  format: '[{time}] [{level}] {message}',
  timeFormat: 'yyyy-MM-dd HH:mm:ss.SSS', // Custom time format
  levelFormat: (level) => level.name.substring(0, 4).toUpperCase(),
  errorFormat: (error) => error?.toString() ?? '',
  dataFormat: (data) => data?.toString() ?? '',
);
```

### Custom Formatters

```dart
final printer = FmtPrinter(
  format: '{time} | {level} | {message} | {custom}',
  formatters: {
    'custom': (event) => 'Custom: ${event.data?['userId'] ?? 'N/A'}',
  },
);
```

### Conditional Formatting

```dart
final printer = FmtPrinter(
  format: '[{time}] [{level}] {message}{error? | {}}',
  formatters: {
    'error?': (event) => event.error != null ? ' | Error: ${event.error}' : '',
  },
);
```

## Advanced Usage

### Custom Time Format

```dart
final printer = FmtPrinter(
  format: '[{time:HH:mm:ss.SSS}] {message}',
  timeFormatter: (time, format) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final millis = time.millisecond.toString().padLeft(3, '0');
    return '$hour:$minute:$second.$millis';
  },
);
```

### JSON Output

```dart
final printer = FmtPrinter(
  format: '{"time":"{time:yyyy-MM-ddTHH:mm:ss.SSSZ}","level":"{level}","message":"{message}"}' +
           '{error?,"error":"{error}"}{data?,"data":{data}}',
  dataFormat: (data) {
    if (data == null) return '';
    return const JsonEncoder().convert(data).replaceAll('"', '\\"');
  },
);
```

### Log Rotation

```dart
class RotatingFmtPrinter extends FmtPrinter {
  final String logFile;
  final int maxSize;
  final int maxFiles;
  
  RotatingFmtPrinter({
    required this.logFile,
    required this.maxSize,
    required this.maxFiles,
    String format = '[{time}] [{level}] {message}',
  }) : super(format: format);
  
  @override
  void log(LogEvent event) {
    _rotateIfNeeded();
    final entry = format(event);
    File(logFile).writeAsStringSync('$entry\n', mode: FileMode.append);
  }
  
  void _rotateIfNeeded() {
    final file = File(logFile);
    if (file.existsSync() && file.lengthSync() > maxSize) {
      // Rotate files
      for (var i = maxFiles - 1; i > 0; i--) {
        final oldFile = File('$logFile.$i');
        if (oldFile.existsSync()) {
          oldFile.renameSync('$logFile.${i + 1}');
        }
      }
      file.renameSync('$logFile.1');
    }
  }
}
```

## Best Practices

1. **Performance**: For high-volume logging, keep the format string simple.
2. **Readability**: Use consistent formatting across your application.
3. **Structured Logging**: Include structured data in a machine-readable format.
4. **Error Handling**: Always include error information when available.

## Example Configurations

### Production Format

```dart
final printer = FmtPrinter(
  format: '{time:yyyy-MM-dd HH:mm:ss.SSS} | {level} | {message}{error? | Error: {error}}',
  timeFormatter: (time, format) {
    return DateFormat(format).format(time.toUtc());
  },
);
```

### Development Format

```dart
final printer = FmtPrinter(
  format: '{time:HH:mm:ss.SSS} | {level:4} | {tag?[{tag}] }\x1B[36m{message}\x1B[0m{error? | \x1B[31m{error}\x1B[0m}',
  levelFormat: (level) {
    final emoji = {
      LogLevel.verbose: '🔍',
      LogLevel.debug: '🐛',
      LogLevel.info: 'ℹ️',
      LogLevel.warning: '⚠️',
      LogLevel.error: '❌',
      LogLevel.fatal: '💀',
    }[level];
    
    return '$emoji ${level.name.toUpperCase().padRight(5)}';
  },
);
```

### JSON Format

```dart
final printer = FmtPrinter(
  format: '{\n  "@timestamp": "{time:yyyy-MM-ddTHH:mm:ss.SSSZ}",\n  "level": "{level}",\n  "message": "{message}",\n  {error? "error": "{error}",\n  }\n  {data? "data": {data},\n  }\n  "logger": {"name": "{logger}", "tag": "{tag}"}\n}',
  dataFormat: (data) {
    if (data == null) return '';
    return const JsonEncoder.withIndent('  ').convert(data).replaceAll('"', '\\"');
  },
);
```

### Syslog Format

```dart
final printer = FmtPrinter(
  format: '<{priority}>{time:MMM dd HH:mm:ss} {hostname} {app}[{pid}]: {message}',
  formatters: {
    'priority': (event) {
      final facility = 16; // local0
      final severity = {
        LogLevel.verbose: 7, // debug
        LogLevel.debug: 7,   // debug
        LogLevel.info: 6,    // info
        LogLevel.warning: 4, // warning
        LogLevel.error: 3,   // error
        LogLevel.fatal: 2,   // critical
      }[event.level]!;
      
      return (facility * 8 + severity).toString();
    },
    'hostname': (_) => Platform.localHostname,
    'app': (_) => Platform.resolvedExecutable.split('/').last,
    'pid': (_) => ProcessInfo.currentRss.toString(),
  },
);
```
