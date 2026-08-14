<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 17 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Every `uses:` reference across action.yml and all workflow files uses a mutable tag or branch ref instead of a pinned 40-character SHA commit digest, making the action vulnerable to supply-chain attacks if any upstream action is compromised or its tag is moved.

Failing references include:
- action.yml: `github/codeql-action/upload-sarif@v4`
- action-e2e.yml: `actions/checkout@v6`, `dtolnay/rust-toolchain@stable`, `Swatinem/rust-cache@v2`, `github/codeql-action/upload-sarif@v4`
- agentshield.yml: `actions/checkout@v6`, `aiconnai/agentshield@v0.8.7`
- ci.yml: `actions/checkout@v6`, `dtolnay/rust-toolchain@stable`, `Swatinem/rust-cache@v2`, `actions/setup-node@v4`, `taiki-e/install-action@v2`
- codeql.yml: `actions/checkout@v6`, `github/codeql-action/init@v3`, `github/codeql-action/analyze@v3`
- docker.yml: `actions/checkout@v6`, `docker/metadata-action@v6`, `docker/login-action@v4`, `docker/setup-buildx-action@v4`, `docker/build-push-action@v7`, `actions/upload-artifact@v7`, `actions/download-artifact@v7`
- feature-matrix.yml: `actions/checkout@v6`, `dtolnay/rust-toolchain@stable`, `Swatinem/rust-cache@v2`
- gitleaks.yml: `actions/checkout@v6`, `github/codeql-action/upload-sarif@v4`
- release.yml: `actions/checkout@v6`, `dtolnay/rust-toolchain@stable`, `Swatinem/rust-cache@v2`, `actions/upload-artifact@v7`, `actions/download-artifact@v7`, `softprops/action-gh-release@v3`
- semgrep.yml: `actions/checkout@v6`, `github/codeql-action/upload-sarif@v4`
- vscode.yml: `actions/checkout@v6`, `actions/setup-node@v6`

Locations:

- `action.yml:218`
- `.github/workflows/action-e2e.yml:18`
- `.github/workflows/agentshield.yml:14`
- `.github/workflows/ci.yml:18`
- `.github/workflows/codeql.yml:18`
- `.github/workflows/docker.yml:14`
- `.github/workflows/feature-matrix.yml:35`
- `.github/workflows/gitleaks.yml:14`
- `.github/workflows/release.yml:18`
- `.github/workflows/semgrep.yml:14`
- `.github/workflows/vscode.yml:18`

### script-injection (severity: high)

Multiple `run:` blocks directly interpolate `${{ }}` expressions inside shell command strings (sub-rule a), allowing an attacker who controls the expression value to inject arbitrary shell commands before the shell ever sees the string.

**action.yml — 'Determine version' step**: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — the `inputs.version` value is interpolated directly into the shell script. An attacker-supplied version string containing shell metacharacters (e.g., `"; malicious-cmd #`) would be executed.

**action.yml — 'Determine platform' step**: `case "${{ runner.os }}-${{ runner.arch }}"` — `runner.*` context values are interpolated directly into the shell.

**action.yml — 'Download AgentShield' step**: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — multiple context values interpolated directly.

**action.yml — 'Use provided AgentShield' step**: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` — runner.temp interpolated directly.

**action.yml — 'Run scan' step**: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format sarif --output $SARIF_FILE"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]` — all user-controlled inputs interpolated directly into shell.

