# ANSI Color

The `AnsiColor` class provides utilities for working with ANSI color codes in terminal output. It allows you to add colors, styles, and other text decorations to your console output.

## Supported Colors

### Foreground Colors
- `black`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `white`
- `brightBlack` (gray)
- `brightRed`
- `brightGreen`
- `brightYellow`
- `brightBlue`
- `brightMagenta`
- `brightCyan`
- `brightWhite`
- `default` (reset to default color)

### Background Colors
- `bgBlack`
- `bgRed`
- `bgGreen`
- `bgYellow`
- `bgBlue`
- `bgMagenta`
- `bgCyan`
- `bgWhite`
- `bgBrightBlack`
- `bgBrightRed`
- `bgBrightGreen`
- `bgBrightYellow`
- `bgBrightBlue`
- `bgBrightMagenta`
- `bgBrightCyan`
- `bgBrightWhite`
- `bgDefault` (reset to default background)

### Text Styles
- `bold`
- `faint`
- `italic`
- `underline`
- `blink`
- `inverse`
- `strikethrough`
- `reset` (reset all styles)

## Usage

### Basic Usage

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  final ansi = AnsiColor();
  
  // Colored text
  print(ansi.red('This is red text'));
  print(ansi.green('This is green text'));
  
  // Background colors
  print(ansi.bgBlue('Blue background'));
  
  // Text styles
  print(ansi.bold('Bold text'));
  print(ansi.underline('Underlined text'));
  
  // Combining styles
  print(ansi.red.bold('Bold red text'));
  print(ansi.bgYellow.black('Black text on yellow background'));
  
  // Nested styles
  print(ansi.red('Red ' + ansi.green('Green') + ' Red'));
}
```

### Disabling Colors

You can disable colors globally:

```dart
// Disable all colors
AnsiColor.enabled = false;

// Now all color methods will return the original text
print(ansi.red('This will not be red')); // Outputs: 'This will not be red'
```

### Custom Colors

Create custom colors using RGB values:

```dart
// 8-bit color
final customColor = AnsiColor().rgb8(200, 100, 50);
print(customColor('Custom color'));

// 24-bit true color
final trueColor = AnsiColor().rgb(255, 165, 0); // Orange
print(trueColor('True color text'));
```

## Best Practices

1. **Check color support**:
   ```dart
   if (AnsiColor.supportsColor) {
     print(ansi.green('Colors are supported'));
   } else {
     print('Colors not supported');
   }
   ```

2. **Use semantic names** for better readability:
   ```dart
   final error = ansi.red.bold;
   final success = ansi.green;
   final warning = ansi.yellow;
   
   print(error('Error: Something went wrong'));
   print(success('Operation completed successfully'));
   print(warning('Warning: This might cause issues'));
   ```

3. **Reset styles** when needed:
   ```dart
   print('${ansi.red('Red')}${ansi.reset()} Normal');
   ```

4. **Avoid color conflicts** with terminal themes:
   ```dart
   // Use high contrast colors for better visibility
   final error = ansi.white.bgRed.bold;
   final success = ansi.black.bgGreen.bold;
   ```

## Advanced Usage

### Custom Themes

Create reusable color themes:

```dart
class LogTheme {
  final AnsiColor error;
  final AnsiColor warning;
  final AnsiColor info;
  final AnsiColor debug;
  
  LogTheme()
      : error = AnsiColor().white.bgRed.bold,
        warning = AnsiColor().black.bgYellow.bold,
        info = AnsiColor().blue.bold,
        debug = AnsiColor().cyan;
}

// Usage
final theme = LogTheme();
print(theme.error(' ERROR '));
print(theme.warning(' WARNING '));
print(theme.info(' INFO '));
print(theme.debug(' DEBUG '));
```

### Conditional Coloring

Apply colors conditionally:

```dart
String formatLogLevel(LogLevel level) {
  final ansi = AnsiColor();
  
  return switch (level) {
    LogLevel.error => ansi.red.bold(level.name),
    LogLevel.warning => ansi.yellow(level.name),
    LogLevel.info => ansi.blue(level.name),
    LogLevel.debug => ansi.cyan(level.name),
    _ => level.name,
  };
}
```

### Progress Bars

Create simple progress bars:

```dart
void showProgress(int current, int total) {
  final ansi = AnsiColor();
  final width = 30;
  final progress = (current / total * width).round();
  final bar = '#' * progress + ' ' * (width - progress);
  final percent = (current / total * 100).round();
  
  stdout.write('\r${ansi.green(bar)} $percent%');
  if (current >= total) {
    print('\nDone!');
  }
}
```

### Color Palettes

Create and use color palettes:

```dart
class ColorPalette {
  static const List<int> _rainbow = [
    0xFFFF0000, // Red
    0xFFFF7F00, // Orange
    0xFFFFFF00, // Yellow
    0xFF00FF00, // Green
    0xFF0000FF, // Blue
    0xFF4B0082, // Indigo
    0xFF8B00FF, // Violet
  ];
  
  final AnsiColor _ansi = AnsiColor();
  
  String rainbow(String text) {
    final buffer = StringBuffer();
    final length = text.length;
    
    for (var i = 0; i < length; i++) {
      final color = _rainbow[i % _rainbow.length];
      final r = (color >> 16) & 0xFF;
      final g = (color >> 8) & 0xFF;
      final b = color & 0xFF;
      
      buffer.write(_ansi.rgb(r, g, b)(text[i]));
    }
    
    return buffer.toString();
  }
}

// Usage
final palette = ColorPalette();
print(palette.rainbow('Rainbow colored text'));
```
