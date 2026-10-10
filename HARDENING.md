<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.6** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions inside shell commands, violating rule (a). This allows expression values to be parsed as shell syntax before the shell ever sees them.

• 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is attacker-controlled and injected directly into shell.
• 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo — runner context expressions interpolated directly.
• 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip ... -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — step outputs and runner.temp interpolated directly.
• 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]` — multiple attacker-controlled inputs interpolated directly into shell.
• 'Check result' step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"` — inputs.fail-on interpolated directly.

All these expressions should be moved to env: variables and then referenced as quoted shell variables (e.g., "$VAR").

Locations:

- `action.yml:57`
- `action.yml:63`
- `action.yml:70`
- `action.yml:76`
- `action.yml:82`
- `action.yml:83`
- `action.yml:89`
- `action.yml:92`
- `action.yml:95`
- `action.yml:96`
- `action.yml:100`
- `action.yml:101`
- `action.yml:104`
- `action.yml:105`
- `action.yml:109`
- `action.yml:112`
- `action.yml:113`
- `action.yml:116`
- `action.yml:143`

### github-env-injection (severity: high)

Two run: blocks write values derived from untrusted inputs to GitHub special environment files without the required sanitization step (printf '%s' ... | tr -d '\n\r').

• 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is set from `${{ inputs.version }}` (attacker-controlled). A newline in inputs.version would allow injecting additional key=value pairs into GITHUB_OUTPUT.
• 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — runner.temp is a ${{ }} expression written directly to GITHUB_PATH without sanitization. Any expression value written to a special env file must be sanitized first with `printf '%s' "$VAR" | tr -d '\n\r'`.

Locations:

- `action.yml:65`
- `action.yml:96`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, enabling a supply-chain attack. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-hex-char-sha> # v3`.

Locations:

- `action.yml:135`

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, static-inline-injection

**Notes:**

Rewrote action.yml to fix all findings:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks into env: maps for each step. Affected steps: 'Determine version' (inputs.version), 'Determine platform' (runner.os, runner.arch), 'Download AgentShield' (steps.version.outputs.version, steps.platform.outputs.target, runner.temp), 'Run scan' (inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests, runner.temp), 'Check result' (inputs.fail-on). All are now referenced as shell variables like $INPUT_VERSION, $RUNNER_OS, etc.

2. github-env-injection: Added sanitization (printf '%s' "$VAR" | tr -d '\n\r') before writing to $GITHUB_OUTPUT in 'Determine version' step and before writing to $GITHUB_PATH in 'Download AgentShield' step.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif from @v3 to @9f759ee644a3e7c15c1390abf49868036c00067b # v3.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the 'Run scan' step in action.yml by replacing string-based ARGS accumulation with a bash array. Changed `ARGS="scan $INPUT_PATH"` to `ARGS=(scan "$INPUT_PATH")`, used `ARGS+=("--flag" "$VALUE")` for all subsequent argument additions, and changed the final invocation from `agentshield $ARGS` to `agentshield "${ARGS[@]}"}`. This ensures all user-controlled inputs (path, fail-on, format, config) are properly quoted as individual array elements, preventing shell word-splitting and metacharacter injection.

