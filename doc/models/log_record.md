# Log Record

The `LogRecord` class represents a single log entry in the logging system. It encapsulates all the information about a log event, including the message, timestamp, log level, and any associated metadata.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `message` | `String` | The log message |
| `level` | `LogLevel` | The severity level of the log |
| `time` | `DateTime` | When the log event occurred |
| `tag` | `String?` | Optional tag to categorize the log |
| `error` | `Object?` | Associated error/exception |
| `stackTrace` | `StackTrace?` | Stack trace when the log was created |
| `data` | `dynamic` | Additional structured data |

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a log record directly
  final record = LogRecord(
    message: 'User logged in',
    level: LogLevel.info,
    tag: 'auth',
    data: {'userId': 123, 'username': 'johndoe'},
  );
  
  // Log the record
  final logger = Logger();
  logger.logRecord(record);
  
  // Or create from an exception
  try {
    // Some code that might throw
  } catch (e, stackTrace) {
    final errorRecord = LogRecord.error(
      message: 'Failed to process request',
      error: e,
      stackTrace: stackTrace,
      tag: 'api',
    );
    logger.logRecord(errorRecord);
  }
}
```

## Factory Constructors

### `LogRecord.info`
Create an info-level log record.

### `LogRecord.debug`
Create a debug-level log record.

### `LogRecord.warning`
Create a warning-level log record.

### `LogRecord.error`
Create an error-level log record with optional error and stack trace.

### `LogRecord.fatal`
Create a fatal-level log record.

## Methods

### `copyWith({...})`
Create a copy of this log record with the given fields replaced.

### `toJson()`
Convert the log record to a JSON-serializable map.

### `toString()`
Get a string representation of the log record.

## Best Practices

1. **Use structured logging** with the `data` field:
   ```dart
   logger.i(
     'User action',
     data: {
       'action': 'login',
       'userId': user.id,
       'timestamp': DateTime.now().toIso8601String(),
     },
   );
   ```

2. **Include relevant context** with error logs:
   ```dart
   try {
     // Some operation
   } catch (e, stackTrace) {
     logger.e(
       'Operation failed',
       error: e,
       stackTrace: stackTrace,
       data: {
         'operation': 'processPayment',
         'userId': currentUser?.id,
         'retryCount': retryCount,
       },
     );
   }
   ```

## Advanced Usage

### Custom Log Records

Extend `LogRecord` to add custom fields:

```dart
class RequestLogRecord extends LogRecord {
  final String requestId;
  final String method;
  final String path;
  final int? statusCode;
  final Duration? duration;
  
  RequestLogRecord({
    required this.requestId,
    required this.method,
    required this.path,
    this.statusCode,
    this.duration,
    String? message,
    LogLevel level = LogLevel.info,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    dynamic data,
  }) : super(
          message: message ?? '$method $path',
          level: level,
          tag: tag,
          error: error,
          stackTrace: stackTrace,
          data: {
            'requestId': requestId,
            'method': method,
            'path': path,
            'statusCode': statusCode,
            'durationMs': duration?.inMilliseconds,
            if (data != null) ...data,
          },
        );
  
  // Add custom methods as needed
  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

// Usage
final record = RequestLogRecord(
  requestId: 'req_123',
  method: 'GET',
  path: '/api/users',
  statusCode: 200,
  duration: Duration(milliseconds: 150),
);
logger.logRecord(record);
```

### Log Record Processors

Create processors to modify log records before they're output:

```dart
abstract class LogRecordProcessor {
  LogRecord process(LogRecord record);
}

class RedactSensitiveDataProcessor implements LogRecordProcessor {
  final List<Pattern> sensitivePatterns = [
    RegExp(r'password=[^&]*'),
    RegExp(r'"password":"[^"]*"'),
    // Add more patterns as needed
  ];
  
  @override
  LogRecord process(LogRecord record) {
    var message = record.message;
    var data = record.data;
    
    // Redact sensitive data from message
    for (final pattern in sensitivePatterns) {
      message = message.replaceAll(pattern, '[REDACTED]');
    }
    
    // Redact sensitive data from structured data
    if (data is Map) {
      data = Map.from(data);
      for (final key in ['password', 'token', 'apiKey']) {
        if (data.containsKey(key)) {
          data[key] = '[REDACTED]';
        }
      }
    }
    
    return record.copyWith(
      message: message,
      data: data,
    );
  }
}

// Usage
final processor = RedactSensitiveDataProcessor();
final processedRecord = processor.process(record);
logger.logRecord(processedRecord);
```
