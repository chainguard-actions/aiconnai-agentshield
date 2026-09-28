<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.3** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings throughout action.yml. This is a script injection vulnerability — the expressions are substituted into the shell script before the shell parses it, allowing an attacker-controlled value to inject arbitrary shell commands.

(a) 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is interpolated directly into the shell.
(a) 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo — runner.* expressions interpolated directly.
(a) 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — all interpolated directly.
(a) 'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` — interpolated directly.
(a) 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]` — all interpolated directly.
(a) 'Check result' step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]` — interpolated directly.

All inputs.* values are attacker-controlled when the action is called from a workflow. Fix: move all inputs into env: variables and reference them as quoted shell variables ("$VAR") in the run: block.

Locations:

- `action.yml:63`
- `action.yml:74`
- `action.yml:84`
- `action.yml:89`
- `action.yml:97`
- `action.yml:98`
- `action.yml:103`
- `action.yml:107`
- `action.yml:110`
- `action.yml:111`
- `action.yml:118`
- `action.yml:127`
- `action.yml:128`
- `action.yml:131`
- `action.yml:132`
- `action.yml:135`
- `action.yml:138`
- `action.yml:139`
- `action.yml:142`
- `action.yml:143`
- `action.yml:146`
- `action.yml:181`
- `action.yml:183`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v4`. The ref `@v4` is a mutable tag, not a pinned 40-character commit SHA. A tag can be moved by the repository owner (or a compromised account) to point to a different, potentially malicious commit, enabling a supply-chain attack. Fix: pin to a full SHA, e.g. `uses: github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:176`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `${{ runner.temp }}/agentshield` directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The ${{ runner.* }} expression is interpolated directly into the shell script (script-injection), and the resulting value is written to GITHUB_PATH without applying `printf '%s' ... | tr -d '\n\r'` to strip newlines. A newline in the value could inject additional entries into GITHUB_PATH. Similarly, the 'Use provided AgentShield' step writes a path derived from `${{ runner.temp }}` to $GITHUB_PATH without sanitization.

Locations:

- `action.yml:111`
- `action.yml:124`

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

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, github-env-injection

**Notes:**

Rewrote action.yml to fix all findings:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: shell blocks into env: blocks for each step. Shell scripts now reference only environment variables ($INPUT_VERSION, $RUNNER_OS_INPUT, $RUNNER_ARCH_INPUT, $RUNNER_TEMP_DIR, $STEP_VERSION, $STEP_TARGET, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $INPUT_STRICT, $STEP_NO_ADAPTER).
2. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full SHA @2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2 # v4.
3. github-env-injection: Both GITHUB_PATH writes now sanitize the path value using printf '%s' "$RUNNER_TEMP_DIR/..." | tr -d '\n\r' before writing.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed three findings in hardened/action/action.yml:
1. script-injection (lines 174-198): Replaced unquoted string-based ARGS construction with a bash array. Changed `ARGS="scan $INPUT_PATH"` etc. to `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")` with `ARGS+=(...)` for optional flags, and `agentshield "${ARGS[@]}"` for invocation. All user-controlled values are now properly double-quoted.
2. github-env-injection (line 94, version): Added `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` and wrote `safe_version` to GITHUB_OUTPUT instead of raw `$VERSION`.
3. github-env-injection (line 209, sarif-file): Added `safe_sarif_file=$(printf '%s' "$SARIF_FILE" | tr -d '\n\r')` and wrote `safe_sarif_file` to GITHUB_OUTPUT instead of raw `$SARIF_FILE`.

