# Development & Release Workflow

This document outlines the development workflow and release process for the Neo CLI, including branch structure, merging strategies, and automated processes.

## Branch Structure

The Neo CLI uses the following branch structure:

- **Production** (`production`): Main branch containing currently released stable code
- **Development** (`development`): Integration branch for collecting features & fixes and internal testing (alpha)
- **Feature Branches** (`add/feature-name`, `imp/feature-name`, `fix/feature-name`): Used for new features, improvements, or fixes, respectively
- **Release Branches** (`release/x.y.z`): For "freezing" code from `development` and preparing a release
- **Hotfix Branches** (`hotfix/fix-name`): For critical fixes to `production` that need immediate release

## Version Tagging

We follow [semantic versioning](https://semver.org/) with the following tag structure:

- Beta/RC releases: `x.y.z-beta.n` or `x.y.z-rc.n`
- Stable releases: `x.y.z`

## Workflow

### Feature Development

1. Create a feature branch from `development` using the appropriate prefix:
   - `add/` for new features
   - `imp/` for improvements
   - `fix/` for bug fixes
2. Develop and test the feature
3. Create a pull request to `development`
   - Automated tests and documentation generation will run
   - Update the automatically created change note in [`change_notes/PR_{id}_{branch-name}.md`](./change_notes/) with:
     - User-facing changes like features, improvements, or fixes visible to end users
     - Internal changes like technical modifications, refactoring, or other developer-focused updates
   - Push the updated change note to the feature branch (it will be included in the PR)
   - Code review required
4. Merge only when feature is complete and approved

> **Note**: Change notes serve as a crucial record for release documentation. They will be used as reference when writing release notes, providing a comprehensive overview of both user-facing and internal changes. During the release process, a GitHub Action automatically cleans up change notes, removing only those that were in the development branch at the time of release branch creation. Any change notes from features merged after the release branch was created will be preserved for the next release.

### Release Steps

1. **Alpha Testing** (on `development`)
   - Features are tested internally
   - Continuous integration runs tests on all PRs
   - Every merge into `development` triggers automatic build and deployment to development environment

2. **Release Preparation**
   - Create a release branch (`release/x.y.z`) from `development` and immediately push it
   - Open a pull request from the release branch to `production` - this triggers the automated release preparations
   - The change notes will be automatically cleaned up when opening the PR. While this early cleanup isn't ideal, it's currently the most practical solution since there isn't a way to remove the notes after closing the PR but before the first commit. Don't worry though - you can still reference the change notes while writing release notes by checking the git history, and they're easily accessible from the PR by clicking on the relevant commits
   - Update the automatically created release note in [`docs/release_notes/{version}.md`](../release_notes/) with user-facing changes like new features, improvements, or fixes visible to end users
   - Update the automatically created internal release note in [`docs/dev/internal_release_notes/{version}.md`](./internal_release_notes/) with internal changes like technical modifications, refactoring, or other developer-focused updates
   - Review and edit the release notes
   - Apply only critical fixes to the release branch

3. **Release Execution**
   - Branch naming:
     - Pre-release: `release/x.y.z-beta.1` or `release/x.y.z-rc.1`
     - Stable: `release/x.y.z`
   - Merge to `production` triggers:
     - Artifact builds for macOS (Universal), Windows (AMD64), and Linux (AMD64/ARM64)
     - Creation of a Git tag and GitHub release with:
       - Release notes
       - Release assets
     - Homebrew formula and Scoop manifest updates with new version and checksums
     - Automatic merge of `production` back into `development` to keep branches in sync
     - Cleanup of the release branch

### Hotfix Process

1. Create `hotfix/fix-name` branch from `production`
2. Implement and test the fix
3. Create release branch (`release/x.y.z`) from hotfix
   - Increment the patch version (1.2.3 → 1.2.4)
   - In rare cases where breaking changes are unavoidable, increment minor version instead
4. Follow normal release process

### Emergency Rollback

For severe issues requiring immediate reversion to a previous stable version, follow the [Emergency Rollback Procedure](./emergency_rollback_procedure.md).

## Best Practices

### Local Commit Management

- **Amending/Squashing Rules:**
  - ✅ Allowed ONLY for local changes that haven't been pushed
  - ❌ NEVER rewrite history that has already been pushed to remote - this will cause conflicts

- **Best Practices:**
  - Use commit amending for quick fixes like typos in the most recent commit
  - Squash multiple small commits before pushing if they represent a single logical change
  - Keep commits separate if they represent distinct, meaningful changes

### General Guidelines

- Keep feature branches focused and short-lived
- Regularly merge `development` back into your feature branches to keep them up to date
- Write clear, descriptive commit messages in past tense (unlike the conventional present tense). This makes git logs and history more readable:
  - "Added animation to button"
  - "Improved sign-in screen"
  - "Fixed render bug"
- Add unit tests for new features and bug fixes where needed
- Update change notes as features are added
- Follow the pull request template guidelines
- Ensure all tests pass before merging
