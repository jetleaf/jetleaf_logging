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

import 'package:jetleaf_lang/lang.dart';

import 'enums/log_level.dart';
import 'logging_listener.dart';

/// The log content.
/// 
/// This is a map of key-value pairs representing the log content.
typedef LogContent = Map<String, dynamic>;

/// The log details.
/// 
/// This is a map of key-value pairs representing the log details.
typedef _LogDetails = Map<DateTime, LogContent>;

/// The log information.
/// 
/// This is a map of key-value pairs representing the log information.
typedef _LogInformation = Map<LogLevel, _LogDetails>;

/// The log entry.
/// 
/// This is a map of key-value pairs representing the log entry.
typedef LogEntry = Map<String, _LogInformation>;

/// {@template logger_factory}
/// A base class for building structured logging mechanisms within Jet-based applications.
///
/// This class provides an in-memory logging facility with support for multiple [LogLevel]s.
/// Subclasses can extend this base to implement custom logging strategies (e.g., file, console, remote).
///
/// Each logger instance is tagged with a custom [tag] to allow filtering or identification in composite logs.
///
/// ### Usage
///
/// Extend this class to build a concrete logger:
/// ```dart
/// class ConsoleLogger extends LoggerFactory {
///   ConsoleLogger(String tag) : super(tag);
///
///   void flush() {
///     _logs.forEach((level, messages) {
///       for (final message in messages) {
///         print('[$tag][$level] $message');
///       }
///     });
///   }
/// }
/// ```
///
/// Then use:
/// ```dart
/// final logger = ConsoleLogger("MyService");
/// logger.add(LogLevel.info, "Service started.");
/// logger.add(LogLevel.error, "Something went wrong.");
/// logger.flush();
/// ```
///
/// {@endtemplate}
abstract class LogFactory {
  /// A custom label or category used to identify the logger instance.
  ///
  /// Commonly used to associate logs with a specific class, service, or module.
  final String tag;

  /// Whether the logger can publish logs to the console.
  final bool canPublish;

  /// The [LogListener] to use for this factory.
  /// 
  /// Can be nullable
  final LoggingListener? logListener;

  /// Internal log storage mapping each [LogLevel] to a list of log messages.
  _LogInformation _logs;

  /// Internal log entry storage mapping each [tag] to a list of log messages.
  /// 
  /// Mostly used when combining multiple loggers, in order to keep track of logs per tags.
  LogEntry _superEntry = {};

  /// Whether the logger is allowed to publish logs to the console.
  /// 
  /// Defaults to `true`
  bool _isAllowed = true;

  /// Whether the logger is allowed to publish [LogLevel.INFO] logs to the console.
  /// 
  /// Defaults to `true`
  bool _isInfoEnabled = true;
  
  /// Whether the logger is allowed to publish [LogLevel.DEBUG] logs to the console.
  /// 
  /// Defaults to `true`
  bool _isDebugEnabled = true;
  
  /// Whether the logger is allowed to publish [LogLevel.WARN] logs to the console.
  /// 
  /// Defaults to `true`
  bool _isWarnEnabled = true;
  
  /// Whether the logger is allowed to publish [LogLevel.ERROR] logs to the console.
  /// 
  /// Defaults to `true`
  bool _isErrorEnabled = true;
  
  /// Whether the logger is allowed to publish [LogLevel.FATAL] logs to the console.
  /// 
  /// Defaults to `true`
  bool _isFatalEnabled = true;
  
  /// Whether the logger is allowed to publish [LogLevel.TRACE] logs to the console.
  /// 
  /// Defaults to `true`
  bool _isTraceEnabled = true;

  /// Constructs the logger factory with the given [tag].
  ///
  /// Initializes an empty log store for all levels.
  /// 
  /// {@macro logger_factory}
  LogFactory(this.tag, {this.canPublish = true, this.logListener}) : _logs = {
    LogLevel.INFO: {},
    LogLevel.WARN: {},
    LogLevel.ERROR: {},
    LogLevel.DEBUG: {},
    LogLevel.FATAL: {},
    LogLevel.OFF: {},
    LogLevel.TRACE: {},
  };

