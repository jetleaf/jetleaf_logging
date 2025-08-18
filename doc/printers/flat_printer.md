# Flat Printer

The `FlatPrinter` is a minimal implementation of `LogPrinter` that outputs log messages in a single line, making it ideal for machine-readable logs and production environments where log volume is high.

## Features

- Single-line output for each log message
- Configurable field separators
- Minimal overhead
- Thread-safe
- Ideal for log aggregation systems

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a flat printer with default settings
  final printer = FlatPrinter();
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log messages
  logger.i('User logged in', data: {'userId': 123});
  logger.e('Failed to connect', error: 'Connection timeout');
}
```

## Output Format

Default output format:
```
TIMESTAMP LEVEL [TAG] MESSAGE [DATA] [ERROR]
```

Example:
```
2023-01-01T12:00:00.000Z INFO [App] User logged in userId=123
2023-01-01T12:00:01.000Z ERROR [App] Failed to connect Connection timeout
```

## Configuration Options

### Basic Configuration

```dart
final printer = FlatPrinter(
  printTime: true,      // Include timestamps
  printLevel: true,     // Include log level
  printTag: true,       // Include log tag
  printEmojis: false,   // Disable emojis
  separator: ' | ',     // Field separator
  keyValueSeparator: '=', // Separator for key-value pairs
  includeError: true,   // Include error information
  includeStack: false,  // Don't include stack traces by default
);
```

### Custom Field Order

```dart
final printer = FlatPrinter(
  fieldOrder: [
    FlatField.time,
    FlatField.level,
    FlatField.tag,
    FlatField.message,
    FlatField.data,
    FlatField.error,
  ],
);
```

### Custom Formatting

```dart
class CustomFlatPrinter extends FlatPrinter {
  @override
  String format(LogEvent event) {
    final buffer = StringBuffer();
    
    // Custom time format
    final time = event.time.toUtc().toIso8601String();
    buffer.write('$time ');
    
    // Uppercase level
    final level = event.level.name.toUpperCase().padRight(5);
    buffer.write('$level ');
    
    // Message in quotes
    buffer.write('"${event.message}"');
    
    // Add data as JSON if present
    if (event.data != null) {
      buffer.write(' data=${_formatData(event.data)}');
    }
    
    // Add error if present
    if (event.error != null) {
      buffer.write(' error="${event.error}"');
    }
    
    return buffer.toString();
  }
  
  String _formatData(dynamic data) {
    if (data is Map || data is List) {
      return JsonEncoder.withIndent('  ').convert(data);
    }
    return data.toString();
  }
}
```

## Best Practices

1. **Production Use**: `FlatPrinter` is optimized for production environments.
2. **Log Aggregation**: Use with log aggregation systems like ELK, Splunk, or CloudWatch.
3. **Structured Logging**: Include structured data in the `data` field for better querying.
4. **Performance**: For high-volume logging, disable unnecessary fields.

## Advanced Usage

### Custom Field Formatters

```dart
final printer = FlatPrinter(
  fieldFormatters: {
    FlatField.time: (event) => event.time.millisecondsSinceEpoch.toString(),
    FlatField.level: (event) => event.level.name[0].toUpperCase(),
    FlatField.message: (event) => event.message.replaceAll('\n', '\\n'),
  },
);
```

### Log Rotation

```dart
class RotatingFlatPrinter extends FlatPrinter {
  final String basePath;
  final int maxSize;
  final int maxFiles;
  
  RotatingFlatPrinter({
    required this.basePath,
    this.maxSize = 10 * 1024 * 1024, // 10MB
    this.maxFiles = 5,
  });
  
  @override
  void log(LogEvent event) {
    _rotateIfNeeded();
    super.log(event);
  }
  
  void _rotateIfNeeded() async {
    final file = File('$basePath.log');
    if (await file.exists() && await file.length() > maxSize) {
      // Rotate files
      for (var i = maxFiles - 1; i > 0; i--) {
        final oldFile = File('$basePath.${i}.log');
        if (await oldFile.exists()) {
          await oldFile.rename('$basePath.${i + 1}.log');
        }
      }
      await file.rename('$basePath.1.log');
    }
  }
}
```

### Integration with Logging Systems

```dart
class CloudLoggingPrinter extends FlatPrinter {
  final CloudLoggingClient _client;
  
  CloudLoggingPrinter(this._client);
  
  @override
  void log(LogEvent event) {
    final entry = LogEntry(
      timestamp: event.time,
      severity: _mapLevel(event.level),
      jsonPayload: {
        'message': event.message,
        'data': event.data,
        'error': event.error?.toString(),
        'tag': event.tag,
      },
    );
    
    _client.writeLogEntries([entry]);
  }
  
  LogSeverity _mapLevel(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => LogSeverity.debug,
      LogLevel.debug => LogSeverity.debug,
      LogLevel.info => LogSeverity.info,
      LogLevel.warning => LogSeverity.warning,
      LogLevel.error => LogSeverity.error,
      LogLevel.fatal => LogSeverity.critical,
    };
  }
}
```

### Performance Optimization

```dart
class BufferedFlatPrinter extends FlatPrinter {
  final List<LogEvent> _buffer = [];
  final int _batchSize;
  final Duration _maxDelay;
  DateTime? _lastFlush;
  
  BufferedFlatPrinter({
    required this._batchSize,
    required this._maxDelay,
  });
  
  @override
  void log(LogEvent event) {
    _buffer.add(event);
    _scheduleFlush();
  }
  
  void _scheduleFlush() {
    if (_buffer.length >= _batchSize) {
      _flush();
    } else if (_lastFlush == null || 
        DateTime.now().difference(_lastFlush!) > _maxDelay) {
      _flush();
    }
  }
  
  void _flush() {
    if (_buffer.isEmpty) return;
    
    // Process batch
    for (final event in _buffer) {
      super.log(event);
    }
    
    _buffer.clear();
    _lastFlush = DateTime.now();
  }
  
  @override
  void dispose() {
    _flush();
    super.dispose();
  }
}
```
