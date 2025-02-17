# Emergency Rollback Procedure

This document outlines the procedure for performing an emergency rollback when a critical issue is discovered in production that requires immediate reversion to a previous stable version.

## When to Use Emergency Rollback

Use this procedure when:

- A critical bug or security vulnerability is discovered in production
- The issue is severe enough that it needs to be addressed immediately
- A hotfix is not feasible or would take too long to implement safely
- You need to restore system stability quickly

## Rollback Process

### 1. Preparation

1. Identify the last known stable version tag (e.g., `1.3.5`)
2. Notify the team about the emergency rollback
3. Document the current issue that necessitates the rollback

### 2. Creating the Rollback Release

1. Checkout the production branch:

   ```bash
   git checkout production
   ```

2. Fetch all tags:

   ```bash
   git fetch --all --tags
   ```

3. Checkout the last known stable version tag:

   ```bash
   git checkout tags/1.3.5  # Replace with actual stable version
   ```

4. Create a new release branch with an incremented version number:

   ```bash
   git checkout -b release/1.4.1  # Version should be higher than current problematic version
   ```

### 3. Documentation

1. Update the automatically created release note with a clear, user-facing message:

   ```markdown
   <!-- markdownlint-disable MD041 -->

   ## 🚨 Emergency Rollback 🚨

   This version reverts back to the functionality of version {STABLE_VERSION}. Our team is actively working on resolving the issues introduced in {PROBLEMATIC_VERSION} and will release an update as soon as possible.

   We apologize for any inconvenience and appreciate your patience.
   ```

2. Add minimal but crucial information to the automatically created internal release note:
   - Brief description of the critical issue triggering the rollback
   - Which version we're rolling back to
   - Who authorized the rollback

   [!TIP] Focus on releasing first. You can always update the internal release notes later with more details by creating a feature branch, pushing to development, and letting it flow to production through the normal process.

### 4. Release Process

Follow the standard release process as documented in [Development & Release Workflow](./development_and_release_workflow.md)

### 5. Post-Rollback Actions

1. Monitor system stability after rollback
2. Send communications to:
   - Teams like Development, Product, etc.
   - End users (if external communication is required)
3. Fix the original issue:
   - Investigate the root cause
   - Develop a proper fix
   - Address any technical debt created by the rollback
4. Schedule a post-mortem meeting to:
   - Review the incident
   - Plan prevention measures
   - Document lessons learned

## Why This Approach?

While some might expect a rollback to simply revert to a previous version number, we deliberately use a forward-moving version number (e.g., going from 1.4.0 to 1.4.1 even when rolling back to 1.3.5 code) for several important reasons:

### Package Manager Compatibility

- Package managers like Homebrew and Scoop expect version numbers to always increase
- These package managers cache versions and don't handle rollbacks to previous versions well
- Attempting to republish an older version can lead to caching issues and failed installations
- Using a forward-moving version ensures reliable distribution through our package managers

### Dependency Management

- Rolling back to an older version number can cause conflicts in dependent projects
- Forward version numbers maintain compatibility with semantic versioning expectations

### Clear Audit Trail

- Each version, even if it contains older code, gets its own unique version number
- This creates a clear historical record of when and why rollbacks occurred
- Makes it easier to track the actual sequence of releases in production

This approach prioritizes practical deployment needs and system compatibility over theoretical version purity, ensuring our rollbacks can be quickly and safely deployed across all platforms and environments.

## Version Number Examples

```text
Previous release:       1.3.5
Problematic release:    1.4.0
Rollback release:       1.4.1 (contains code from 1.3.5)
Fixed release:          1.4.2 (contains code from 1.4.1 + fix)
```

## Important Notes

- The version number always moves forward (e.g., 1.4.1) even though we're rolling back to older code (1.3.5)
- This maintains version number consistency and avoids confusion in dependency management
- Always clearly document in release notes that this is a rollback and which version it reverts to
- Consider this a temporary measure while a proper fix is developed
- Keep the problematic version documented for future reference

## Related Documentation

- [Development & Release Workflow](./development_and_release_workflow.md)
- [Hotfix Process](./development_and_release_workflow.md#hotfix-process)
