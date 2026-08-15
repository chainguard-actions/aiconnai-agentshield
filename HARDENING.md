<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.7** was hardened automatically. 25 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in action.yml, violating rule (a). This includes attacker-controllable inputs.* values and runner.* context values that flow through YAML template substitution before the shell sees them.

- 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`
- 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` and the error echo
- 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`
- 'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`
- 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`

Locations:

- `action.yml:64`
- `action.yml:72`
- `action.yml:76`
- `action.yml:82`
- `action.yml:88`
- `action.yml:89`
- `action.yml:95`
- `action.yml:98`
- `action.yml:99`
- `action.yml:101`
- `action.yml:102`
- `action.yml:115`
- `action.yml:127`
- `action.yml:128`
- `action.yml:131`
- `action.yml:132`
- `action.yml:134`
- `action.yml:136`
- `action.yml:139`
- `action.yml:141`
- `action.yml:144`

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in .github/workflows/action-e2e.yml, violating rule (a). The 'Install binary' step uses `${{ runner.temp }}` directly in shell commands: `mkdir -p ${{ runner.temp }}/agentshield`, `cp target/release/agentshield ${{ runner.temp }}/agentshield/`, and `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. Additional steps use `${{ runner.temp }}` in agentshield scan commands and SARIF file paths throughout the workflow.

Locations:

- `.github/workflows/action-e2e.yml:35`
- `.github/workflows/action-e2e.yml:36`
- `.github/workflows/action-e2e.yml:37`

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in .github/workflows/release.yml, violating rule (a).

- 'Build (native)' step: `cargo build --release --target ${{ matrix.target }} --features full`
- 'Build (cross)' step: `cross build --release --target ${{ matrix.target }} --features full`
- 'Smoke check wrap command (unix)' step: `target/${{ matrix.target }}/release/agentshield --help | grep wrap`
- 'Smoke check wrap command (windows)' step: `target\\${{ matrix.target }}\\release\\agentshield.exe --help | Select-String wrap`
- 'Package (unix)' step: `BINARY=target/${{ matrix.target }}/release/agentshield` and `ARCHIVE=agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz`
- 'Package (windows)' step: `$BINARY = "target/${{ matrix.target }}/release/agentshield.exe"` and `$ARCHIVE = "agentshield-${{ github.ref_name }}-${{ matrix.target }}.zip"`

Locations:

- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:59`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:67`
- `.github/workflows/release.yml:68`
- `.github/workflows/release.yml:74`
- `.github/workflows/release.yml:75`

### script-injection (severity: high)

In .github/workflows/docker.yml, the 'Create and push manifest list' step interpolates `${{ needs.metadata.outputs.json }}` directly inside a run: shell command string, violating rule (a): `tags=$(jq -r '.tags[] | "-t " + .' <<< '${{ needs.metadata.outputs.json }}' | xargs)`. The needs.metadata.outputs.json value flows through YAML template substitution before the shell processes it.

Locations:

- `.github/workflows/docker.yml:95`

### github-env-injection (severity: high)

In action.yml, multiple steps write values derived from untrusted inputs or ${{ }} expressions to special environment files without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is derived from `${{ inputs.version }}` (attacker-controlled), written without sanitization.
2. 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — a ${{ }} expression is written directly to GITHUB_PATH without sanitization.
3. 'Run scan' step: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is derived from `${{ runner.temp }}` and `${{ inputs.format }}`, written without sanitization.

Locations:

- `action.yml:73`
- `action.yml:102`
- `action.yml:148`

### github-env-injection (severity: high)

In .github/workflows/action-e2e.yml, the 'Install binary' step writes `${{ runner.temp }}/agentshield` directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The ${{ runner.temp }} expression is interpolated via YAML template substitution before the shell writes it to the path file.

Locations:

- `.github/workflows/action-e2e.yml:37`

### github-env-injection (severity: high)

