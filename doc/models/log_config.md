# Log Configuration

The `LogConfig` class holds the configuration settings for the logging system. It allows you to customize various aspects of logging behavior.

## Configuration Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `level` | `LogLevel` | `LogLevel.info` | Minimum log level to output |
| `colors` | `bool` | `false` | Enable/disable colored output |
| `printTime` | `bool` | `false` | Whether to include timestamps in logs |
| `printEmojis` | `bool` | `false` | Whether to include emojis in logs |
| `tag` | `String?` | `null` | Default tag for all logs |
| `stackTraceLevel` | `LogLevel` | `LogLevel.error` | Minimum level to include stack traces |
| `stackTracePrefix` | `String` | `'STACKTRACE:'` | Prefix for stack trace lines |

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Configure logging
  final config = LogConfig(
    level: LogLevel.debug,
    colors: true,
    printTime: true,
    printEmojis: true,
    tag: 'MyApp',
    stackTraceLevel: LogLevel.warning,
  );
  
  // Apply configuration
  Logger.configure(config);
  
  // Or when using the factory
  LogFactory.instance.configure(config);
}
```

## Best Practices

1. **Environment-specific configuration**:
   ```dart
   LogConfig createConfig() {
     final isProduction = bool.fromEnvironment('dart.vm.product');
     
     return LogConfig(
       level: isProduction ? LogLevel.warning : LogLevel.verbose,
       colors: !isProduction,
       printTime: true,
       printEmojis: !isProduction,
     );
   }
   ```

2. **Customize stack trace behavior**:
   ```dart
   // Only show stack traces for errors in production
   final config = LogConfig(
     stackTraceLevel: kReleaseMode ? LogLevel.error : LogLevel.warning,
     stackTracePrefix: '>>> ',
   );
   ```

## Advanced Configuration

### Custom Formatters

You can customize how different parts of the log message are formatted:

```dart
final config = LogConfig(
  level: LogLevel.debug,
  timeFormatter: (time) => '[${time.hour}:${time.minute}:${time.second}]',
  levelFormatter: (level) => level.name.padRight(5).toUpperCase(),
  tagFormatter: (tag) => tag != null ? '[$tag]' : '',
);
```

### Conditional Formatting

Use the `shouldPrint` callback to conditionally print logs:

```dart
final config = LogConfig(
  level: LogLevel.verbose,
  shouldPrint: (event) {
    // Only print logs from specific components
    return event.tag?.startsWith('network.') ?? false;
  },
);
```

### Custom Log Levels

Extend `LogLevel` to add custom log levels:

```dart
class CustomLogLevels {
  static const LogLevel audit = LogLevel('AUDIT', 35);
  static const LogLevel security = LogLevel('SECURITY', 45);
}

// Usage
logger.log(CustomLogLevels.audit, 'User accessed admin panel');
```

## Thread Safety

`LogConfig` is immutable, making it thread-safe. When you need to update the configuration, create a new instance:

```dart
// Update configuration
final newConfig = currentConfig.copyWith(level: LogLevel.warning);
Logger.configure(newConfig);
```

This ensures that logging remains consistent even when the configuration changes during runtime.