  /// Returns a new [Log] instance for the given [type].
  /// 
  /// {@macro log}
  static Log getLog(Type type, {bool canPublish = true}) {
    return Log(type.toString(), canPublish: canPublish);
  }

  /// Whether the logger is allowed to publish logs to the console.
  /// 
  /// This is used to determine whether the logger should publish or store logs to the console/factory.
  /// 
  /// {@macro logger_factory}
  bool getIsAllowed() => _isAllowed;

  /// Sets whether logging is allowed globally.
  /// 
  /// When set to `false`, all logging operations may be suppressed.
  void setIsAllowed(bool value) {
    _isAllowed = value;
  }

  /// Returns whether `INFO`-level logging is currently enabled.
  bool getIsInfoEnabled() => _isInfoEnabled;

  /// Enables or disables `INFO`-level logging.
  /// 
  /// Set to `true` to allow `INFO` messages to be logged.
  void setIsInfoEnabled(bool value) {
    _isInfoEnabled = value;
  }

  /// Returns whether `DEBUG`-level logging is currently enabled.
  bool getIsDebugEnabled() => _isDebugEnabled;

  /// Enables or disables `DEBUG`-level logging.
  /// 
  /// Useful during development for detailed internal state logs.
  void setIsDebugEnabled(bool value) {
    _isDebugEnabled = value;
  }

  /// Returns whether `WARN`-level logging is currently enabled.
  bool getIsWarnEnabled() => _isWarnEnabled;

  /// Enables or disables `WARN`-level logging.
  /// 
  /// Use `WARN` logs for recoverable issues that need attention.
  void setIsWarnEnabled(bool value) {
    _isWarnEnabled = value;
  }

  /// Returns whether `ERROR`-level logging is currently enabled.
  bool getIsErrorEnabled() => _isErrorEnabled;

  /// Enables or disables `ERROR`-level logging.
  /// 
  /// Use `ERROR` logs for unrecoverable failures or serious issues.
  void setIsErrorEnabled(bool value) {
    _isErrorEnabled = value;
  }

  /// Returns whether `FATAL`-level logging is currently enabled.
  bool getIsFatalEnabled() => _isFatalEnabled;

  /// Enables or disables `FATAL`-level logging.
  /// 
  /// `FATAL` logs represent critical system errors that typically
  /// require an immediate shutdown.
  void setIsFatalEnabled(bool value) {
    _isFatalEnabled = value;
  }

  /// Returns whether `TRACE`-level logging is currently enabled.
  bool getIsTraceEnabled() => _isTraceEnabled;

  /// Enables or disables `TRACE`-level logging.
  /// 
  /// `TRACE` logs are the most fine-grained level and are useful for
  /// diagnosing specific code paths or rare edge cases.
  void setIsTraceEnabled(bool value) {
    _isTraceEnabled = value;
  }

  void _log(LogLevel level, String message, {Object? error, StackTrace? stacktrace, String? dTag}) {
    if(logListener != null) {
      if(getIsDebugEnabled() && level == LogLevel.DEBUG) {
        logListener!.onLog(level, message, tag: dTag ?? tag, error: error, stackTrace: stacktrace);
      }

      if(getIsInfoEnabled() && level == LogLevel.INFO) {
        logListener!.onLog(level, message, tag: dTag ?? tag, error: error, stackTrace: stacktrace);
      }

      if(getIsWarnEnabled() && level == LogLevel.WARN) {
        logListener!.onLog(level, message, tag: dTag ?? tag, error: error, stackTrace: stacktrace);
      }

      if(getIsErrorEnabled() && level == LogLevel.ERROR) {
        logListener!.onLog(level, message, tag: dTag ?? tag, error: error, stackTrace: stacktrace);
      }

      if(getIsFatalEnabled() && level == LogLevel.FATAL) {
        logListener!.onLog(level, message, tag: dTag ?? tag, error: error, stackTrace: stacktrace);
      }

      if(getIsTraceEnabled() && level == LogLevel.TRACE) {
        logListener!.onLog(level, message, tag: dTag ?? tag, error: error, stackTrace: stacktrace);
      }
    }
  }