**action.yml — 'Check result' step**: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]`, `if [ "${{ inputs.strict }}" = "false" ]` — context values interpolated directly.

**feature-matrix.yml**: `- run: ${{ matrix.command }}` — the entire shell command is constructed from a matrix value, which is a direct script injection vector.

**release.yml — 'Build (native)' step**: `cargo build --release --target ${{ matrix.target }} --features full` — matrix.target interpolated directly.

**release.yml — 'Smoke check wrap command (unix)' step**: `target/${{ matrix.target }}/release/agentshield --help | grep wrap` — matrix.target interpolated directly.

**release.yml — 'Package (unix)' step**: `BINARY=target/${{ matrix.target }}/release/agentshield`, `ARCHIVE=agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz` — matrix.target and github.ref_name interpolated directly.

**docker.yml — 'Create and push manifest list' step**: `tags=$(jq -r '.tags[] | "-t " + .' <<< '${{ needs.metadata.outputs.json }}' | xargs)` — needs.metadata.outputs.json (a step output) interpolated directly into a shell heredoc.

**gitleaks.yml — 'Run Gitleaks' step**: `-v "${{ github.workspace }}:/src"` — github.workspace interpolated directly into a docker run command.

**semgrep.yml — 'Run Semgrep' step**: `-v "${{ github.workspace }}:/src"` — github.workspace interpolated directly into a docker run command.

**action-e2e.yml — 'Install binary' step**: `mkdir -p ${{ runner.temp }}/agentshield`, `cp target/release/agentshield ${{ runner.temp }}/agentshield/`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — runner.temp interpolated directly.

**action-e2e.yml — multiple verification steps**: `${{ steps.subdir-filtered-action.outputs.exit-code }}`, `${{ steps.subdir-filtered-action.outputs.finding-count }}`, `${{ steps.no-adapter-permissive.outputs.exit-code }}`, `${{ steps.no-adapter-strict.outcome }}`, `${{ steps.no-adapter-strict.outputs.exit-code }}`, `${{ steps.invalid-config-permissive.outcome }}`, `${{ steps.invalid-config-permissive.outputs.exit-code }}` — step outputs interpolated directly into shell conditionals.

Locations:

- `action.yml:63`
- `action.yml:88`
- `action.yml:100`
- `action.yml:122`
- `action.yml:140`
- `action.yml:215`
- `.github/workflows/feature-matrix.yml:44`
- `.github/workflows/release.yml:60`
- `.github/workflows/release.yml:70`
- `.github/workflows/release.yml:75`
- `.github/workflows/docker.yml:115`
- `.github/workflows/gitleaks.yml:30`
- `.github/workflows/semgrep.yml:30`
- `.github/workflows/action-e2e.yml:35`

### github-env-injection (severity: high)

Several `run:` blocks write values derived from untrusted inputs or workflow-controlled context expressions to `$GITHUB_OUTPUT`, `$GITHUB_ENV`, or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

**action.yml — 'Determine version' step**: `echo "version=$VERSION" >> $GITHUB_OUTPUT` where `VERSION` is set directly from `${{ inputs.version }}` (an attacker-controlled input). A newline character in the version string would allow injecting arbitrary key=value pairs into GITHUB_OUTPUT.

**action.yml — 'Download AgentShield' step**: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — the `runner.temp` expression is interpolated directly and written to GITHUB_PATH without sanitization.

**action.yml — 'Run scan' step**: `echo "AGENTSHIELD_EXIT=$EXIT_CODE" >> $GITHUB_ENV` — while EXIT_CODE is computed locally, the step also writes `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` where SARIF_FILE is derived from `${{ runner.temp }}` without sanitization.

**release.yml — 'Package (unix)' step**: `echo "ARCHIVE=$ARCHIVE" >> $GITHUB_ENV` where `ARCHIVE` is constructed as `agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz` — both `github.ref_name` and `matrix.target` are interpolated directly into the ARCHIVE variable which is then written to GITHUB_ENV without sanitization.

Locations:

- `action.yml:82`
- `action.yml:118`
- `action.yml:210`
- `.github/workflows/release.yml:78`

### missing-permissions (severity: medium)

Three workflow files have no top-level `permissions:` block and no job-level `permissions:` blocks on any of their jobs. Without explicit permissions, GitHub Actions defaults to the repository's default token permissions (which may be `read-all` or `write-all` depending on repository settings), violating the principle of least privilege.

- **ci.yml**: No `permissions:` key at the top level or in any of its jobs (`release-invariants`, `test`, `clippy`, `fmt`, `supply-chain`, `smoke`, `vscode`).
- **feature-matrix.yml**: No `permissions:` key at the top level or in its `feature-matrix` job.
- **vscode.yml**: No `permissions:` key at the top level or in its `test` job.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/feature-matrix.yml:1`
- `.github/workflows/vscode.yml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:70`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:81`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.path }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:155`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:156`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:159`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:163`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:166`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:167`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.baseline }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:170`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.baseline }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:171`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.ignore-tests }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:174`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Check result"; move to env: map

Locations:

- `action.yml:247`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.strict }}" appears directly in run: block of step "Check result"; move to env: map

Locations:

- `action.yml:250`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yml and 10 workflow files:

1. **unpinned-uses**: Pinned all `uses:` references to full 40-char SHA digests with tag comments for readability. Actions pinned: actions/checkout@v6→d23441a4, dtolnay/rust-toolchain@stable→4360b525, Swatinem/rust-cache@v2→6323deb1, github/codeql-action/upload-sarif@v4→ff2f1c62, aiconnai/agentshield@v0.8.7→a1a57119, actions/setup-node@v4→49933ea5, actions/setup-node@v6→249970729, taiki-e/install-action@v2→82cd3e76, github/codeql-action/init@v3→f3712979, github/codeql-action/analyze@v3→f3712979, docker/metadata-action@v6→dc802804, docker/login-action@v4→dbcb8138, docker/setup-buildx-action@v4→bb05f3f5, docker/build-push-action@v7→53b7df96, actions/upload-artifact@v7→043fb46d, actions/download-artifact@v7→37930b1c, softprops/action-gh-release@v3→3d0d9888.

2. **script-injection / static-inline-injection**: Moved all `${{ }}` expressions from `run:` blocks to `env:` blocks in action.yml (all inputs and runner context values), feature-matrix.yml (matrix.command tokenized via xargs array), release.yml (matrix.target and github.ref_name in both bash and PowerShell steps), docker.yml (needs.metadata.outputs.json), gitleaks.yml and semgrep.yml (github.workspace replaced with $GITHUB_WORKSPACE), action-e2e.yml (runner.temp replaced with $RUNNER_TEMP, step outputs moved to env: blocks).

3. **github-env-injection**: Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing to GITHUB_OUTPUT, GITHUB_ENV, and GITHUB_PATH in action.yml. In release.yml, ARCHIVE is now built from sanitized safe_ref and safe_target variables.

4. **missing-permissions**: Added `permissions: contents: read` top-level blocks to ci.yml, feature-matrix.yml, and vscode.yml.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection issues: (1) In .github/workflows/docker.yml, moved `${{ steps.build.outputs.digest }}` from the run: shell string into an env: block as BUILD_DIGEST, referencing it as "$BUILD_DIGEST" in the shell. (2) In action.yml's 'Run scan' step, replaced the unquoted string-concatenation ARGS variable (expanded as `agentshield $ARGS`) with a bash array ARGS=(...) where each argument is individually quoted, expanded safely as `agentshield "${ARGS[@]}"`—preventing shell metacharacters in inputs.path, inputs.fail-on, inputs.format, inputs.config, and inputs.baseline from executing arbitrary commands.

