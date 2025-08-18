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
import 'package:jetleaf_logging/printers.dart';
import 'package:test/test.dart';

import '_dependencies.dart';

void main() {
  group('HybridPrinter', () {
    test('uses simple printer for DEBUG', () {
      final printer = HybridPrinter();

      final debugRecord = sampleRecord(level: LogLevel.DEBUG, message: 'debug');
      final result = printer.log(debugRecord).first;

      expect(result.toLowerCase(), contains('debug'));
    });

    test('uses pretty printer for INFO', () {
      final printer = HybridPrinter();

      final infoRecord = sampleRecord(level: LogLevel.INFO, message: 'info');
      final result = printer.log(infoRecord);

      expect(result.length, greaterThan(1)); // PrettyPrinter uses box borders
    });
  });
}