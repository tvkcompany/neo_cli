<!-- markdownlint-disable MD041 -->

# Change Note

N/A

# Internal Change Note

## Changes 🛠️

- The `build_artifacts.yml` workflow now dynamically uses the latest compatible Dart SDK version based on `pubspec.yaml` constraints (e.g., with `sdk: ^3.6.1`, it uses the latest stable `3.x.x` release)
