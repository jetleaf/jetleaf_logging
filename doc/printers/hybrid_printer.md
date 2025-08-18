# Hybrid Printer

The `HybridPrinter` is a powerful implementation of `LogPrinter` that combines multiple printers and routes log events based on their level or other criteria. This allows for different formatting and output destinations based on the log level or other event properties.

## Features

- Combine multiple printers
- Route logs based on level, tag, or custom conditions
- Fallback to a default printer
- Debug-specific formatting
- Thread-safe

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create individual printers
  final prettyPrinter = PrettyPrinter(
    colors: true,
    printEmojis: true,
  );
  
  final simplePrinter = SimplePrinter(
    printTime: true,
    printLevel: true,
  );
  
  // Create a hybrid printer
  final printer = HybridPrinter(
    prettyPrinter,          // Default printer
    debug: prettyPrinter,   // Use pretty printer for debug logs
    error: simplePrinter,   // Use simple printer for errors
  );
  
  // Create a logger with the hybrid printer
  final logger = Logger(printer: printer);
  
  // Log messages will be routed to the appropriate printer
  logger.d('Debug message');    // Uses prettyPrinter
  logger.i('Info message');     // Uses prettyPrinter (default)
  logger.e('Error message');    // Uses simplePrinter
}
```

## Configuration Options

### Printer Selection

```dart
final printer = HybridPrinter(
  prettyPrinter,          // Default printer
  verbose: prettyPrinter, // Specific printer for verbose logs
  debug: prettyPrinter,   // Specific printer for debug logs
  info: simplePrinter,    // Specific printer for info logs
  warning: simplePrinter, // Specific printer for warning logs
  error: simplePrinter,   // Specific printer for error logs
  fatal: simplePrinter,   // Specific printer for fatal logs
  secondary: null,        // Secondary printer (all logs)
  filter: null,           // Custom filter function
);
```

### Custom Routing

```dart
final printer = HybridPrinter(
  defaultPrinter,
  filter: (event) {
    // Route based on tag
    if (event.tag == 'network') {
      return networkPrinter;
    }
    
    // Route based on message content
    if (event.message.contains('error', true)) {
      return errorPrinter;
    }
    
    // Use default printer
    return null;
  },
);
```

### Multiple Printers

```dart
// Create a printer that logs to both console and file
final printer = HybridPrinter.multiple([
  PrettyPrinter(colors: true),
  RotatingFilePrinter('app.log'),
]);
```

## Advanced Usage

### Conditional Logging

```dart
final printer = HybridPrinter.conditional(
  condition: (event) => event.level >= LogLevel.warning,
  ifTrue: warningPrinter,
  ifFalse: debugPrinter,
);
```

### Tag-Based Routing

```dart
final printer = HybridPrinter(
  defaultPrinter,
  filter: (event) {
    switch (event.tag) {
      case 'network':
        return networkPrinter;
      case 'database':
        return databasePrinter;
      case 'auth':
        return authPrinter;
      default:
        return null; // Use default printer
    }
  },
);
```

### Performance-Sensitive Logging

```dart
final printer = HybridPrinter.performanceAware(
  defaultPrinter: simplePrinter,
  debugPrinter: prettyPrinter,
  isDebugMode: !kReleaseMode,
);
```

## Best Practices

1. **Performance**: Use simpler printers for high-volume logs in production.
2. **Readability**: Use more detailed printers for development and debugging.
3. **Consistency**: Maintain consistent formats across different log levels.
4. **Error Handling**: Ensure critical errors are always logged, even if other logs are filtered.

## Example Configurations

### Development vs Production

```dart
Logger createLogger({bool isProduction = false}) {
  final prettyPrinter = PrettyPrinter(
    colors: !isProduction,
    printEmojis: !isProduction,
    printTime: true,
  );
  
  final jsonPrinter = JsonPrinter();
  
  return Logger(
    printer: isProduction 
        ? jsonPrinter 
        : prettyPrinter,
  );
}
```

### Multi-Destination Logging

```dart
final printer = HybridPrinter.multiple([
  // Console output
  PrettyPrinter(colors: true),
  
  // File output
  RotatingFilePrinter(
    'app.log',
    maxSize: 10 * 1024 * 1024, // 10MB
    maxFiles: 5,
  ),
  
  // Remote logging for errors
  HybridPrinter.conditional(
    condition: (event) => event.level >= LogLevel.error,
    ifTrue: RemoteLogPrinter('https://logs.example.com/api'),
  ),
]);
```

### Environment-Specific Formatting

```dart
final printer = HybridPrinter(
  // Default printer for production
  SimplePrinter(printTime: true),
  
  // Override for development
  debug: PrettyPrinter(
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
  
  // Override for tests
  filter: (event) {
    if (Platform.environment['TEST'] == 'true') {
      return TestPrinter();
    }
    return null;
  },
);
```

### Rate-Limited Logging

```dart
class RateLimitedPrinter extends LogPrinter {
  final LogPrinter _delegate;
  final Duration _window;
  final int _maxLogsPerWindow;
  
  final Map<LogLevel, List<DateTime>> _logs = {};
  
  RateLimitedPrinter(
    this._delegate, {
    required Duration window,
    required int maxLogsPerWindow,
  }) : _window = window,
       _maxLogsPerWindow = maxLogsPerWindow;
  
  @override
  void log(LogEvent event) {
    final now = DateTime.now();
    final logs = _logs.putIfAbsent(event.level, () => []);
    
    // Remove old logs
    logs.removeWhere((time) => now.difference(time) > _window);
    
    if (logs.length < _maxLogsPerWindow) {
      _delegate.log(event);
      logs.add(now);
    } else if (logs.length == _maxLogsPerWindow) {
      _delegate.log(LogEvent(
        level: event.level,
        message: 'Log rate limit reached for level ${event.level}',
        time: now,
      ));
      logs.add(now);
    }
  }
}

// Usage
final printer = HybridPrinter(
  RateLimitedPrinter(
    SimplePrinter(),
    window: Duration(minutes: 1),
    maxLogsPerWindow: 100,
  ),
  error: SimplePrinter(), // No rate limiting for errors
);
```
