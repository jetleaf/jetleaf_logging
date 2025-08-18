# Flat Structured Printer

The `FlatStructuredPrinter` is an implementation of `LogPrinter` that outputs logs in a structured, machine-readable format while maintaining a flat, single-line output. It's ideal for production environments where logs need to be processed by log aggregation systems.

## Features

- Single-line, structured JSON output
- Configurable field inclusion
- Custom field mapping
- Thread-safe
- Efficient serialization

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a flat structured printer
  final printer = FlatStructuredPrinter();
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log structured data
  logger.i('User logged in', data: {
    'userId': 123,
    'email': 'user@example.com',
    'ip': '192.168.1.1',
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

## Output Format

Default output is a single-line JSON object:

```json
{"time":"2023-01-01T12:00:00.000Z","level":"INFO","message":"User logged in","userId":123,"email":"user@example.com","ip":"192.168.1.1"}
{"time":"2023-01-01T12:00:01.000Z","level":"ERROR","message":"Operation failed","error":"Exception: Invalid operation","stackTrace":"...","attempt":3}
```

## Configuration Options

### Basic Configuration

```dart
final printer = FlatStructuredPrinter(
  includeTime: true,          // Include timestamp
  includeLevel: true,         // Include log level
  includeMessage: true,       // Include log message
  includeError: true,         // Include error information
  includeStack: false,        // Include stack trace (only for errors)
  includeTag: true,           // Include log tag
  includeContext: true,       // Include context data
  flatten: true,              // Flatten nested objects
  maxDepth: 5,                // Maximum depth when flattening
  fieldRename: (name) => name, // Custom field name mapping
);
```

### Custom Field Mapping

```dart
final printer = FlatStructuredPrinter(
  fieldRename: (name) {
    // Convert camelCase to snake_case
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  },
);
```

### Custom JSON Encoder

```dart
final printer = FlatStructuredPrinter(
  toEncodable: (value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Enum) {
      return value.name;
    }
    return value.toString();
  },
);
```

## Advanced Usage

### Custom Field Processors

```dart
final printer = FlatStructuredPrinter(
  fieldProcessors: {
    'password': (value) => '***REDACTED***',
    'email': (email) => email.toString().replaceAll(
      RegExp(r'^(.{3}).*@(.{2}).*\..{2,}'),
      r'$1***@$2***.com'
    ),
  },
);
```

### Log Rotation with Compression

```dart
class CompressedFilePrinter extends LogPrinter {
  final String path;
  final int maxSize;
  final FlatStructuredPrinter _printer;
  
  CompressedFilePrinter({
    required this.path,
    this.maxSize = 10 * 1024 * 1024, // 10MB
  }) : _printer = FlatStructuredPrinter();
  
  @override
  void log(LogEvent event) {
    _rotateIfNeeded();
    final json = _printer.format(event);
    File(path).writeAsStringSync('$json\n', mode: FileMode.append);
  }
  
  void _rotateIfNeeded() async {
    final file = File(path);
    if (!await file.exists()) return;
    
    final length = await file.length();
    if (length < maxSize) return;
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final compressedFile = File('$path.$timestamp.gz');
    
    // Compress the current log file
    final input = file.openRead();
    final output = compressedFile.openWrite(
      mode: FileMode.writeOnly,
      encoding: utf8,
    );
    
    await output.addStream(input.transform(gzip.encoder));
    await output.close();
    
    // Clear the current log file
    await file.writeAsString('');
  }
  
  @override
  void dispose() {
    _printer.dispose();
  }
}
```

## Best Practices

1. **Field Naming**: Use consistent field names across your application.
2. **Sensitive Data**: Redact or hash sensitive information.
3. **Field Types**: Use appropriate JSON types (string, number, boolean).
4. **Performance**: For high-volume logging, keep the structure simple.
5. **Documentation**: Document your log schema for other teams.

## Example Configurations

### Production Configuration

```dart
final printer = FlatStructuredPrinter(
  includeTime: true,
  includeLevel: true,
  includeMessage: true,
  includeError: true,
  includeStack: true,
  includeTag: true,
  includeContext: true,
  flatten: true,
  maxDepth: 3,
  fieldRename: (name) => name.toLowerCase(),
  toEncodable: (value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Duration) return value.inMilliseconds;
    if (value is Enum) return value.name.toLowerCase();
    return value;
  },
  fieldProcessors: {
    'password': (_) => '***REDACTED***',
    'token': (_) => '***REDACTED***',
    'creditCard': (_) => '***REDACTED***',
    'email': (email) {
      final str = email.toString();
      final parts = str.split('@');
      if (parts.length != 2) return '***@***';
      return '${parts[0][0]}***@${parts[1].split('.')[0][0]}***.${parts[1].substring(parts[1].lastIndexOf('.') + 1)}';
    },
  },
);
```

### Cloud Logging Integration

```dart
class CloudLoggingPrinter extends LogPrinter {
  final LoggingService _cloudLogging;
  final FlatStructuredPrinter _printer;
  
  CloudLoggingPrinter(this._cloudLogging) 
      : _printer = FlatStructuredPrinter(
          includeTime: false, // Cloud logging adds its own timestamp
          includeLevel: false,
        );
  
  @override
  void log(LogEvent event) {
    final json = jsonDecode(_printer.format(event)) as Map<String, dynamic>;
    
    // Map to cloud logging format
    final entry = LogEntry(
      json['message'] as String? ?? '',
      severity: _mapLevel(event.level),
      jsonPayload: json,
    );
    
    _cloudLogging.write([entry]);
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
  
  @override
  void dispose() {
    _printer.dispose();
  }
}
```

### Request Context

```dart
class RequestAwarePrinter extends LogPrinter {
  final FlatStructuredPrinter _printer;
  
  RequestAwarePrinter() : _printer = FlatStructuredPrinter();
  
  @override
  void log(LogEvent event) {
    // Get request context from zone
    final requestId = Zone.current[#requestId];
    final userId = Zone.current[#userId];
    
    // Add context to the log event
    final eventWithContext = event.copyWith(
      data: {
        ...?event.data,
        if (requestId != null) 'requestId': requestId,
        if (userId != null) 'userId': userId,
      },
    );
    
    print(_printer.format(eventWithContext));
  }
  
  @override
  void dispose() {
    _printer.dispose();
  }
}

// Usage in request handler
void handleRequest(String requestId, String userId) {
  runZoned(() {
    logger.i('Request started');
    // ...
  }, zoneValues: {
    #requestId: requestId,
    #userId: userId,
  });
}
```
