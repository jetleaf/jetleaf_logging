// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

/// 📝 **JetLeaf Logging System**
///
/// This library provides the core logging infrastructure for the JetLeaf
/// framework, including log levels, formatting, configuration models,
/// output handling, and extensible logging pipelines.
///
/// It serves as the public entry point to JetLeaf's logging API.
///
///
/// ## 🔥 Key Features
///
/// - Flexible log level control (trace → fatal)
/// - ANSI-styled console output
/// - Structured log records
/// - Configurable printers and listeners
/// - Extensible logging factory and entrypoints
///
///
/// ## 📦 Exports Overview
///
/// ### 🧾 Log Enums
/// - `LogLevel` — severity classification
/// - `LogStep` — lifecycle phases (e.g., start/end)
/// - `LogType` — categorization of log intent
///
///
/// ### 🎨 ANSI Output
/// - `AnsiColor` — terminal-safe color/style definitions  
/// - `AnsiOutput` — utilities for rendering styled log text
///
/// Useful for rich console diagnostics.
///
///
/// ### 📑 Log Models
/// - `LogConfig` — runtime configuration for logging behavior  
/// - `LogRecord` — immutable representation of a logged event
///
/// Enables structured logging and external routing.
///
///
/// ### ⚙️ Core Logging Engine
/// - `LogPrinter` — strategy interface for rendering logs  
/// - `LoggingListener` — event subscription for log emission  
/// - `LogFactory` — responsible for creating log instances  
/// - `Log` — primary logging API entrypoint
///
/// Example usage:
/// ```dart
/// final log = LogFactory.get('server');
/// log.info('Server started');
/// ```
///
///
/// ### 🛠 Helpers
/// - common utility functions supporting the logging system
///
///
/// ## ✅ Intended Usage
///
/// Import once to access the complete JetLeaf logging API:
/// ```dart
/// import 'package:jetleaf_logging/logging.dart';
/// ```
///
/// Designed for framework and application-level diagnostics,
/// with extensibility for custom sinks, printers, and integrations.
library;

import 'src/enums/log_level.dart';
import 'src/enums/log_type.dart';
import 'src/core/log_printer.dart';
import 'src/core/log_processor.dart';
import 'src/core/logging_listener.dart';
import 'src/models/log_config.dart';

/// ENUMS & Interfaces exported for external use.
export 'src/enums/log_level.dart';
export 'src/enums/log_step.dart';
export 'src/enums/log_type.dart';

export 'src/ansi/ansi_color.dart';
export 'src/ansi/ansi_output.dart';

export 'src/models/log_config.dart';
export 'src/models/log_record.dart';

export 'src/core/log_printer.dart';
export 'src/core/logging_listener.dart';

export 'src/core/log_factory.dart';
export 'src/core/log.dart';

export 'src/helpers/commons.dart';

/// {@template logger}
/// A flexible and extensible logging interface.
///
/// The [Logger] class provides structured and leveled logging functionality
/// across your application. It wraps a [LoggingListener] that handles
/// how logs are processed and output—making it customizable through the strategy pattern.
///
/// This class offers six common logging levels:
/// - [info] – General operational messages.
/// - [debug] – Development and debugging messages.
/// - [trace] – Fine-grained, low-level application traces.
/// - [warning] – Warning messages about unexpected conditions.
/// - [error] – Errors that occurred during execution.
/// - [fatal] – Critical errors that may require immediate attention.
///
/// ### Example:
/// ```dart
/// console.info('Server started');
/// console.error('Unexpected error occurred', error: e, stackTrace: s);
/// ```
/// 
/// {@endtemplate}
class Logger implements LogProcessor {
  /// The current log listener responsible for handling the log output logic.
  ///
  /// You can override this with a custom [LoggingListener] via [addListener()]
  /// to modify how logs are formatted or where they are sent (e.g., file, console, remote server).
  late LoggingListener listener;

  /// {@macro logger}
  Logger({
    LogLevel level = LogLevel.INFO,
    LogPrinter? printer,
    LogType type = LogType.SIMPLE,
    void Function(String)? output,
    String name = "",
    LogConfig? config,
    LoggingListener? listener,
  }) : listener = listener ?? DefaultLoggingListener(
    level: level,
    printer: printer,
    type: type,
    output: output,
    name: name,
    config: config,
  );

  /// Replaces the current [LoggingListener] with a custom implementation.
  ///
  /// Useful if you want to change the output format, destination,
  /// or add logic like filtering or buffering logs.
  ///
  /// Example:
  /// ```dart
  /// console.addListener(MyCustomListener());
  /// ```
  void addListener(LoggingListener listener) {
    this.listener = listener;
  }

  @override
  void info(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    listener.onLog(LogLevel.INFO, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  @override
  void warn(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    listener.onLog(LogLevel.WARN, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  @override
  void error(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    listener.onLog(LogLevel.ERROR, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  @override
  void fatal(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    listener.onLog(LogLevel.FATAL, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  @override
  void debug(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    listener.onLog(LogLevel.DEBUG, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  @override
  void trace(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    listener.onLog(LogLevel.TRACE, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Logs a message with a specified log level.
  ///
  /// Use this for logging messages with a specific log level.
  void log(dynamic message, {String? tag, Object? error, StackTrace? stackTrace, LogLevel level = LogLevel.INFO}) {
    listener.onLog(level, message, error: error, stackTrace: stackTrace, tag: tag);
  }
}

/// Global singleton logger instance for convenience.
///
/// Use `console` for quick access without instantiating [Tracing] manually.
///
/// Example:
/// ```dart
/// console.debug('Hello from global logger');
/// ```
final console = Logger();