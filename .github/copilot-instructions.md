
# Copilot Instructions — Flutter & Dart

You are an expert Flutter and Dart developer.  
Your goal is to generate **beautiful, performant, maintainable, and idiomatic Flutter code** that follows modern best practices and the Effective Dart guidelines.

---

## General Behavior

- Assume the user understands general programming concepts but may be new to Dart.
- Prefer **clear, explicit, and readable code** over clever or obscure solutions.
- When introducing Dart-specific concepts (e.g. null safety, futures, streams), include concise inline explanation when helpful.
- Ask for clarification if a request is ambiguous regarding:
  - Target platform (mobile, web, desktop)
  - Runtime context (UI, background, service, CLI)

---

## Coding Style & Conventions

- Write **concise, declarative Dart code**.
- Favor **composition over inheritance**.
- Prefer **immutable data structures**.
- Keep functions focused on **a single responsibility** (ideally under 30 lines).
- Avoid abbreviations; use meaningful, descriptive names.

### Naming

- Classes: `PascalCase`
- Variables, methods, parameters: `camelCase`
- Files: `snake_case`
- Line length: **≤ 80 characters**

---

## Project Structure

- Follow the flutter case study guidelines (https://docs.flutter.dev/app-architecture/case-study)
- Assume a standard Flutter project layout:
  - Entry point: `lib/main.dart`
  - Development Entry point: `lib/main_development.dart`
- Separate concerns clearly:
  - UI (widgets, screens)
  - Domain (business logic)
  - Data (models, repositories, APIs, services)
  - utils
    - helpers, extensions, miscellaneous functions
- For large projects, organize **by feature** instead of by layer.

---

## Flutter Best Practices

- Widgets are immutable; rebuild UI instead of mutating state.
- Prefer `StatelessWidget` whenever possible.
- Break large `build()` methods into small private widgets.
- Use `const` constructors wherever possible.
- Use `ListView.builder` or slivers for large or dynamic lists.
- Never perform expensive work inside `build()`.

---

## State Management

- Separate **ephemeral UI state** from **application state**.
- Prefer built-in Flutter solutions:
  - `ValueNotifier` + `ValueListenableBuilder` for simple state
  - `ChangeNotifier` for shared or complex state
  - `FutureBuilder` for single async results
  - `StreamBuilder` for async event streams
- Use third-party state management libraries **only if explicitly requested**.
- Prefer **constructor-based dependency injection**.

---

## Navigation & Routing

- Prefer modern declarative routing:
  - `go_router` or `auto_route`
- Use `Navigator` only for short-lived or non-deep-linkable flows.
- Handle authentication redirects explicitly when routing.

---

## Async, Errors & Null Safety

- Use `async` / `await` consistently with proper error handling.
- Use `Future` for single async results and `Stream` for event sequences.
- Write **sound null-safe code**.
- Avoid `!` unless the value is provably non-null.
- Use exhaustive `switch` expressions whenever possible.
- Prefer custom exceptions for domain-specific failure cases.

---

## Dart Language Best Practices

- Follow **Effective Dart** guidelines.
- Use pattern matching and records where they improve clarity.
- Group related classes into the same library.
- Add documentation comments to **all public APIs** if the file is unclear.
- Avoid trailing comments.
- Use arrow functions for simple one-line expressions.

---

## Code Quality

- Keep business logic out of widgets.
- Anticipate and handle failure cases.
- Do not allow silent failures.
- Prefer simplicity to cleverness.
- Avoid deeply nested widget trees.

---

## Logging

- Do not use `print`.
- Prefer structured logging via `dart:developer` or a logging package like `logging`.

---

## Testing

- Write testable code by design.
- Prefer fakes or stubs over mocks.
- Follow Arrange–Act–Assert or Given–When–Then.
- Include:
  - Unit tests for domain logic
  - unit tests for data layer
  - Widget tests for UI
  - Integration tests for end-to-end flows

---

## Serialization & Data Handling

- Use `dart_mappable` for JSON encoding/decoding.
- Use `FieldRename.snake` for API compatibility.
- Abstract data sources behind repositories or services.

---

## UI, Layout & Theming

- Use `ThemeData` and Material 3 consistently.
- Support light and dark themes.
- Generate color palettes using `ColorScheme.fromSeed`.
- Centralize component theming.
- Use `ThemeExtension` for custom design tokens.
- Ensure layouts are responsive:
  - `LayoutBuilder`
  - `MediaQuery`
  - `Wrap`, `Expanded`, `Flexible` appropriately
- Provide error and loading states for network images.

---

## Accessibility (A11Y)

- Ensure sufficient color contrast (WCAG 2.1).
- Support dynamic text scaling.
- Use semantic labels (`Semantics` widget).
- Write UI that works with screen readers.

---

## Documentation

- Use Dart doc comments (`///`) for public APIs.
- Document **why**, not what.
- Write documentation for the reader.
- Use consistent terminology.
- Avoid redundant or obvious documentation.
- Include code examples where helpful.

---

Always prioritize:
✅ Clarity  
✅ Maintainability  
✅ Correctness  
✅ Flutter idioms  
✅ Modern Dart best practices
