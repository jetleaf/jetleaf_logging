# Log Level

The `LogLevel` enum defines the severity levels for log messages. Each level has an associated priority, with higher values indicating more severe events.

## Levels

| Level | Priority | Description |
|-------|----------|-------------|
| `verbose` | 0 | Detailed debug information |
| `debug` | 10 | Debug-level information |
| `info` | 20 | General information |
| `warning` | 30 | Warnings about potential issues |
| `error` | 40 | Errors that need attention |
| `fatal` | 50 | Critical errors causing failure |
| `off` | 1000 | Special level to disable all logging |

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  final logger = Logger();
  
  // Log at different levels
  logger.v('Verbose information');
  logger.d('Debug information');
  logger.i('General information');
  logger.w('Warning message');
  logger.e('Error message');
  logger.f('Fatal error');
  
  // Check log level
  if (logger.isLoggable(LogLevel.debug)) {
    // Expensive operation only for debug logs
    logger.d('Debug data: ${expensiveOperation()}');
  }
}
```

## Comparing Levels

You can compare log levels using the standard comparison operators:

```dart
final level = LogLevel.warning;

if (level >= LogLevel.warning) {
  // Will match warning, error, and fatal
  print('This is an important message');
}

// Get all levels at or above info
final importantLevels = LogLevel.values.where(
  (level) => level >= LogLevel.info,
);
```

## Best Practices

1. **Choose appropriate levels**:
   - Use `verbose` for detailed debugging
   - Use `debug` for general debugging
   - Use `info` for normal operational messages
   - Use `warning` for handled exceptions
   - Use `error` for unhandled exceptions
   - Use `fatal` for critical failures

2. **Performance considerations**:
   ```dart
   // Good: Only create message if level is enabled
   if (logger.isLoggable(LogLevel.debug)) {
     logger.d('Debug data: ${expensiveOperation()}');
   }
   
   // Bad: Expensive operation runs regardless of log level
   logger.d('Debug data: ${expensiveOperation()}');
   ```

## Custom Levels

You can create custom log levels by extending the `LogLevel` class:

```dart
class CustomLevels {
  static const audit = LogLevel('AUDIT', 25);
  static const security = LogLevel('SECURITY', 45);
}

// Usage
logger.log(CustomLevels.audit, 'Security audit completed');
logger.log(CustomLevels.security, 'Unauthorized access attempt');
```

## Level Filters

Filter logs based on level:

```dart
// Only show warnings and above
Logger.configure(LogConfig(level: LogLevel.warning));

// In a specific part of the app
final networkLogger = Logger()..level = LogLevel.debug;
```

## Level Hierarchy

```
off (1000)
└── fatal (50)
    └── error (40)
        └── warning (30)
            └── info (20)
                └── debug (10)
                    └── verbose (0)
```

When you set a log level, all levels with equal or higher priority will be included.
