<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.6** was hardened automatically. 23 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Determine version' step directly interpolates ${{ inputs.version }} inside a run: shell command (e.g., `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`). The 'Determine platform' step interpolates ${{ runner.os }} and ${{ runner.arch }} directly in a case statement. The 'Download AgentShield' step interpolates ${{ steps.version.outputs.version }}, ${{ steps.platform.outputs.target }}, and ${{ runner.temp }} directly in shell commands. The 'Run scan' step interpolates ${{ inputs.path }}, ${{ inputs.fail-on }}, ${{ inputs.format }}, ${{ inputs.config }}, ${{ inputs.ignore-tests }}, and ${{ runner.temp }} directly in shell commands. The 'Check result' step interpolates ${{ inputs.fail-on }} directly. All of these are sub-rule (a) violations — any ${{ ... }} expression inside a run: block is a script-injection risk regardless of context.

Locations:

- `action.yml:55`
- `action.yml:60`
- `action.yml:69`
- `action.yml:75`
- `action.yml:80`
- `action.yml:81`
- `action.yml:86`
- `action.yml:89`
- `action.yml:90`
- `action.yml:92`
- `action.yml:93`
- `action.yml:99`
- `action.yml:100`
- `action.yml:102`
- `action.yml:103`
- `action.yml:106`
- `action.yml:109`
- `action.yml:110`
- `action.yml:113`
- `action.yml:131`

### script-injection (severity: high)

