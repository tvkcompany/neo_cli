<!-- markdownlint-disable MD041 -->

# Change Note

## New 🚀

- Added automatic configuration of `analysis_options.yaml` with Neo-specific settings in all created projects
- Updated Dart SDK requirement to `^3.9.0` (all created projects now require Dart 3.9.0 or later)

## Improvements 💪

- **Updated templates**: All templates now support the latest version of Neo
- **Improved gitignore**: Enhanced the generated `.gitignore` file in created projects
- **Project versioning**: All created projects now start with version `0.1.0`
- Simplified README with updated documentation links

## Removed ❌

- Removed platforms and template options from `config` command - please run `neo config` after updating to this version

# Internal Change Note

## Changes 🛠️

- Removed all release notes infrastructure including GitHub workflows
- Updated Dart SDK requirement to 3.9.0
- Updated package dependencies
- Updated `.gitignore` with latest patterns
- Set cursor rule to always apply
- Replaced old documentation URLs with new ones throughout the codebase
