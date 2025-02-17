<!-- markdownlint-disable MD033 MD041 MD024-->

<div align="center">
    <img src="docs/images/neo_cli_logo.png" alt="Neo CLI Logo" height="128">
</div>

# Neo CLI

The Neo Command Line Interface (CLI for short) is the gateway to using [Neo](https://github.com/tvkcompany/neo/blob/production/README.md).

## Getting Started

### Prerequisites

Before installing the Neo CLI, make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed and properly set up on your system.

<details>

<summary>MacOS</summary>

### Installation

Install the Neo CLI using [Homebrew](https://brew.sh):

```bash
brew install tvkcompany/neo/neo
```

### Updating

When a new version is [released](https://github.com/tvkcompany/neo_cli/releases), you can update the Neo CLI using:

```bash
brew upgrade neo
```

> 💡 TIP: You can check if there is a new version available by running `brew outdated neo`.

### Uninstalling

```bash
brew uninstall neo
brew untap tvkcompany/neo
```

</details>

---

<details>

<summary>Windows</summary>

### Installation

Install the Neo CLI using [Scoop](https://scoop.sh):

```powershell
scoop bucket add neo https://github.com/tvkcompany/scoop-neo.git
scoop install neo
```

### Updating

When a new version is [released](https://github.com/tvkcompany/neo_cli/releases), you can update the Neo CLI using:

```powershell
scoop update neo
```

> 💡 TIP: You can check if there are any updates available by running `scoop status`.

### Uninstalling

```powershell
scoop uninstall neo
scoop bucket rm neo
```

</details>

---

<details>

<summary>Linux</summary>

### Installation

Install the Neo CLI using [Homebrew](https://brew.sh):

```bash
brew install tvkcompany/neo/neo
```

### Updating

When a new version is [released](https://github.com/tvkcompany/neo_cli/releases), you can update the Neo CLI using:

```bash
brew upgrade neo
```

> 💡 TIP: You can check if there is a new version available by running `brew outdated neo`.

### Uninstalling

```bash
brew uninstall neo
brew untap tvkcompany/neo
```

</details>

---

After installation, you can verify that the Neo CLI is working by running:

```bash
neo --version
```

## Usage

For information about using the Neo CLI, please visit the [Neo documentation](https://github.com/tvkcompany/neo/blob/production/docs/README.md).
