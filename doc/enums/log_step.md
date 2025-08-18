# Log Step

The `LogStep` enum represents different steps or phases in the logging process. It's used to track the progression of log events through the logging pipeline.

## Steps

| Value | Description |
|-------|-------------|
| `created` | The log record was just created |
| `filtered` | The log record passed through filters |
| `formatted` | The log message was formatted |
| `output` | The log was written to output |
| `dispatched` | The log was dispatched to all listeners |
| `completed` | The log processing is complete |

## Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

class LogProcessor {
  void process(LogRecord record) {
    // Log when processing starts
    record.step = LogStep.filtered;
    
    try {
      // Process the log record
      record.step = LogStep.formatted;
      
      // Output the log
      record.step = LogStep.output;
      
      // Mark as completed
      record.step = LogStep.completed;
    } catch (e) {
      // Handle error during processing
      record.error = e;
      record.step = LogStep.completed;
      rethrow;
    }
  }
}
```

## Best Practices

1. **Use for debugging**: Track where in the pipeline a log record is:
   ```dart
   void handleLog(LogRecord record) {
     switch (record.step) {
       case LogStep.created:
         // Handle new log
         break;
       case LogStep.filtered:
         // Handle filtered log
         break;
       // ... other cases
     }
   }
   ```

2. **Add custom steps**: Extend if needed for your application:
   ```dart
   extension CustomLogStep on LogStep {
     static const LogStep enriched = LogStep('enriched', 15);
     static const LogStep validated = LogStep('validated', 25);
   }
   ```

## Step Order

Logs typically progress through these steps:

1. `created` → 2. `filtered` → 3. `formatted` → 4. `output` → 5. `dispatched` → 6. `completed`

## Integration with Listeners

Listeners can use the step to implement conditional logic:

```dart
class StepAwareListener extends LoggingListener {
  @override
  void onLog(LogEvent event) {
    if (event.step == LogStep.formatted) {
      // Only process after formatting
      print('Formatted message: ${event.message}');
    }
  }
}
```
