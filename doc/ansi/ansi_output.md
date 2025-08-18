# ANSI Output

The `AnsiOutput` class provides a fluent interface for building and managing ANSI-styled console output. It's built on top of `AnsiColor` and offers additional features for more complex output scenarios.

## Features

- Chainable API for building styled output
- Automatic color reset handling
- Support for nested styles
- Cursor movement and screen manipulation
- Progress bars and spinners
- Table formatting

## Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  final output = AnsiOutput();
  
  // Simple styled output
  output
    .write('Hello, ')
    .red('world')
    .reset()
    .writeln('!');
    
  // Chain styles
  output
    .bold().underline()
    .write('Styled text')
    .reset()
    .writeln(' Normal text');
    
  // Build complex output
  output
    .green('Success: ')
    .write('Operation completed in ')
    .bold().yellow('2.5s')
    .reset()
    .writeln();
}
```

## Cursor Control

```dart
final output = AnsiOutput();

// Move cursor
output
  .cursorUp(2)    // Move up 2 lines
  .cursorRight(3)  // Move right 3 columns
  .write('X')     // Write at new position
  .cursorTo(0, 0) // Move to top-left
  .clearScreen();  // Clear the screen

// Save and restore cursor position
output
  .saveCursor()
  .write('First line\n')
  .restoreCursor()
  .write('Overwritten line');
```

## Progress Indicators

### Progress Bar

```dart
void showProgress(double progress) {
  final width = 40;
  final filled = (progress * width).round();
  final bar = '#' * filled + '-' * (width - filled);
  
  AnsiOutput()
    .write('[')
    .green(bar)
    .write('] ')
    .bold().write('${(progress * 100).toStringAsFixed(1)}%')
    .reset()
    .flush(overwrite: true); // Overwrites the current line
}

// Usage
for (var i = 0; i <= 100; i++) {
  showProgress(i / 100);
  await Future.delayed(Duration(milliseconds: 50));
}
```

### Spinner

```dart
class Spinner {
  final List<String> _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int _index = 0;
  
  void spin() {
    AnsiOutput()
      .write('\r${_frames[_index]} Processing...')
      .flush(overwrite: true);
      
    _index = (_index + 1) % _frames.length;
  }
}
```

## Tables

```dart
void printTable() {
  final output = AnsiOutput();
  final data = [
    ['Name', 'Age', 'City'],
    ['Alice', '28', 'New York'],
    ['Bob', '34', 'San Francisco'],
    ['Charlie', '22', 'Los Angeles'],
  ];
  
  // Calculate column widths
  final colWidths = List.filled(data[0].length, 0);
  for (final row in data) {
    for (var i = 0; i < row.length; i++) {
      if (row[i].length > colWidths[i]) {
        colWidths[i] = row[i].length;
      }
    }
  }
  
  // Print table
  for (var i = 0; i < data.length; i++) {
    final row = data[i];
    
    // Header row
    if (i == 0) {
      output.bold().underline();
    }
    
    // Print row
    for (var j = 0; j < row.length; j++) {
      output.write(row[j].padRight(colWidths[j] + 2));
    }
    output.writeln();
    
    // Reset styles after header
    if (i == 0) {
      output.reset();
    }
  }
  
  output.flush();
}
```

## Best Practices

1. **Always reset styles** after use to prevent style bleeding
2. **Batch writes** when possible to minimize I/O operations
3. **Check for TTY** before using advanced features:
   ```dart
   if (AnsiOutput.isTerminal) {
     // Use advanced features
   } else {
     // Fallback to simple output
   }
   ```
4. **Handle errors** when writing to output:
   ```dart
   try {
     output.write('Important message').flush();
   } catch (e) {
     // Handle write error
   }
   ```

## Advanced Usage

### Custom Themes

```dart
class LogTheme {
  final AnsiOutput Function(String) error;
  final AnsiOutput Function(String) success;
  final AnsiOutput Function(String) warning;
  
  LogTheme()
      : error = (msg) => AnsiOutput().red().bold().write(msg).reset(),
        success = (msg) => AnsiOutput().green().write(msg).reset(),
        warning = (msg) => AnsiOutput().yellow().write(msg).reset();
}

// Usage
final theme = LogTheme();
theme.error('Error: Something went wrong').writeln();
theme.success('Operation completed').writeln();
```

### Nested Styles

```dart
void printStyledMessage() {
  AnsiOutput()
    .write('This is ')
    .red('red text with ')
    .bold().write('bold').reset().red(' and ')
    .underline().write('underline').reset().red('.')
    .reset()
    .writeln(' Back to normal.');
}
```

### Interactive Prompts

```dart
Future<String> prompt(String message) async {
  final output = AnsiOutput();
  final input = stdin;
  
  output.blue('? ').write(message).write(' ');
  output.flush();
  
  return input.readLineSync()?.trim() ?? '';
}

// Usage
final name = await prompt('Enter your name:');
print('Hello, $name!');
```

### Status Updates

```dart
class StatusUpdater {
  final AnsiOutput _output = AnsiOutput();
  String _lastStatus = '';
  
  void update(String status) {
    if (status == _lastStatus) return;
    
    _output
      .cursorToStart()
      .clearToEndOfLine()
      .write(status)
      .flush();
      
    _lastStatus = status;
  }
  
  void complete([String? message]) {
    _output
      .cursorToStart()
      .clearToEndOfLine()
      .green('✓ ')
      .write(message ?? 'Done')
      .writeln()
      .flush();
  }
}
```