The 'Install binary' step in action-e2e.yml directly interpolates ${{ runner.temp }} in multiple shell commands: `mkdir -p ${{ runner.temp }}/agentshield`, `cp target/release/agentshield ${{ runner.temp }}/agentshield/`, and `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. Multiple test steps also interpolate ${{ runner.temp }} directly in run: blocks (e.g., `--output ${{ runner.temp }}/safe.sarif`). Sub-rule (a) violation.

Locations:

- `.github/workflows/action-e2e.yml:33`
- `.github/workflows/action-e2e.yml:34`
- `.github/workflows/action-e2e.yml:35`
- `.github/workflows/action-e2e.yml:46`
- `.github/workflows/action-e2e.yml:57`
- `.github/workflows/action-e2e.yml:75`
- `.github/workflows/action-e2e.yml:93`
- `.github/workflows/action-e2e.yml:110`
- `.github/workflows/action-e2e.yml:124`
- `.github/workflows/action-e2e.yml:137`
- `.github/workflows/action-e2e.yml:152`
- `.github/workflows/action-e2e.yml:163`
- `.github/workflows/action-e2e.yml:165`
- `.github/workflows/action-e2e.yml:167`

### script-injection (severity: high)

The 'Export digest' step in docker.yml directly interpolates ${{ steps.build.outputs.digest }} in a run: block: `digest="${{ steps.build.outputs.digest }}"`). The 'Create and push manifest list' step directly interpolates ${{ needs.metadata.outputs.json }} in a run: block: `tags=$(jq -r '.tags[] | "-t " + .' <<< '${{ needs.metadata.outputs.json }}' | xargs)`. Both are sub-rule (a) violations.

Locations:

- `.github/workflows/docker.yml:80`
- `.github/workflows/docker.yml:107`

### script-injection (severity: high)

The 'Package (unix)' step in release.yml directly interpolates ${{ matrix.target }} and ${{ github.ref_name }} in a run: block: `BINARY=target/${{ matrix.target }}/release/agentshield` and `ARCHIVE=agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz`. The 'Package (windows)' PowerShell step similarly interpolates these values. Sub-rule (a) violations.

Locations:

- `.github/workflows/release.yml:72`
- `.github/workflows/release.yml:73`
- `.github/workflows/release.yml:84`
- `.github/workflows/release.yml:85`

### github-env-injection (severity: high)

In the 'Determine version' step, VERSION is derived from ${{ inputs.version }} (an untrusted input) and written to $GITHUB_OUTPUT without sanitization: `echo "version=$VERSION" >> $GITHUB_OUTPUT`. In the 'Download AgentShield' step, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes a runner context value directly to $GITHUB_PATH without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

Locations:

- `action.yml:63`
- `action.yml:93`

### github-env-injection (severity: high)

In the 'Install binary' step of action-e2e.yml, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes a runner context value directly to $GITHUB_PATH without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

Locations:

- `.github/workflows/action-e2e.yml:35`

### github-env-injection (severity: high)

In the 'Package (unix)' step of release.yml, ARCHIVE is set to `agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz` (containing github.ref_name, a workflow-controlled value) and then written to $GITHUB_ENV without sanitization: `echo "ARCHIVE=$ARCHIVE" >> $GITHUB_ENV`. Similarly, the 'Package (windows)' PowerShell step writes `"ARCHIVE=$ARCHIVE" | Out-File -Append -Encoding ascii $env:GITHUB_ENV` where ARCHIVE contains ${{ github.ref_name }}.

Locations:

- `.github/workflows/release.yml:76`
- `.github/workflows/release.yml:89`

### unpinned-uses (severity: high)

The action uses github/codeql-action/upload-sarif@v3 (tag, not a SHA digest). All uses: references must be pinned to a full 40-character commit SHA to prevent supply-chain attacks.

Locations:

- `action.yml:121`

### unpinned-uses (severity: high)

Multiple unpinned uses: references found in action-e2e.yml: actions/checkout@v4, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, github/codeql-action/upload-sarif@v3. All use tags or branch names instead of full 40-character commit SHAs.

Locations:

- `.github/workflows/action-e2e.yml:24`
- `.github/workflows/action-e2e.yml:27`
- `.github/workflows/action-e2e.yml:28`
- `.github/workflows/action-e2e.yml:183`

### unpinned-uses (severity: high)

Multiple unpinned uses: references found in ci.yml: actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2. All use tags or branch names instead of full 40-character commit SHAs.

Locations:

- `.github/workflows/ci.yml:18`
- `.github/workflows/ci.yml:19`
- `.github/workflows/ci.yml:20`
- `.github/workflows/ci.yml:27`
- `.github/workflows/ci.yml:30`
- `.github/workflows/ci.yml:31`
- `.github/workflows/ci.yml:38`
- `.github/workflows/ci.yml:44`
- `.github/workflows/ci.yml:45`
- `.github/workflows/ci.yml:46`

### unpinned-uses (severity: high)

Multiple unpinned uses: references found in docker.yml: actions/checkout@v6, docker/metadata-action@v6, docker/login-action@v4, docker/setup-buildx-action@v4, docker/build-push-action@v7, actions/upload-artifact@v7, actions/download-artifact@v7. All use tags instead of full 40-character commit SHAs.

Locations:

- `.github/workflows/docker.yml:18`
- `.github/workflows/docker.yml:27`
- `.github/workflows/docker.yml:40`
- `.github/workflows/docker.yml:56`
- `.github/workflows/docker.yml:59`
- `.github/workflows/docker.yml:63`
- `.github/workflows/docker.yml:75`
- `.github/workflows/docker.yml:80`
- `.github/workflows/docker.yml:91`
- `.github/workflows/docker.yml:100`
- `.github/workflows/docker.yml:107`
- `.github/workflows/docker.yml:111`

### unpinned-uses (severity: high)

Multiple unpinned uses: references found in release.yml: actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, actions/upload-artifact@v7, actions/download-artifact@v7, softprops/action-gh-release@v3, docker/setup-qemu-action@v3, docker/setup-buildx-action@v3, docker/login-action@v3, docker/build-push-action@v6. All use tags or branch names instead of full 40-character commit SHAs.

Locations:

- `.github/workflows/release.yml:22`
- `.github/workflows/release.yml:37`
- `.github/workflows/release.yml:40`
- `.github/workflows/release.yml:44`
- `.github/workflows/release.yml:95`
- `.github/workflows/release.yml:102`
- `.github/workflows/release.yml:113`
- `.github/workflows/release.yml:121`
- `.github/workflows/release.yml:126`
- `.github/workflows/release.yml:130`
- `.github/workflows/release.yml:136`
- `.github/workflows/release.yml:145`
- `.github/workflows/release.yml:155`

### missing-permissions (severity: medium)

ci.yml has no top-level permissions: key and none of its four jobs (test, clippy, fmt, smoke) define a job-level permissions: block. Without explicit permissions, the workflow inherits the default repository permissions, which may be overly broad (write access to contents and other scopes). A permissions: block with minimal required scopes should be added.

Locations:

- `.github/workflows/ci.yml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:57`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:64`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.path }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:108`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:111`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:115`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:118`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:119`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.ignore-tests }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:122`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Check result"; move to env: map

