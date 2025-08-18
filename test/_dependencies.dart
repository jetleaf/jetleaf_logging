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

import 'package:jetleaf_logging/logging.dart';
import 'package:jetleaf_logging/src/models/log_record.dart';

LogRecord sampleRecord({
  String message = "Test log",
  LogLevel level = LogLevel.INFO,
  DateTime? time,
  String? tag,
  dynamic error,
  StackTrace? stackTrace,
  String? location,
}) {
  return LogRecord(
    level,
    message,
    time: time ?? DateTime.utc(2025, 1, 1, 12, 0, 0),
    loggerName: tag,
    error: error,
    stackTrace: stackTrace,
  );
}

LogConfig defaultConfig({
  List<LogStep> steps = const [LogStep.TIMESTAMP, LogStep.LEVEL, LogStep.MESSAGE],
  bool showTag = false,
  bool showLevel = true,
  bool showTimestamp = true,
  bool useHumanReadableTime = false,
  bool showDateOnly = false,
}) {
  return LogConfig(
    steps: steps,
    showTag: showTag,
    showLevel: showLevel,
    showTimestamp: showTimestamp,
    useHumanReadableTime: useHumanReadableTime,
    showDateOnly: showDateOnly,
  );
}