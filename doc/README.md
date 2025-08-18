# JetLeaf Logging Documentation

Welcome to the JetLeaf Logging documentation. This directory contains detailed documentation for all components of the logging library.

## Table of Contents

### Core Components
- [Logger](./logger.md) - The main logging interface
- [Log Factory](./log_factory.md) - Factory for creating loggers
- [Log Printer](./log_printer.md) - Base interface for log printers
- [Logging Listener](./logging_listener.md) - For listening to log events

### Models
- [Log Config](./models/log_config.md) - Configuration for logging
- [Log Record](./models/log_record.md) - Represents a single log entry

### Enums
- [Log Level](./enums/log_level.md) - Different levels of logging
- [Log Step](./enums/log_step.md) - Steps in the logging process
- [Log Type](./enums/log_type.md) - Types of log entries

### Printers
- [Simple Printer](./printers/simple_printer.md) - Basic log printer
- [Pretty Printer](./printers/pretty_printer.md) - Formatted, colorful output
- [Flat Printer](./printers/flat_printer.md) - Single-line log output
- [FMT Printer](./printers/fmt_printer.md) - Formatted message printer
- [Hybrid Printer](./printers/hybrid_printer.md) - Combines multiple printers
- [Prefix Printer](./printers/prefix_printer.md) - Adds prefixes to log messages
- [Structured Printers](./printers/README.md) - For structured logging

### Helpers
- [Commons](./helpers/commons.md) - Common utilities
- [Stack Trace Parser](./helpers/stack_trace_parser.md) - For parsing stack traces

### ANSI
- [ANSI Color](./ansi/ansi_color.md) - ANSI color codes
- [ANSI Output](./ansi/ansi_output.md) - ANSI output utilities
