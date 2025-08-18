# Stack Trace Parser

The `StackTraceParser` class provides utilities for parsing and formatting stack traces in a more readable and useful way. It can extract relevant information from stack traces, filter out noise, and format them consistently.

## Features

- Parses raw stack traces into structured data
- Filters out framework and package-internal stack frames
- Formats stack traces for better readability
- Supports both synchronous and asynchronous stack traces
- Configurable frame filtering and formatting

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  try {
    // Code that might throw
    throw Exception('Something went wrong');
  } catch (e, stackTrace) {
    // Parse the stack trace
    final parsed = StackTraceParser.parse(stackTrace);
    
    // Print formatted stack trace
    print(parsed.toString());
    
    // Or access individual frames
    for (final frame in parsed.frames) {
      print('${frame.library} - ${frame.function}:${frame.line}');
    }
  }
}
```

## Stack Frame Structure

Each stack frame contains the following information:

| Property | Type | Description |
|----------|------|-------------|
| `library` | `String` | The library where the frame originated |
| `function` | `String` | The function name |
| `line` | `int` | The line number |
| `column` | `int?` | The column number (if available) |
| `isCore` | `bool` | Whether this is a core Dart library frame |
| `isPackage` | `bool` | Whether this is a package frame |
| `isApplication` | `bool` | Whether this is an application frame |

## Filtering Stack Frames

You can filter stack frames to show only relevant information:

```dart
final parser = StackTraceParser(
  // Include only frames from your application code
  include: (frame) => frame.isApplication,
  
  // Exclude specific packages
  exclude: (frame) => frame.library?.contains('package:flutter') ?? false,
);

final parsed = parser.parse(stackTrace);
```

## Custom Formatting

Customize how stack traces are formatted:

```dart
final parser = StackTraceParser(
  formatter: (frame) {
    // Custom format for each frame
    return '${frame.function} (${frame.library}:${frame.line})';
  },
);

// Or use the builder for more control
final parser = StackTraceParser.builder(
  (StringBuffer buffer, StackFrame frame, int index, int total) {
    // Custom formatting with builder
    buffer.write('[$index/$total] ');
    buffer.write(frame.function);
    buffer.write(' in ');
    buffer.write(frame.library);
    if (frame.line != null) {
      buffer.write(':${frame.line}');
    }
  },
);
```

## Best Practices

1. **Filter noise**: Always filter out framework and package-internal frames in production logs
2. **Include relevant context**: Keep enough context to debug issues
3. **Consider performance**: Parsing stack traces can be expensive, so do it only when needed
4. **Be consistent**: Use the same formatting throughout your application

## Advanced Usage

### Asynchronous Stack Traces

Handle asynchronous stack traces with `Chain`:

```dart
try {
  // Some async code
} catch (e, stackTrace) {
  final chain = Chain.forTrace(stackTrace);
  final parsed = StackTraceParser.parseChain(chain);
  print(parsed);
}
```

### Custom Frame Processing

Process frames before they're formatted:

```dart
final parser = StackTraceParser(
  processFrame: (frame) {
    // Modify or filter frames
    if (frame.function?.contains('_internal') ?? false) {
      return null; // Skip internal methods
    }
    return frame;
  },
);
```

### Integration with Logging

Use with the logging system:

```dart
void logError(dynamic error, StackTrace stackTrace) {
  final parsed = StackTraceParser.parse(stackTrace);
  
  logger.e(
    error.toString(),
    error: error,
    stackTrace: parsed.toString(),
    type: LogType.error,
  );
  
  // Or log just the relevant frames
  final relevantFrames = parsed.frames
      .where((f) => f.isApplication)
      .take(5);
      
  logger.d('Relevant frames:', data: relevantFrames);
}
```

### Custom Frame Filtering

Create custom filters for different environments:

```dart
class ProductionFrameFilter extends FrameFilter {
  @override
  bool shouldInclude(StackFrame frame) {
    // Only include application frames and important packages
    return frame.isApplication || 
           frame.library?.startsWith('package:important_package') == true;
  }
}

// Usage
final parser = StackTraceParser(
  filter: ProductionFrameFilter(),
);
```