In .github/workflows/release.yml, the 'Package (unix)' step writes `ARCHIVE=$ARCHIVE` to $GITHUB_ENV without sanitization, where ARCHIVE is derived from `${{ github.ref_name }}` and `${{ matrix.target }}` (both interpolated directly in the run block): `echo "ARCHIVE=$ARCHIVE" >> $GITHUB_ENV`. The 'Package (windows)' step similarly writes `ARCHIVE=$ARCHIVE` to $env:GITHUB_ENV via PowerShell. The 'Derive Docker version tag' step writes `version=$version` to $GITHUB_OUTPUT where version is derived from the inherited env var $GITHUB_REF_NAME without sanitization.

Locations:

- `.github/workflows/release.yml:70`
- `.github/workflows/release.yml:79`
- `.github/workflows/release.yml:121`

### unpinned-uses (severity: high)

action.yml uses a mutable tag reference instead of a pinned SHA commit hash: `uses: github/codeql-action/upload-sarif@v4`. This is vulnerable to supply-chain attacks if the tag is moved.

Locations:

- `action.yml:163`

### unpinned-uses (severity: high)

Multiple unpinned uses: references in .github/workflows/ci.yml — all use mutable tags/branch names instead of pinned 40-character SHA commit hashes:
- `uses: actions/checkout@v6` (multiple jobs)
- `uses: dtolnay/rust-toolchain@stable` (multiple jobs)
- `uses: Swatinem/rust-cache@v2` (multiple jobs)

Locations:

- `.github/workflows/ci.yml:23`
- `.github/workflows/ci.yml:24`
- `.github/workflows/ci.yml:25`
- `.github/workflows/ci.yml:30`
- `.github/workflows/ci.yml:31`
- `.github/workflows/ci.yml:34`
- `.github/workflows/ci.yml:38`
- `.github/workflows/ci.yml:39`
- `.github/workflows/ci.yml:42`
- `.github/workflows/ci.yml:47`
- `.github/workflows/ci.yml:48`
- `.github/workflows/ci.yml:49`

### unpinned-uses (severity: high)

Multiple unpinned uses: references in .github/workflows/docker.yml — all use mutable tags instead of pinned 40-character SHA commit hashes:
- `uses: actions/checkout@v6`
- `uses: docker/metadata-action@v6`
- `uses: docker/login-action@v4` (multiple)
- `uses: docker/setup-buildx-action@v4` (multiple)
- `uses: docker/build-push-action@v7`
- `uses: actions/upload-artifact@v7`
- `uses: actions/download-artifact@v7`

Locations:

- `.github/workflows/docker.yml:22`
- `.github/workflows/docker.yml:37`
- `.github/workflows/docker.yml:56`
- `.github/workflows/docker.yml:60`
- `.github/workflows/docker.yml:64`
- `.github/workflows/docker.yml:75`
- `.github/workflows/docker.yml:83`
- `.github/workflows/docker.yml:91`
- `.github/workflows/docker.yml:97`
- `.github/workflows/docker.yml:101`
- `.github/workflows/docker.yml:107`

### unpinned-uses (severity: high)

Multiple unpinned uses: references in .github/workflows/release.yml — all use mutable tags instead of pinned 40-character SHA commit hashes:
- `uses: actions/checkout@v6` (multiple jobs)
- `uses: dtolnay/rust-toolchain@stable`
- `uses: Swatinem/rust-cache@v2`
- `uses: actions/upload-artifact@v7`
- `uses: actions/download-artifact@v7`
- `uses: softprops/action-gh-release@v3`
- `uses: docker/setup-qemu-action@v3`
- `uses: docker/setup-buildx-action@v3`
- `uses: docker/login-action@v3`
- `uses: docker/build-push-action@v6`

Locations:

