<!-- markdownlint-disable MD041 -->

# Change Note

Template updates for Neo 1.6.0 compatibility and template builder improvements.

## Improvements 💪

- **Sidebar template**: Updated to use Neo 1.6.0 API by removing deprecated `activeItem` and `setActiveItem()` usage
  - Removed `MyObserver` router observer class
  - Updated sidebar layout to use route-based active state detection via `router.currentPath`
  - Changed `buildSidebarButton` to use `routePrefix` parameter for determining active state
  - Sidebar buttons now automatically determine active state based on current route path

# Internal Change Note

## Changes 🛠️

- Updated `template_builder.dart` to escape `${}` sequences when reading template files: `content.replaceAll(r'${', r'\${')`
- Removed `MyObserver` class from sidebar template router file
- Updated sidebar layout to use `router.currentPath.toLowerCase()` and route prefix matching instead of local state management
- Removed unused imports (`flutter_hooks`, `hooks_riverpod` from router observer) from sidebar template files
