# Log Type

The `LogType` enum categorizes log messages based on their purpose or the type of information they contain. This helps in filtering and processing different kinds of logs differently.

## Types

| Value | Description |
|-------|-------------|
| `message` | Regular log message |
| `metric` | Performance or business metrics |
| `audit` | Security or compliance audit logs |
| `request` | Incoming HTTP/API requests |
| `response` | Outgoing HTTP/API responses |
| `database` | Database queries and operations |
| `security` | Security-related events |
| `system` | System-level events |
| `custom` | Custom log type (use `subType` for more details) |

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  final logger = Logger();
  
  // Log different types of messages
  logger.i('User logged in', type: LogType.security);
  
  logger.d(
    'Database query executed',
    type: LogType.database,
    data: {
      'query': 'SELECT * FROM users',
      'duration': '150ms',
    },
  );
  
  // Custom type with subtype
  logger.i(
    'Cache miss',
    type: LogType.custom,
    subType: 'cache',
  );
}
```

## Best Practices

1. **Be consistent** with log types across your application
2. **Use custom types** for domain-specific logging needs
3. **Combine with log levels** for better filtering:
   ```dart
   void logApiError(String message, int statusCode) {
     logger.e(
       message,
       type: LogType.response,
       level: statusCode >= 500 ? LogLevel.error : LogLevel.warning,
       data: {'statusCode': statusCode},
     );
   }
   ```

## Custom Types

For domain-specific logging, extend with custom types:

```dart
class CustomLogTypes {
  static const payment = LogType.custom('payment');
  static const notification = LogType.custom('notification');
  static const workflow = LogType.custom('workflow');
}

// Usage
logger.i('Payment processed', type: CustomLogTypes.payment);
```

## Type-Specific Handlers

Process different log types differently:

```dart
class LogProcessor {
  void process(LogRecord record) {
    switch (record.type) {
      case LogType.metric:
        _processMetric(record);
        break;
      case LogType.security:
        _processSecurityEvent(record);
        break;
      // ... other types
    }
  }
  
  void _processMetric(LogRecord record) {
    // Send to metrics system
  }
  
  void _processSecurityEvent(LogRecord record) {
    // Send to SIEM system
  }
}
```

## Integration with Analytics

Use log types to feed different analytics systems:

```dart
class AnalyticsService {
  final Logger _logger;
  
  void trackEvent(String name, Map<String, dynamic> properties) {
    _logger.i(
      'Analytics event: $name',
      type: LogType.metric,
      data: properties,
    );
  }
  
  void trackError(dynamic error, StackTrace stackTrace, {String? context}) {
    _logger.e(
      context ?? 'Analytics error',
      error: error,
      stackTrace: stackTrace,
      type: LogType.metric,
    );
  }
}
```
