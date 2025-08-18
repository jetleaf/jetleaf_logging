# Logging Listener

The `LoggingListener` abstract class provides a way to listen to log events across the application. It's useful for scenarios where you need to react to log events, such as sending them to a remote server, filtering, or aggregating logs.

## Features

- Listen to all log events in the application
- Filter log events based on level, tag, or other criteria
- React to log events in real-time
- Chain multiple listeners together

## Built-in Listeners

1. **ConsoleListener** - Outputs logs to the console
2. **FileListener** - Writes logs to a file
3. **MemoryListener** - Stores logs in memory
4. **NetworkListener** - Sends logs to a remote server

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a listener
  final consoleListener = ConsoleListener(
    printer: PrettyPrinter(colors: true),
    level: LogLevel.verbose,
  );
  
  // Create a file listener
  final fileListener = FileListener(
    file: File('app.log'),
    printer: SimplePrinter(),
    level: LogLevel.info,
  );
  
  // Create a composite listener
  final compositeListener = CompositeListener([
    consoleListener,
    fileListener,
  ]);
  
  // Register the listener
  Logger.addListener(compositeListener);
  
  // Now all logs will be sent to both console and file
  final logger = Logger();
  logger.i('This will be logged to both console and file');
  
  // Clean up when done
  Logger.removeListener(compositeListener);
  compositeListener.dispose();
}
```

## Implementing a Custom Listener

Create a custom listener by extending `LoggingListener`:

```dart
class CustomListener extends LoggingListener {
  final String _name;
  
  CustomListener({
    required String name,
    required LogLevel level,
  }) : _name = name, super(level: level);
  
  @override
  void onLog(LogEvent event) {
    if (!shouldLog(event)) return;
    
    // Custom handling of the log event
    print('[$_name] [${event.level.name}] ${event.message}');
    
    // You can access all event properties:
    // - event.time
    // - event.tag
    // - event.error
    // - event.stackTrace
    // - event.data
  }
  
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

// Usage
final customListener = CustomListener(name: 'custom', level: LogLevel.debug);
Logger.addListener(customListener);
```

## Best Practices

1. **Filter at the listener level** to improve performance:
   ```dart
   // Only process error logs
   final errorListener = ConsoleListener(
     printer: PrettyPrinter(),
     level: LogLevel.error,
     filter: (event) => event.level == LogLevel.error,
   );
   ```

2. **Use composite listeners** to group multiple listeners:
   ```dart
   final composite = CompositeListener([
     ConsoleListener(level: LogLevel.info),
     FileListener(file: File('app.log'), level: LogLevel.debug),
     CustomListener(level: LogLevel.warning),
   ]);
   ```

3. **Handle errors** in your listeners:
   ```dart
   @override
   void onLog(LogEvent event) {
     try {
       // Your logging logic
     } catch (e, stackTrace) {
       // Don't let listener errors crash the app
       print('Error in listener: $e\n$stackTrace');
     }
   }
   ```

## Advanced Usage

### Buffering Logs

Create a listener that buffers logs and flushes them periodically:

```dart
class BufferedListener extends LoggingListener {
  final List<LogEvent> _buffer = [];
  final Duration flushInterval;
  Timer? _timer;
  
  BufferedListener({
    required this.flushInterval,
    required LogLevel level,
  }) : super(level: level) {
    _startTimer();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(flushInterval, (_) => _flush());
  }
  
  @override
  void onLog(LogEvent event) {
    if (!shouldLog(event)) return;
    _buffer.add(event);
  }
  
  void _flush() {
    if (_buffer.isEmpty) return;
    
    // Process the buffered logs
    for (final event in _buffer) {
      // Your processing logic here
      print('${event.time} [${event.level.name}] ${event.message}');
    }
    
    _buffer.clear();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _flush(); // Flush any remaining logs
    super.dispose();
  }
}
```

### Conditional Logging

Create a listener that only logs under certain conditions:

```dart
class ConditionalListener extends LoggingListener {
  final bool Function(LogEvent) condition;
  final LogPrinter printer;
  
  ConditionalListener({
    required this.condition,
    required this.printer,
    required LogLevel level,
  }) : super(level: level);
  
  @override
  void onLog(LogEvent event) {
    if (!shouldLog(event) || !condition(event)) return;
    printer.log(event);
  }
}

// Usage: Only log messages containing 'important'
final listener = ConditionalListener(
  condition: (event) => event.message.contains('important'),
  printer: PrettyPrinter(),
  level: LogLevel.info,
);
```