  /// Adds a [message] to the log buffer under the specified [level].
  ///
  /// If the level already contains entries, the new message is appended.
  ///
  /// Example:
  /// ```dart
  /// logger.add(LogLevel.debug, "Fetching user profile...");
  /// ```
  /// 
  /// If [canPublish] is true, the log is published to the console.
  /// 
  /// If [canPublish] is false, the log is stored in the internal log buffer.
  /// 
  /// {@macro logger_factory}
  void add(LogLevel level, String message, {Object? error, StackTrace? stacktrace}) {
    if(!getIsAllowed()) {
      return;
    }

    final timestamp = DateTime.now();

    if(canPublish) {
      _log(level, message, error: error, stacktrace: stacktrace);
    } else {
      _logs.update(
        level,
        (details) => details..add(timestamp, _prepareContent(message, error: error, stacktrace: stacktrace)),
        ifAbsent: () => {timestamp: _prepareContent(message, error: error, stacktrace: stacktrace)},
      );
    }
  }

  /// Prepares a log content.
  /// 
  /// This method takes a [message] and optional [error] and [stacktrace],
  /// and returns a map containing the log content.
  /// 
  /// {@macro logger_factory}
  LogContent _prepareContent(String message, {Object? error, StackTrace? stacktrace}) {
    LogContent content = {
      "message": message,
    };

    if(error != null) {
      content["error"] = error;
    }

    if(stacktrace != null) {
      content["stacktrace"] = stacktrace;
    }

    return content;
  }

  /// Returns the log entry for the current logger.
  /// 
  /// This is mostly used when combining multiple loggers, in order to keep track of logs per tags. 
  /// 
  /// {@macro logger_factory}
  LogEntry get entry => {tag: _logs};

  /// Adds all logs from the given [entry] to the internal super entry buffer.
  /// 
  /// This is mostly used when combining multiple loggers, in order to keep track of logs per tags. 
  /// 
  /// {@macro logger_factory}
  void addAll(LogEntry entry) {
    _superEntry.addAll(entry);
  }

  /// Clears all logs from every [LogLevel].
  ///
  /// Useful for resetting the internal state or reusing the logger.
  ///
  /// Example:
  /// ```dart
  /// logger.clear(); // Empties all stored logs
  /// ```
  void clear() {
    _logs = {
      LogLevel.INFO: {},
      LogLevel.WARN: {},
      LogLevel.ERROR: {},
      LogLevel.DEBUG: {},
      LogLevel.FATAL: {},
      LogLevel.OFF: {},
      LogLevel.TRACE: {},
    };

    _superEntry = {};
  }

  /// Publishes all logs to the console.
  /// 
  /// This method iterates through all log levels and their associated messages,
  /// and publishes them to the console if [canPublish] is false.
  /// 
  /// Example:
  /// ```dart
  /// logger.publish();
  /// ```
  /// 
  /// This is mostly used when the extending class was initially created with [canPublish] set to false.
  void publish() {
    if(canPublish.isFalse) {
      if(_logs.isNotEmpty) {
        _logs.forEach((LogLevel level, _LogDetails details) {
          details.forEach((timestamp, content) {
            _log(level, getMessage(content), error: getError(content), stacktrace: getStackTrace(content));
          });
        });
      }

      if(_superEntry.isNotEmpty) {
        _superEntry.forEach((tag, details) {
          details.forEach((level, updates) {
            updates.forEach((timestamp, content) {
              _log(level, getMessage(content), dTag: tag, error: getError(content), stacktrace: getStackTrace(content));
            });
          });
        });
      }

      clear();
    }
  }

  /// Returns the message from the given [content].
  /// 
  /// {@macro logger_factory}
  String getMessage(LogContent content) {
    return content["message"];
  }

