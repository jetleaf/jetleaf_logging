# JetLeaf Logging

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful, extensible logging library for Dart applications that provides flexible logging capabilities with support for ANSI colors, custom formatting, and multiple output formats.

## Features

- 🎨 **ANSI Color Support**: Beautiful, color-coded output for better log readability
- 🖨️ **Multiple Printer Types**: Choose from various log printers (simple, pretty, flat, structured, etc.)
- 📊 **Log Levels**: Built-in support for different log levels (debug, info, warning, error, etc.)
- 🧩 **Extensible**: Easily create custom log printers and formatters
- 🏗️ **Structured Logging**: Support for structured logging with metadata
- 🔍 **Stack Trace Parsing**: Built-in stack trace parsing for better debugging
- ⚡ **High Performance**: Optimized for performance in production environments

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  jetleaf_logging: ^1.0.0
```

## Quick Start

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // Create a logger
  final logger = Logger();
  
  // Log messages at different levels
  logger.d('Debug message');
  logger.i('Info message');
  logger.w('Warning message');
  logger.e('Error message', error: 'Something went wrong');
  
  // Log with custom printer
  final prettyPrinter = PrettyPrinter(
    colors: true,
    printEmojis: true,
  );
  
  logger.d('This will be pretty printed', printer: prettyPrinter);
}
```

## Documentation

For detailed documentation, see the [docs](./doc/) directory.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Developed with ❤️ by the JetLeaf Team
