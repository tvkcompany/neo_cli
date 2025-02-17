<!-- markdownlint-disable MD024 -->

# Setup and Maintenance

## Initial Setup

### Overview

When setting up the Neo CLI development environment for the first time, follow these steps to configure it correctly.

### Steps

1. Clone the repository to your local machine.
2. Open your terminal and navigate to the project directory.
3. Run the following command to install the necessary dependencies:

    ```bash
    dart pub get
    ```

   This command ensures that all dependencies specified in `pubspec.yaml` are correctly installed.

## Routine Updates After Pulling Changes

After pulling changes from the repository, it's crucial to update your project dependencies to maintain compatibility and functionality with the latest project updates. In some editors & IDEs, such as VSCode with the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) installed, dependency updates may occur automatically after pulling changes. If not, follow steps 2 and 3 again.

## Automatic Script in VSCode-Compatible Editors

For users of VSCode-compatible editors (such as VSCode or Cursor), we have created a script to run `dart pub outdated` automatically whenever the project folder is opened. This way, you can see if there are any outdated dependencies every time you open your editor and update them manually if needed.

## Running the CLI Locally

During development, you can run the CLI directly from the source code using the `dart run` command. Here are some examples:

```bash
# You can run any CLI command using this pattern
dart run bin/neo_cli.dart [command] [options]

# For example, to list the configuration
dart run bin/neo_cli.dart config --list
```

This allows you to test your changes immediately without having to build and install the CLI globally.
