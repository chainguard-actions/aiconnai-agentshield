<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.3** was hardened automatically. 15 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in action.yml. This includes attacker-controllable inputs (inputs.version, inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests) as well as runner.os, runner.arch, runner.temp, and steps.*.outputs.* — all of which flow through YAML template substitution before the shell sees them, enabling script injection. Sub-rule (a) violations:
- 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`
- 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in`
- 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`
- 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`
- 'Check result' step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`

Locations:

- `action.yml:57`
- `action.yml:65`
- `action.yml:75`
- `action.yml:93`
- `action.yml:101`
- `action.yml:130`

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in workflow files. Sub-rule (a) violations:
- action-e2e.yml 'Install binary' step: `mkdir -p ${{ runner.temp }}/agentshield`, `cp target/release/agentshield ${{ runner.temp }}/agentshield/`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`; and numerous subsequent steps use `${{ runner.temp }}/safe.sarif`, `${{ runner.temp }}/vuln.sarif`, etc. directly in run: blocks.
- release.yml 'Smoke check wrap command (windows)' step: `target\${{ matrix.target }}\release\agentshield.exe`; 'Package (unix)' step: `BINARY=target/${{ matrix.target }}/release/agentshield`, `ARCHIVE=agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz`; 'Package (windows)' step: `$BINARY = "target/${{ matrix.target }}/release/agentshield.exe"`, `$ARCHIVE = "agentshield-${{ github.ref_name }}-${{ matrix.target }}.zip"`

Locations:

- `.github/workflows/action-e2e.yml:33`
- `.github/workflows/action-e2e.yml:47`
- `.github/workflows/release.yml:57`
- `.github/workflows/release.yml:62`
- `.github/workflows/release.yml:72`

### github-env-injection (severity: high)

In action.yml, untrusted input values are written to special GitHub environment files without the required sanitization step (printf '%s' ... | tr -d '\n\r'):
1. 'Determine version' step: VERSION is set from ${{ inputs.version }} (attacker-controlled) and then written unsanitized to $GITHUB_OUTPUT via `echo "version=$VERSION" >> $GITHUB_OUTPUT`. A newline in inputs.version could inject additional key=value pairs into GITHUB_OUTPUT.
2. 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes a ${{ }} expression directly to $GITHUB_PATH without sanitization.

Locations:

- `action.yml:60`
- `action.yml:101`

### unpinned-uses (severity: high)

All uses: references across action.yml and workflow files use mutable tags or branch names instead of immutable 40-character SHA digests, making the action vulnerable to supply-chain attacks if any referenced action is compromised or its tag is moved.

action.yml:
- uses: github/codeql-action/upload-sarif@v3

.github/workflows/action-e2e.yml:
- uses: actions/checkout@v4
- uses: dtolnay/rust-toolchain@stable
- uses: Swatinem/rust-cache@v2
- uses: github/codeql-action/upload-sarif@v3

.github/workflows/ci.yml:
- uses: actions/checkout@v6
- uses: dtolnay/rust-toolchain@stable
- uses: Swatinem/rust-cache@v2

.github/workflows/docker.yml:
- uses: actions/checkout@v6
- uses: docker/login-action@v4
- uses: docker/metadata-action@v6
- uses: docker/setup-qemu-action@v4
- uses: docker/setup-buildx-action@v4
- uses: docker/build-push-action@v7

.github/workflows/release.yml:
- uses: actions/checkout@v6
- uses: dtolnay/rust-toolchain@stable
- uses: Swatinem/rust-cache@v2
- uses: actions/upload-artifact@v7
- uses: actions/download-artifact@v7
- uses: softprops/action-gh-release@v3

Locations:

- `action.yml:121`
- `.github/workflows/action-e2e.yml:22`
- `.github/workflows/action-e2e.yml:25`
- `.github/workflows/action-e2e.yml:26`
- `.github/workflows/action-e2e.yml:155`
- `.github/workflows/ci.yml:18`
- `.github/workflows/ci.yml:19`
- `.github/workflows/ci.yml:20`
- `.github/workflows/docker.yml:17`
- `.github/workflows/docker.yml:20`
- `.github/workflows/docker.yml:27`
- `.github/workflows/docker.yml:37`
- `.github/workflows/docker.yml:41`
- `.github/workflows/docker.yml:45`
- `.github/workflows/release.yml:36`
- `.github/workflows/release.yml:38`
- `.github/workflows/release.yml:41`
- `.github/workflows/release.yml:82`
- `.github/workflows/release.yml:91`
- `.github/workflows/release.yml:103`

### missing-permissions (severity: medium)

The ci.yml workflow has no top-level permissions: key and none of its four jobs (test, clippy, fmt, smoke) define job-level permissions. This means the workflow runs with the default GitHub token permissions, which may be overly broad (write access to contents and other scopes by default for non-fork contexts). Explicit minimal permissions should be declared.

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

Fixed all findings across action.yml and .github/workflows/*.yml:

1. script-injection + static-inline-injection (action.yml): Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks into env: blocks. Shell scripts now reference plain env vars ($INPUT_VERSION, $RUNNER_OS, $RUNNER_TEMP, etc.).

2. github-env-injection (action.yml): Added printf '%s' ... | tr -d '\n\r' sanitization before writing VERSION to $GITHUB_OUTPUT and RUNNER_TEMP path to $GITHUB_PATH.

3. script-injection (action-e2e.yml): Moved all ${{ runner.temp }} expressions from run: blocks to env: blocks (RUNNER_TEMP). Fixed Install binary, all test scan steps, and HTML report step.

4. script-injection (release.yml): Moved ${{ matrix.target }} and ${{ github.ref_name }} from run: blocks to env: blocks (MATRIX_TARGET, REF_NAME) in Smoke check, Package, and Build steps.

5. unpinned-uses: Pinned all 13 action references across action.yml, action-e2e.yml, ci.yml, docker.yml, and release.yml to their full 40-character SHA digests with tag comments.

6. missing-permissions (ci.yml): Added top-level `permissions: contents: read` block.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Replaced the unquoted string-concatenation approach (`ARGS="scan $INPUT_PATH"` ... `agentshield $ARGS`) with a bash array approach: `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")` with `ARGS+=(...)` for optional flags, and the final invocation `agentshield "${ARGS[@]}"`. Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG) is now double-quoted when added to the array, preventing word splitting, glob expansion, and command injection from attacker-controlled values.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed all three github-env-injection findings:
1. action.yml: Sanitized SARIF_FILE (built from runner.temp) before writing to GITHUB_OUTPUT using `safe_sarif=$(printf '%s' "$SARIF_FILE" | tr -d '\n\r')`.
2. action-e2e.yml: Sanitized RUNNER_TEMP path before writing to GITHUB_PATH using `safe_path=$(printf '%s' "$RUNNER_TEMP/agentshield" | tr -d '\n\r')`.
3. release.yml (unix): Sanitized ARCHIVE (built from github.ref_name and matrix.target) before writing to GITHUB_ENV using `safe_archive=$(printf '%s' "$ARCHIVE" | tr -d '\n\r')`.
4. release.yml (windows/PowerShell): Sanitized ARCHIVE before writing to GITHUB_ENV using `$SAFE_ARCHIVE = $ARCHIVE -replace '[\r\n]', ''`.

