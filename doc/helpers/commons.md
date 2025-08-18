# Common Utilities

The `commons.dart` file contains various utility functions and extensions used throughout the logging library. These utilities provide common functionality for working with strings, collections, and other Dart types.

## String Utilities

### `StringExtensions`
Extension methods for the `String` class:

| Method | Description |
|--------|-------------|
| `isNullOrEmpty` | Returns `true` if the string is null or empty |
| `isNotNullOrEmpty` | Returns `true` if the string is not null and not empty |
| `truncate(int maxLength, {String ellipsis = '...'})` | Truncates the string to the specified length |
| `capitalize()` | Capitalizes the first letter of the string |
| `toCamelCase()` | Converts the string to camelCase |
| `toPascalCase()` | Converts the string to PascalCase |
| `toSnakeCase()` | Converts the string to snake_case |

### `String?` Extensions

| Method | Description |
|--------|-------------|
| `orEmpty()` | Returns an empty string if the string is null |
| `or(String defaultValue)` | Returns the string or the default value if null |

## Collection Utilities

### `ListExtensions`
Extension methods for the `List` class:

| Method | Description |
|--------|-------------|
| `isNullOrEmpty` | Returns `true` if the list is null or empty |
| `isNotNullOrEmpty` | Returns `true` if the list is not null and not empty |
| `getOrNull(int index)` | Safely gets an element at the specified index |
| `joinWithCommas()` | Joins elements with commas |
| `joinWithNewLines()` | Joins elements with newlines |

### `MapExtensions`
Extension methods for the `Map` class:

| Method | Description |
|--------|-------------|
| `getOrNull(K key)` | Safely gets a value by key |
| `getOrPut(K key, V Function() defaultValue)` | Gets a value or puts a default value if the key doesn't exist |
| `mapKeys<R>(R Function(K key, V value) transform)` | Transforms map keys |
| `mapValues<R>(R Function(K key, V value) transform)` | Transforms map values |

## Functional Utilities

### `ObjectExtensions`
Extension methods for any object:

| Method | Description |
|--------|-------------|
| `let<R>(R Function(T) block)` | Executes the given block with the object as its argument |
| `also(void Function(T) block)` | Executes the given block and returns the object |
| `takeIf(bool Function(T) predicate)` | Returns the object if it satisfies the given predicate |
| `takeUnless(bool Function(T) predicate)` | Returns the object if it does not satisfy the given predicate |

### `bool` Extensions

| Method | Description |
|--------|-------------|
| `then(Function() action)` | Executes the action if the boolean is true |
| `orElse(Function() action)` | Executes the action if the boolean is false |

## Date/Time Utilities

### `DateTimeExtensions`
Extension methods for the `DateTime` class:

| Method | Description |
|--------|-------------|
| `toIso8601String()` | Converts the date to an ISO 8601 string |
| `toLocalString()` | Converts the date to a local string |
| `toUtcString()` | Converts the date to a UTC string |
| `isToday()` | Returns `true` if the date is today |
| `isYesterday()` | Returns `true` if the date is yesterday |
| `isThisYear()` | Returns `true` if the date is in the current year |

## Usage Examples

```dart
import 'package:jetleaf_logging/jetleaf_logging.dart';

void main() {
  // String extensions
  final name = 'john doe';
  print(name.capitalize()); // 'John doe'
  print(name.toCamelCase()); // 'johnDoe'
  
  // Nullable string
  String? maybeName;
  print(maybeName.or('Anonymous')); // 'Anonymous'
  
  // List extensions
  final numbers = [1, 2, 3];
  print(numbers.getOrNull(10)); // null
  print(numbers.joinWithCommas()); // '1, 2, 3'
  
  // Map extensions
  final map = {'a': 1, 'b': 2};
  print(map.getOrPut('c', () => 3)); // 3
  
  // Object extensions
  'hello'.let((it) => print(it.toUpperCase())); // 'HELLO'
  
  // Boolean extensions
  final isLoggedIn = true;
  isLoggedIn.then(() => print('User is logged in'));
  
  // DateTime extensions
  final now = DateTime.now();
  print(now.isToday()); // true
  print(now.toIso8601String());
}
```

## Best Practices

1. **Use extension methods** to make your code more readable and concise
2. **Chain operations** for better readability:
   ```dart
   final result = someString
       .trim()
       .toLowerCase()
       .replaceAll(' ', '_');
   ```
3. **Handle null safety** using the provided extensions:
   ```dart
   // Instead of
   final length = someString != null ? someString.length : 0;
   
   // Use
   final length = someString?.length ?? 0;
   // or
   final length = someString.orEmpty().length;
   ```
4. **Use functional extensions** for better code organization:
   ```dart
   // Instead of
   String? process(String? input) {
     if (input == null) return null;
     return input.trim().toUpperCase();
   }
   
   // Use
   String? process(String? input) =>
       input?.trim()?.toUpperCase();
   ```
