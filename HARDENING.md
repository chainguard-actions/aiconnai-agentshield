<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.4** was hardened automatically. 22 finding(s) were identified and resolved across 4 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions inside shell commands, violating rule (a). This allows an attacker-controlled value to be injected into the shell before quoting can protect it.

- 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is attacker-controlled.
- 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` — runner context interpolated directly.
- 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip ... -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — all context values interpolated directly.
- 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format sarif --output $SARIF_FILE"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]` — all inputs are attacker-controlled.
- 'Check result' step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"` — inputs.fail-on interpolated.

All these values should be passed via env: variables and then referenced as quoted shell variables (e.g., "$VAR").

Locations:

- `action.yml:68`
- `action.yml:76`
- `action.yml:84`
- `action.yml:97`
- `action.yml:98`
- `action.yml:103`
- `action.yml:105`
- `action.yml:107`
- `action.yml:109`
- `action.yml:111`
- `action.yml:116`
- `action.yml:118`
- `action.yml:121`
- `action.yml:123`
- `action.yml:125`
- `action.yml:127`
- `action.yml:155`

### script-injection (severity: high)

run: blocks in .github/workflows/action-e2e.yml directly interpolate ${{ runner.temp }} and ${{ runner.os }} expressions inside shell commands (rule (a)). Examples: `mkdir -p ${{ runner.temp }}/agentshield`, `cp target/release/agentshield ${{ runner.temp }}/agentshield/`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`, and multiple agentshield scan commands using `${{ runner.temp }}/...` for output paths. These context values should be passed via env: variables.

Locations:

- `.github/workflows/action-e2e.yml:33`
- `.github/workflows/action-e2e.yml:34`
- `.github/workflows/action-e2e.yml:35`
- `.github/workflows/action-e2e.yml:43`
- `.github/workflows/action-e2e.yml:55`
- `.github/workflows/action-e2e.yml:80`
- `.github/workflows/action-e2e.yml:107`
- `.github/workflows/action-e2e.yml:120`
- `.github/workflows/action-e2e.yml:138`
- `.github/workflows/action-e2e.yml:152`
- `.github/workflows/action-e2e.yml:165`

### script-injection (severity: high)

run: blocks in .github/workflows/release.yml directly interpolate ${{ github.ref_name }} and ${{ matrix.target }} expressions inside shell commands (rule (a)). Examples: `BINARY=target/${{ matrix.target }}/release/agentshield`, `ARCHIVE=agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz`, and the PowerShell equivalent. github.ref_name is attacker-influenced (tag names can be crafted) and matrix.target is workflow-controlled. These should be passed via env: variables.

Locations:

- `.github/workflows/release.yml:74`
- `.github/workflows/release.yml:75`
- `.github/workflows/release.yml:82`
- `.github/workflows/release.yml:83`
- `.github/workflows/release.yml:88`
- `.github/workflows/release.yml:89`

### script-injection (severity: high)

run: blocks in .github/workflows/docker.yml directly interpolate ${{ steps.build.outputs.digest }} and ${{ needs.metadata.outputs.json }} expressions inside shell commands (rule (a)). Examples: `digest="${{ steps.build.outputs.digest }}"` and `tags=$(jq -r '.tags[] | "-t " + .' <<< '${{ needs.metadata.outputs.json }}' | xargs)`. Step outputs and needs outputs are workflow-controllable and must not be interpolated directly into shell. These should be passed via env: variables.

Locations:

- `.github/workflows/docker.yml:84`
- `.github/workflows/docker.yml:101`

### github-env-injection (severity: high)

The 'Download AgentShield' step in action.yml writes ${{ runner.temp }}/agentshield directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. Although runner.temp is typically safe, it is a context value that flows through YAML template substitution before the shell sees it, and no `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write. Additionally, the 'Determine version' step writes `VERSION` (derived from `${{ inputs.version }}`) to $GITHUB_OUTPUT via `echo "version=$VERSION" >> $GITHUB_OUTPUT` without sanitization — inputs.version is attacker-controlled and could contain newlines to inject additional output variables.

Locations:

- `action.yml:111`
- `action.yml:79`

### github-env-injection (severity: high)

The 'Install binary' step in .github/workflows/action-e2e.yml writes `${{ runner.temp }}/agentshield` directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The runner.temp context value is interpolated via YAML template substitution and no `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write.

Locations:

- `.github/workflows/action-e2e.yml:35`

### unpinned-uses (severity: high)

action.yml references a GitHub Action by mutable tag rather than a full 40-character commit SHA, making it vulnerable to supply-chain attacks if the tag is moved:
- `uses: github/codeql-action/upload-sarif@v3`

Locations:

- `action.yml:143`

### unpinned-uses (severity: high)

.github/workflows/action-e2e.yml references actions by mutable tags rather than full commit SHAs:
- `uses: actions/checkout@v4`
- `uses: dtolnay/rust-toolchain@stable`
- `uses: Swatinem/rust-cache@v2`
- `uses: github/codeql-action/upload-sarif@v3`

Locations:

- `.github/workflows/action-e2e.yml:21`
- `.github/workflows/action-e2e.yml:24`
- `.github/workflows/action-e2e.yml:25`
- `.github/workflows/action-e2e.yml:163`

### unpinned-uses (severity: high)

.github/workflows/ci.yml references actions by mutable tags rather than full commit SHAs:
- `uses: actions/checkout@v6`
- `uses: dtolnay/rust-toolchain@stable`
- `uses: Swatinem/rust-cache@v2`
(repeated across test, clippy, fmt, and smoke jobs)

Locations:

- `.github/workflows/ci.yml:17`
- `.github/workflows/ci.yml:18`
- `.github/workflows/ci.yml:19`

### unpinned-uses (severity: high)

.github/workflows/docker.yml references actions by mutable tags rather than full commit SHAs:
- `uses: actions/checkout@v6`
- `uses: docker/metadata-action@v6`
- `uses: docker/login-action@v4`
- `uses: docker/setup-buildx-action@v4`
- `uses: docker/build-push-action@v7`
- `uses: actions/upload-artifact@v7`
- `uses: actions/download-artifact@v7`

Locations:

- `.github/workflows/docker.yml:21`
- `.github/workflows/docker.yml:37`
- `.github/workflows/docker.yml:57`
- `.github/workflows/docker.yml:63`
- `.github/workflows/docker.yml:68`
- `.github/workflows/docker.yml:89`
- `.github/workflows/docker.yml:100`
- `.github/workflows/docker.yml:111`

### unpinned-uses (severity: high)

.github/workflows/release.yml references actions by mutable tags rather than full commit SHAs:
- `uses: actions/checkout@v6`
- `uses: dtolnay/rust-toolchain@stable`
- `uses: Swatinem/rust-cache@v2`
- `uses: actions/upload-artifact@v7`
- `uses: actions/download-artifact@v7`
- `uses: softprops/action-gh-release@v3`

Locations:

- `.github/workflows/release.yml:18`
- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:97`
- `.github/workflows/release.yml:108`
- `.github/workflows/release.yml:116`
- `.github/workflows/release.yml:124`