  /// Returns the error from the given [content].
  /// 
  /// {@macro logger_factory}
  Object? getError(LogContent content) {
    return content["error"];
  }

  /// Returns the stack trace from the given [content].
  /// 
  /// {@macro logger_factory}
  StackTrace? getStackTrace(LogContent content) {
    return content["stacktrace"];
  }
}

/// {@template log}
/// A convenient logging utility built on top of [LogFactory].
///
/// The `Log` class provides a simplified and readable interface for
/// logging messages at various log levels such as info, warning, error,
/// debug, fatal, and trace. It is typically used throughout the JetLeaf
/// framework to emit consistent and structured log output.
///
/// ### Example:
/// ```dart
/// final log = Log('MyComponent');
///
/// log.info('Application started.');
/// log.error('Something went wrong.', error: exception, stacktrace: stack);
/// log.debug('Debugging some internal state...');
/// ```
///
/// The `tag` passed to the constructor is used to identify the origin
/// of log messages, such as a class or module name.
///
/// This class is `final`, so it cannot be extended.
/// {@endtemplate}
final class Log extends LogFactory {
  /// {@macro log}
  Log(super.tag, {super.canPublish = true});

  /// {@template log.info}
  /// Logs a message at the `INFO` level.
  ///
  /// Typically used for general application flow messages.
  ///
  /// ### Example:
  /// ```dart
  /// log.info('Server started successfully.');
  /// ```
  /// {@endtemplate}
  void info(String message, {Object? error, StackTrace? stacktrace}) {
    add(LogLevel.INFO, message, error: error, stacktrace: stacktrace);
  }

  /// {@template log.warn}
  /// Logs a message at the `WARN` level.
  ///
  /// Typically used to indicate a potential problem that is non-fatal.
  ///
  /// ### Example:
  /// ```dart
  /// log.warn('Disk space is running low.');
  /// ```
  /// {@endtemplate}
  void warn(String message, {Object? error, StackTrace? stacktrace}) {
    add(LogLevel.WARN, message, error: error, stacktrace: stacktrace);
  }

  /// {@template log.error}
  /// Logs a message at the `ERROR` level.
  ///
  /// Used when an operation fails but the app can still continue.
  ///
  /// ### Example:
  /// ```dart
  /// log.error('Failed to load configuration file.', error: e, stacktrace: s);
  /// ```
  /// {@endtemplate}
  void error(String message, {Object? error, StackTrace? stacktrace}) {
    add(LogLevel.ERROR, message, error: error, stacktrace: stacktrace);
  }

  /// {@template log.debug}
  /// Logs a message at the `DEBUG` level.
  ///
  /// Used for debugging during development or diagnostics.
  ///
  /// ### Example:
  /// ```dart
  /// log.debug('User data: $user');
  /// ```
  /// {@endtemplate}
  void debug(String message, {Object? error, StackTrace? stacktrace}) {
    add(LogLevel.DEBUG, message, error: error, stacktrace: stacktrace);
  }

  /// {@template log.fatal}
  /// Logs a message at the `FATAL` level.
  ///
  /// Used when a critical error occurs and the system may not recover.
  ///
  /// ### Example:
  /// ```dart
  /// log.fatal('Unrecoverable system failure.', error: err, stacktrace: st);
  /// ```
  /// {@endtemplate}
  void fatal(String message, {Object? error, StackTrace? stacktrace}) {
    add(LogLevel.FATAL, message, error: error, stacktrace: stacktrace);
  }

  /// {@template log.trace}
  /// Logs a message at the `TRACE` level.
  ///
  /// Useful for very fine-grained logging of program execution.
  ///
  /// ### Example:
  /// ```dart
  /// log.trace('Entering middleware layer...');
  /// ```
  /// {@endtemplate}
  void trace(String message, {Object? error, StackTrace? stacktrace}) {
    add(LogLevel.TRACE, message, error: error, stacktrace: stacktrace);
  }
}