- `.github/workflows/release.yml:20`
- `.github/workflows/release.yml:35`
- `.github/workflows/release.yml:37`
- `.github/workflows/release.yml:39`
- `.github/workflows/release.yml:84`
- `.github/workflows/release.yml:90`
- `.github/workflows/release.yml:96`
- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:108`
- `.github/workflows/release.yml:113`
- `.github/workflows/release.yml:118`
- `.github/workflows/release.yml:124`

### unpinned-uses (severity: high)

Multiple unpinned uses: references in .github/workflows/action-e2e.yml — all use mutable tags instead of pinned 40-character SHA commit hashes:
- `uses: actions/checkout@v6`
- `uses: dtolnay/rust-toolchain@stable`
- `uses: Swatinem/rust-cache@v2`
- `uses: github/codeql-action/upload-sarif@v4`

Locations:

- `.github/workflows/action-e2e.yml:25`
- `.github/workflows/action-e2e.yml:27`
- `.github/workflows/action-e2e.yml:28`
- `.github/workflows/action-e2e.yml:230`

### missing-permissions (severity: medium)

.github/workflows/ci.yml has no top-level `permissions:` key and none of its four jobs (test, clippy, fmt, smoke) have job-level `permissions:` blocks. This means the workflow runs with the default token permissions, which may be broader than necessary.

Locations:

- `.github/workflows/ci.yml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:66`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:77`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.path }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:140`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:141`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:144`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:148`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:151`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:152`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.baseline }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:155`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.baseline }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:156`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.ignore-tests }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:159`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Check result"; move to env: map

Locations:

- `action.yml:194`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across 5 files:

**action.yml**: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions out of run: blocks into env: blocks. Replaced ${{ runner.temp }} with $RUNNER_TEMP (standard env var). Added printf/tr sanitization before writing to GITHUB_OUTPUT and GITHUB_PATH. Pinned github/codeql-action/upload-sarif@v4 to SHA 7188fc363630916deb702c7fdcf4e481b751f97a.

**.github/workflows/ci.yml**: Added top-level `permissions: contents: read` block. Pinned all actions: actions/checkout@v6→SHA d23441a4, dtolnay/rust-toolchain@stable→SHA 4cda84d5, Swatinem/rust-cache@v2→SHA e18b4977.

**.github/workflows/docker.yml**: Pinned all actions to SHAs. Fixed script-injection in 'Create and push manifest list' step by moving needs.metadata.outputs.json to METADATA_JSON env var and using printf to pipe to jq instead of herestring.

**.github/workflows/release.yml**: Pinned all actions to SHAs. Moved matrix.target to MATRIX_TARGET env var and github.ref_name to REF_NAME env var in all affected steps. Added sanitization (printf/tr for unix, -replace for PowerShell) before writing to GITHUB_ENV and GITHUB_OUTPUT.

**.github/workflows/action-e2e.yml**: Pinned all actions to SHAs. Fixed 'Install binary' step to use $RUNNER_TEMP instead of ${{ runner.temp }} with sanitization before writing to GITHUB_PATH. Fixed 'Test 8c' step to move steps.subdir-filtered-action.outputs.* into env: block.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities:

1. action.yml 'Run scan' step (line 133): Replaced string-based $ARGS concatenation with a bash array. Previously, unquoted user-controlled inputs ($INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE) were concatenated into a string and passed unquoted to agentshield, allowing shell metacharacter injection. Now uses ARGS=() array with properly double-quoted values and invokes agentshield "${ARGS[@]}".

2. docker.yml 'Create and push manifest list' step (line 113): Replaced unquoted $tags (built via xargs from untrusted metadata output) and $sources with bash arrays. Tags are built with mapfile -t tag_args using jq to emit one token per line, and sources are built in a for loop. The docker command now uses "${tag_args[@]}" "${source_args[@]}" to prevent word-splitting and injection.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings: (1) In release.yml line 103, added double-quotes around $BINARY inside dirname and basename command substitutions: `$(dirname "$BINARY")` and `$(basename "$BINARY")` to prevent shell metacharacter injection from matrix.target values. (2) In action-e2e.yml line 255, replaced the shell expansion of `$SUBDIR_SARIF_FILE` inside the Python -c string literal with `os.environ['SUBDIR_SARIF_FILE']` — the variable was already safely placed in the step's env: block, so reading it via os.environ avoids any shell injection risk while preserving correct behavior.

