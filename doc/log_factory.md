# Log Factory

The `LogFactory` class is responsible for creating and managing logger instances. It implements the singleton pattern to ensure a single source of truth for logger configuration.

## Features

- Singleton instance access
- Centralized logger configuration
- Logger instance management
- Default logger retrieval

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Get the log factory instance
  final factory = LogFactory.instance;
  
  // Configure the default logger
  factory.configure(
    LogConfig(
      level: LogLevel.debug,
      colors: true,
    ),
  );
  
  // Get the default logger
  final logger = factory.getLogger();
  
  // Or get a named logger
  final networkLogger = factory.getLogger('network');
  
  // Log messages
  logger.i('Application started');
  networkLogger.d('Network request started');
}
```

## Methods

### `configure(LogConfig config)`
Configure the default logging settings that will be used for all new loggers.

### `Logger getLogger([String? name])`
Get a logger instance. If a name is provided, a named logger will be returned.
Named loggers can have different configurations than the default logger.

### `void dispose()`
Clean up resources used by the log factory. Call this when the application is shutting down.

## Best Practices

1. **Use named loggers** for different components of your application:
   ```dart
   final apiLogger = LogFactory.instance.getLogger('api');
   final dbLogger = LogFactory.instance.getLogger('database');
   final cacheLogger = LogFactory.instance.getLogger('cache');
   ```

2. **Configure log levels** appropriately for different environments:
   ```dart
   void setupLogging() {
     final config = LogConfig(
       level: kReleaseMode ? LogLevel.warning : LogLevel.verbose,
       colors: !kReleaseMode,
     );
     LogFactory.instance.configure(config);
   }
   ```

3. **Reuse logger instances** instead of creating new ones:
   ```dart
   // Good
   class UserService {
     static final _logger = LogFactory.instance.getLogger('UserService');
     
     Future<User> getUser(String id) async {
       _logger.d('Fetching user $id');
       // ...
     }
   }
   
   // Bad - creates a new logger on each call
   class BadUserService {
     Future<User> getUser(String id) async {
       LogFactory.instance.getLogger('UserService').d('Fetching user $id');
       // ...
     }
   }
   ```

## Advanced Usage

### Custom Logger Factories

You can extend `LogFactory` to create custom logger factories with specialized behavior:

```dart
class CustomLogFactory extends LogFactory {
  @override
  Logger createLogger(String? name) {
    // Create a custom logger with specific settings
    return CustomLogger(
      name: name,
      config: config,
      // ...
    );
  }
}

// Initialize with custom factory
void main() {
  LogFactory.instance = CustomLogFactory();
  // ...
}
```

### Logger Hierarchies

Named loggers can use dot notation to create hierarchies:

```dart
final appLogger = LogFactory.instance.getLogger('app');
final dbLogger = LogFactory.instance.getLogger('app.database');
final userLogger = LogFactory.instance.getLogger('app.database.user');
```

This allows for hierarchical configuration and filtering of log messages.