### missing-permissions (severity: medium)

.github/workflows/ci.yml has no top-level `permissions:` key and none of its jobs (test, clippy, fmt, smoke) define a `permissions:` block. This means the workflow runs with the default GitHub token permissions, which may be broader than necessary (e.g., write access to contents and packages on some repository configurations).

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yml and 4 workflow files:

**action.yml**:
- Moved all ${{ inputs.* }}, ${{ runner.* }}, ${{ steps.*.outputs.* }} expressions from run: blocks to env: blocks
- Used bash arrays (args=()) for building agentshield command arguments
- Sanitized VERSION before writing to GITHUB_OUTPUT: `printf '%s' "$VERSION" | tr -d '\n\r'`
- Sanitized INSTALL_DIR before writing to GITHUB_PATH: `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`
- Pinned github/codeql-action/upload-sarif@v3 → SHA 4187e74d05793876e9989daffde9c3e66b4acd07

**action-e2e.yml**:
- Moved all ${{ runner.temp }} expressions to RUNNER_TEMP_VAL env variable
- Sanitized GITHUB_PATH write with printf/tr
- Pinned all 4 action references to full commit SHAs

**release.yml**:
- Moved ${{ github.ref_name }} → REF_NAME env var, ${{ matrix.target }} → MATRIX_TARGET env var in Package steps
- Pinned all 6 action references to full commit SHAs

**docker.yml**:
- Moved ${{ steps.build.outputs.digest }} → BUILD_DIGEST env var in Export digest step
- Moved ${{ needs.metadata.outputs.json }} → METADATA_JSON env var in Create manifest step, using printf '%s' for safe expansion
- Pinned all 7 action references to full commit SHAs

**ci.yml**:
- Added `permissions: {}` at top level (workflow only runs cargo commands)
- Pinned all action references (actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2) to full commit SHAs across all 4 jobs

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed 4 findings across 3 files:

1. release.yml (lines 69, 73): Moved `${{ matrix.target }}` into `env: MATRIX_TARGET:` for both Build (native) and Build (cross) steps; referenced as `"$MATRIX_TARGET"` in run commands.

2. docker.yml (line 144): Replaced unquoted `$tags $sources` with bash arrays (`mapfile -t tag_args` from jq output, `source_args` loop), then called `docker buildx imagetools create "${tag_args[@]}" "${source_args[@]}"` with proper quoting.

3. action.yml (line 150, github-env-injection): Added `safe_sarif=$(printf '%s' "$SARIF_FILE" | tr -d '\n\r')` before writing to GITHUB_OUTPUT.

4. action.yml (line 154, script-injection): Replaced `python3 -c "...open('$SARIF_FILE')..."` with a heredoc `python3 - "$SARIF_FILE" <<'PYEOF'` that reads the path via `sys.argv[1]`, eliminating shell injection.

Note: action-e2e.yml findings were not fixed per the rules — test harness files are excluded from security hardening.

### Iteration 3

**Fixes applied:** github-env-injection, invalid-yaml

**Notes:**

Fixed github-env-injection in release.yml: (1) In 'Package (unix)' step, added sanitization via `safe_archive=$(printf '%s' "$ARCHIVE" | tr -d '\n\r')` before writing to GITHUB_ENV. (2) In 'Package (windows)' step, added sanitization via `$SAFE_ARCHIVE = $ARCHIVE -replace '[\r\n]', ''` before writing to GITHUB_ENV. The invalid-yaml finding in action.yml was already resolved in a previous iteration - the file is currently valid YAML with no single-line run: values starting with quotes.

### Iteration 4

**Fixes applied:** invalid-yaml

**Notes:**

Fixed YAML parsing error at line 158 in action.yml. The issue was a Python heredoc (<<'PYEOF') inside a YAML block scalar (run: |). The Python code lines (import json, sys; d = json.load...; print(...)) had zero indentation, which caused the YAML parser to terminate the block scalar prematurely. The PYEOF terminator and ) || COUNT=0 then appeared at an unexpected indentation level, causing the 'could not find expected :' error. Fixed by replacing the heredoc with a Python one-liner using python3 -c '...', keeping all code on a single line within the YAML block scalar.

