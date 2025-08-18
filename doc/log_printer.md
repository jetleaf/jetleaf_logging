# Log Printer

The `LogPrinter` abstract class defines the interface for formatting and printing log messages. It's the foundation for all printer implementations in the logging library.

## Features

- Abstract interface for log printing
- Support for custom formatting
- Chainable with other printers
- Thread-safe operations

## Built-in Printers

1. **SimplePrinter** - Basic text output
2. **PrettyPrinter** - Formatted, colorful output
3. **FlatPrinter** - Single-line log messages
4. **FmtPrinter** - Custom format strings
5. **HybridPrinter** - Combines multiple printers
6. **PrefixPrinter** - Adds prefixes to messages

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a simple printer
  final simplePrinter = SimplePrinter();
  
  // Create a pretty printer with colors
  final prettyPrinter = PrettyPrinter(
    colors: true,
    printEmojis: true,
    printTime: true,
  );
  
  // Create a hybrid printer that combines multiple printers
  final hybridPrinter = HybridPrinter(
    PrettyPrinter(colors: true),
    secondary: SimplePrinter(),
    debug: PrettyPrinter(colors: true, printEmojis: true),
  );
  
  // Use the printers with a logger
  final logger = Logger();
  
  // Simple printer (default)
  logger.i('This uses the default printer');
  
  // Custom printer for a single log
  logger.d('Debug message', printer: prettyPrinter);
  
  // Set default printer for all logs
  logger.printer = hybridPrinter;
  logger.w('This will use the hybrid printer');
}
```

## Implementing a Custom Printer

Create a custom printer by extending `LogPrinter`:

```dart
class CustomPrinter extends LogPrinter {
  @override
  void log(LogEvent event) {
    final time = DateTime.now().toIso8601String();
    final level = event.level.name.toUpperCase();
    final message = event.message;
    
    // Custom formatting
    print('[$time] [$level] $message');
    
    // Print exception if present
    if (event.error != null) {
      print('Error: ${event.error}');
    }
    
    // Print stack trace if available
    if (event.stackTrace != null) {
      print('Stack trace:\n${event.stackTrace}');
    }
  }
}

// Usage
final customPrinter = CustomPrinter();
logger.i('Custom formatted message', printer: customPrinter);
```

## Best Practices

1. **Choose the right printer** for your environment:
   - Use `PrettyPrinter` during development
   - Use `SimplePrinter` or `FlatPrinter` in production
   - Use `PrefixPrinter` to add context to log messages

2. **Chain printers** for complex formatting:
   ```dart
   final printer = PrefixPrinter(
     PrettyPrinter(colors: true),
     prefix: (event) => '[${event.level.name}]',
   );
   ```

3. **Consider performance** for high-volume logging:
   - Avoid expensive operations in custom printers
   - Use `debugPrint` for Flutter to avoid blocking the UI
   - Consider batching log messages in production

## Advanced Topics

### Custom Formatters

Create custom formatters for specific log fields:

```dart
class CustomTimeFormatter extends FieldFormatter<DateTime> {
  @override
  String format(DateTime time) {
    return '[${time.hour}:${time.minute}:${time.second}]';
  }
}

// Usage
final printer = PrettyPrinter(
  timeFormatter: CustomTimeFormatter(),
);
```

### Conditional Printing

Use `ConditionalPrinter` to control when logs are printed:

```dart
final printer = ConditionalPrinter(
  (event) => event.level >= LogLevel.warning, // Only print warnings and above
  printer: PrettyPrinter(),
);
```

### Log Batching

For high-throughput scenarios, batch log messages:

```dart
class BatchPrinter extends LogPrinter {
  final List<LogEvent> _buffer = [];
  final int batchSize;
  final LogPrinter _printer;
  
  BatchPrinter(this._printer, {this.batchSize = 10});
  
  @override
  void log(LogEvent event) {
    _buffer.add(event);
    if (_buffer.length >= batchSize) {
      _flush();
    }
  }
  
  void _flush() {
    if (_buffer.isEmpty) return;
    
    // Process batch
    for (final event in _buffer) {
      _printer.log(event);
    }
    
    _buffer.clear();
  }
  
  @override
  void dispose() {
    _flush();
    _printer.dispose();
  }
}
```
