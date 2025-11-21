<!-- markdownlint-disable MD041 -->

# Change Note

Improved router architecture in project templates using Riverpod providers and better state management patterns.

## Improvements 💪

- **Router architecture**: Updated all templates to use Riverpod providers for router management
  - Router renamed from `NeoRouter` to `AppRouter` for better naming consistency
  - Router accepts `Ref` parameter so that future features like authentication route guards can watch providers when needed

- **Sidebar template**: Improved sidebar layout implementation
  - Changed from `HookConsumerWidget` to `ConsumerWidget` (removed unnecessary hooks dependency)
  - Updated to use `AutoRouter` builder pattern for better router context access
  - Router context now accessed within builder function for proper scoping

- **Template consistency**: Both `simple` and `sidebar` templates now use the same router architecture pattern

# Internal Change Note

## Changes 🛠️

- Renamed router class from `NeoRouter` to `AppRouter` in sidebar template
- Added Riverpod provider for router using `@Riverpod` annotation with `keepAlive: true`
- Updated router to accept `Ref` parameter in constructor to enable future features like authentication route guards that need to watch providers
- Changed sidebar layout from `HookConsumerWidget` to `ConsumerWidget`
- Updated sidebar layout to use `AutoRouter` builder pattern instead of direct widget tree
- Updated router imports and usage in `main.dart` to use `routerProvider`
- Applied same router pattern to `simple` template for consistency