Locations:

- `action.yml:157`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all findings across action.yml and .github/workflows/{action-e2e.yml,docker.yml,release.yml,ci.yml}:

1. script-injection/static-inline-injection: Moved all ${{ }} expressions from run: blocks into env: blocks in action.yml (inputs.version, runner.os, runner.arch, steps.version.outputs.version, steps.platform.outputs.target, runner.temp, inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests), action-e2e.yml (runner.temp), docker.yml (steps.build.outputs.digest, needs.metadata.outputs.json), and release.yml (matrix.target, github.ref_name).

2. github-env-injection: Sanitized all writes to GITHUB_OUTPUT, GITHUB_PATH, and GITHUB_ENV using `printf '%s' "$VAR" | tr -d '\n\r'` in action.yml (version output, GITHUB_PATH write), action-e2e.yml (GITHUB_PATH write), and release.yml (ARCHIVE written to GITHUB_ENV in both bash and PowerShell steps).

3. unpinned-uses: Pinned all action references to full 40-character commit SHAs in action.yml, action-e2e.yml, docker.yml, release.yml, and ci.yml. Actions pinned: actions/checkout@v4, actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, github/codeql-action/upload-sarif@v3, docker/metadata-action@v6, docker/login-action@v4, docker/setup-buildx-action@v4, docker/build-push-action@v7, actions/upload-artifact@v7, actions/download-artifact@v7, softprops/action-gh-release@v3, docker/setup-qemu-action@v3, docker/setup-buildx-action@v3, docker/login-action@v3, docker/build-push-action@v6.

4. missing-permissions: Added top-level `permissions: contents: read` to ci.yml.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed two high-severity findings in the 'Run scan' step of hardened/action/action.yml:

1. script-injection: Replaced the string-concatenation $ARGS pattern with a bash array (ARGS=(...)). Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG) is now added as a separate double-quoted array element via ARGS+=("--flag" "$VALUE"). The command is invoked as `agentshield "${ARGS[@]}"`, preventing word-splitting and shell metacharacter injection.

2. github-env-injection: Added sanitization of the SARIF_FILE value before writing to $GITHUB_OUTPUT. Used `safe_sarif=$(printf '%s' "$SARIF_FILE" | tr -d '\n\r')` and then wrote `echo "sarif-file=$safe_sarif" >> $GITHUB_OUTPUT`, stripping any embedded newlines that could inject additional key=value pairs into GITHUB_OUTPUT.

### Iteration 3

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed three security findings:
1. release.yml (lines 70, 74, 79, 85) - script-injection: Added `env: MATRIX_TARGET: ${{ matrix.target }}` to Build (native), Build (cross), Smoke check (unix), and Smoke check (windows) steps. Replaced all direct `${{ matrix.target }}` interpolations in run: blocks with `"$MATRIX_TARGET"` (bash) or `$env:MATRIX_TARGET` (PowerShell).
2. docker.yml (line 136) - script-injection: Replaced unquoted `$tags $sources` expansion with bash arrays built via `mapfile -t tag_args` and `mapfile -t source_args`, then safely expanded with `"${tag_args[@]}" "${source_args[@]}"` to prevent word-splitting and shell metacharacter injection from untrusted needs.*.outputs.* values.
3. release.yml (line 148) - github-env-injection: Added `safe=$(printf '%s' "$version" | tr -d '\n\r')` sanitization step before writing to GITHUB_OUTPUT, preventing newline injection via a crafted git tag name.

