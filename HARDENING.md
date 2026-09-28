<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions inside shell commands, violating rule (a). This allows an attacker who controls the inputs to inject arbitrary shell commands.

1. 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is attacker-controlled.
2. 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` — runner.* expressions are interpolated directly into a case statement.
3. 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield"` — steps outputs and runner.temp all interpolated directly.
4. 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, and `${{ inputs.ignore-tests }}` — all user-supplied inputs interpolated directly into shell.
5. 'Check result' step: `'${{ inputs.fail-on }}'`, `${{ steps.scan.outputs.no_adapter }}`, and `${{ inputs.strict }}` — interpolated directly into shell conditionals.

Locations:

- `action.yml:68`
- `action.yml:90`
- `action.yml:100`
- `action.yml:130`
- `action.yml:200`

### github-env-injection (severity: high)

Multiple run: blocks write values derived from untrusted inputs to $GITHUB_OUTPUT and $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is set from `${{ inputs.version }}` (attacker-controlled) without sanitization.
2. 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — runner.temp expression written directly to GITHUB_PATH without sanitization.
3. 'Run scan' step: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is constructed from `${{ runner.temp }}` and `${{ inputs.format }}` without sanitization before the write.

Locations:

- `action.yml:85`
- `action.yml:120`
- `action.yml:175`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4` which is pinned to a mutable tag (`v4`) rather than an immutable 40-character commit SHA. A compromised or altered tag could cause the action to execute malicious code. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:192`

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all security findings in hardened/action/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks into env: blocks for all 5 affected steps (Determine version, Determine platform, Download AgentShield, Run scan, Check result). Each step now references environment variables ($INPUT_VERSION, $RUNNER_OS_INPUT, $RUNNER_ARCH_INPUT, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP_DIR, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $STEP_NO_ADAPTER, $INPUT_STRICT) instead of direct ${{ }} interpolation.

2. github-env-injection: Added sanitization with `printf '%s' "$VAR" | tr -d '\n\r'` before all writes to $GITHUB_OUTPUT and $GITHUB_PATH: version in Determine version step, path in Download AgentShield step, path in Use provided AgentShield step, and sarif-file in Run scan step.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif from mutable tag @v4 to immutable SHA @2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2 with # v4 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml by replacing the string-based ARGS accumulation with a bash array. Changed:
- `ARGS="scan $INPUT_PATH"` → `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")`
- All subsequent `ARGS="$ARGS --flag $INPUT_VAR"` patterns → `ARGS+=(--flag "$INPUT_VAR")`
- Final invocation `agentshield $ARGS` → `agentshield "${ARGS[@]}"`

This ensures all user-controlled inputs (path, fail-on, format, config, baseline) are properly quoted as separate array elements, preventing shell metacharacter injection via word-splitting or glob expansion.

