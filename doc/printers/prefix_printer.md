# Prefix Printer

The `PrefixPrinter` is a decorator implementation of `LogPrinter` that adds a prefix to log messages. It's useful for adding context to log messages, such as thread names, request IDs, or any other contextual information.

## Features

- Add dynamic prefixes to log messages
- Conditional prefixing
- Thread-safe
- Composable with other printers
- Lightweight wrapper

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a base printer
  final basePrinter = SimplePrinter();
  
  // Create a prefix printer
  final printer = PrefixPrinter(
    basePrinter,
    prefix: (event) => '[${event.time.second}] ',
  );
  
  // Create a logger with the printer
  final logger = Logger(printer: printer);
  
  // Log messages will include the prefix
  logger.i('Processing started');
  await Future.delayed(Duration(seconds: 1));
  logger.i('Processing completed');
}
```

## Output Example

```
[42] [INFO] Processing started
[43] [INFO] Processing completed
```

## Configuration Options

### Static Prefix

```dart
final printer = PrefixPrinter(
  SimplePrinter(),
  prefix: (event) => '[APP] ',
);
```

### Dynamic Prefix

```dart
final printer = PrefixPrinter(
  SimplePrinter(),
  prefix: (event) {
    final time = event.time;
    final thread = '${Isolate.current.hashCode}';
    return '[${time.hour}:${time.minute}:${time.second}] [$thread] ';
  },
);
```

### Conditional Prefixing

```dart
final printer = PrefixPrinter.conditional(
  SimplePrinter(),
  prefix: (event) => '[${event.tag ?? 'global'}] ',
  shouldAddPrefix: (event) => event.tag != null,
);
```

## Advanced Usage

### Request-Scoped Logging

```dart
class RequestLogger {
  final String requestId;
  late final Logger _logger;
  
  RequestLogger(this.requestId) {
    final basePrinter = SimplePrinter(printTime: true);
    
    _logger = Logger(
      printer: PrefixPrinter(
        basePrinter,
        prefix: (_) => '[$requestId] ',
      ),
    );
  }
  
  void log(String message) => _logger.i(message);
}

// Usage
final logger = RequestLogger('req-123');
logger.log('Processing request'); // Output: [req-123] [2023-01-01T12:00:00.000Z] [INFO] Processing request
```

### Thread/Isolate Context

```dart
class ThreadAwareLogger {
  static final _printers = <int, LogPrinter>{};
  
  static Logger get logger {
    final threadId = Isolate.current.hashCode;
    
    return Logger(
      printer: _printers.putIfAbsent(threadId, () {
        final basePrinter = SimplePrinter();
        
        return PrefixPrinter(
          basePrinter,
          prefix: (_) => '[Thread $threadId] ',
        );
      }),
    );
  }
}

// Usage in multiple isolates
void isolateEntry() {
  ThreadAwareLogger.logger.i('Logging from isolate');
}
```

### Performance Monitoring

```dart
class PerformanceLogger {
  final Stopwatch _stopwatch = Stopwatch()..start();
  
  Logger get logger {
    final elapsed = _stopwatch.elapsed;
    final prefix = '[${elapsed.inSeconds}.${(elapsed.inMilliseconds % 1000).toString().padLeft(3, '0')}s] ';
    
    return Logger(
      printer: PrefixPrinter(
        SimplePrinter(),
        prefix: (_) => prefix,
      ),
    );
  }
}

// Usage
final perf = PerformanceLogger();
perf.logger.i('Operation started');
await Future.delayed(Duration(milliseconds: 123));
perf.logger.i('Operation completed');
```

## Best Practices

1. **Keep Prefixes Short**: Avoid long prefixes that make logs harder to read.
2. **Be Consistent**: Use the same prefix format throughout your application.
3. **Include Context**: Add meaningful context like request IDs or user IDs.
4. **Performance**: Keep prefix generation efficient, especially for high-volume logs.

## Example Configurations

### Request Tracing

```dart
final printer = PrefixPrinter(
  PrettyPrinter(),
  prefix: (event) {
    final requestId = Zone.current[#requestId];
    return requestId != null ? '[$requestId] ' : '';
  },
);

// In request handler
void handleRequest(String requestId) {
  return runZoned(() {
    // All logs in this zone will include the request ID
    logger.i('Processing request');
    // ...
  }, zoneValues: {#requestId: requestId});
}
```

### Component-Based Logging

```dart
Logger createComponentLogger(String component) {
  return Logger(
    printer: PrefixPrinter(
      SimplePrinter(),
      prefix: (_) => '[$component] ',
    ),
  );
}

// Usage
final networkLogger = createComponentLogger('NETWORK');
final dbLogger = createComponentLogger('DATABASE');
```

### Multi-Line Logging

```dart
final printer = PrefixPrinter.multiLine(
  PrettyPrinter(),
  prefix: '| ',
  firstPrefix: '┌ ',
  lastPrefix: '└ ',
  nextPrefix: '| ',
);

// Usage
logger.i('''This is a multi-line
log message that will be
properly indented with
prefixes on each line''');
```

### Environment-Aware Prefixing

```dart
final printer = PrefixPrinter(
  SimplePrinter(),
  prefix: (event) {
    final env = Platform.environment['ENV'] ?? 'dev';
    final host = Platform.localHostname;
    return '[$env@$host] ';
  },
);
```

### Log Level Based Prefixing

```dart
final printer = PrefixPrinter.conditional(
  PrettyPrinter(),
  prefix: (event) {
    final emoji = {
      LogLevel.verbose: '🔍',
      LogLevel.debug: '🐛',
      LogLevel.info: 'ℹ️',
      LogLevel.warning: '⚠️',
      LogLevel.error: '❌',
      LogLevel.fatal: '💀',
    }[event.level]!;
    
    return '$emo� ';
  },
);
```
