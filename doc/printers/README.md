# Log Printers

This directory contains documentation for the various log printer implementations available in the JetLeaf Logging library. Printers are responsible for formatting and outputting log messages.

## Available Printers

### Base Printers
- [Simple Printer](./simple_printer.md) - Basic text output
- [Pretty Printer](./pretty_printer.md) - Formatted, colorful output
- [Flat Printer](./flat_printer.md) - Single-line log messages
- [FMT Printer](./fmt_printer.md) - Custom format strings
- [Hybrid Printer](./hybrid_printer.md) - Combines multiple printers
- [Prefix Printer](./prefix_printer.md) - Adds prefixes to log messages

### Structured Printers
- [Flat Structured Printer](./flat_structured_printer.md) - Single-line structured logs
- [Pretty Structured Printer](./pretty_structured_printer.md) - Formatted structured logs

## Choosing a Printer

Select a printer based on your needs:

- **Development**: Use `PrettyPrinter` for easy-to-read, colorful output
- **Production**: Use `FlatPrinter` or `FlatStructuredPrinter` for machine-readable logs
- **Custom Formatting**: Use `FmtPrinter` for complete control over log format
- **Multiple Outputs**: Use `HybridPrinter` to send logs to different destinations

## Creating Custom Printers

Extend the `LogPrinter` class to create custom printers:

```dart
class CustomPrinter extends LogPrinter {
  @override
  void log(LogEvent event) {
    // Custom formatting logic here
    final time = event.time.toIso8601String();
    final level = event.level.name.toUpperCase();
    final message = event.message;
    
    print('[$time] [$level] $message');
  }
}
```

## Common Patterns

### Chaining Printers

```dart
final printer = PrefixPrinter(
  PrettyPrinter(
    colors: true,
    printTime: true,
  ),
  prefix: (event) => '[${event.tag ?? 'APP'}]',
);
```

### Conditional Printing

```dart
final printer = ConditionalPrinter(
  (event) => event.level >= LogLevel.warning,
  printer: PrettyPrinter(),
);
```

### Custom Formatting

```dart
final printer = FmtPrinter(
  (event) => '${event.time} | ${event.level.name} | ${event.message}',
);
```

## Best Practices

1. **Performance**: Keep printer implementations efficient
2. **Thread Safety**: Make printers thread-safe if they maintain state
3. **Configuration**: Allow customization through constructor parameters
4. **Error Handling**: Handle formatting errors gracefully
5. **Documentation**: Document any special formatting options or requirements
