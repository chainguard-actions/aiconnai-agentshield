<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 16 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions inside shell commands, violating rule (a). This allows an attacker who controls the calling workflow's inputs to inject arbitrary shell commands.

1. 'Determine version' step (lines ~64, 73): `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`
2. 'Determine platform' step (line ~85): `case "${{ runner.os }}-${{ runner.arch }}" in`
3. 'Download AgentShield' step (lines ~97–111): `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`
4. 'Use provided AgentShield' step (line ~122): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`
5. 'Run scan' step (lines ~134–154): `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`
6. 'Check result' step (lines ~187–189): `'${{ inputs.fail-on }}'`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}`

All inputs.* and steps.*.outputs.* values are attacker-controllable. These must be moved to env: variables and referenced as quoted shell variables (e.g., "$VAR") instead.

Locations:

- `action.yml:64`
- `action.yml:73`
- `action.yml:85`
- `action.yml:97`
- `action.yml:103`
- `action.yml:107`
- `action.yml:110`
- `action.yml:111`
- `action.yml:122`
- `action.yml:134`
- `action.yml:135`
- `action.yml:136`
- `action.yml:139`
- `action.yml:140`
- `action.yml:143`
- `action.yml:147`
- `action.yml:151`
- `action.yml:154`
- `action.yml:187`
- `action.yml:189`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `${{ runner.temp }}/agentshield` directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The runner.temp context is a workflow-controlled value that flows through YAML template substitution before the shell sees it. A newline embedded in this value could inject additional entries into GITHUB_PATH. The required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`) is absent before the write. Similarly, the 'Use provided AgentShield' step writes `$(dirname "$AGENTSHIELD_DEST")` to $GITHUB_PATH where AGENTSHIELD_DEST was set from `${{ runner.temp }}` without sanitization.

Locations:

- `action.yml:111`
- `action.yml:130`

### unpinned-uses (severity: high)

The action.yml references `github/codeql-action/upload-sarif@v4` using a mutable version tag (`@v4`) instead of a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. It should be pinned to a specific SHA, e.g., `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:182`

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, static-inline-injection

**Notes:**

Rewrote action.yml to fix all findings:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ steps.*.outputs.* }}, and ${{ runner.* }} expressions from run: blocks into env: blocks. Each step now uses plain shell variable references ($INPUT_VERSION, $RUNNER_TEMP_DIR, $STEP_VERSION, $STEP_TARGET, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $STEP_NO_ADAPTER, $INPUT_STRICT).
2. github-env-injection: Both GITHUB_PATH writes now sanitize the path value with `printf '%s' "$VAR" | tr -d '\n\r'` before writing.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full SHA 6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee with # v4 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection vulnerability in the 'Run scan' step of action.yml. Replaced the string-based ARGS construction (where unquoted input variables like $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE were concatenated into a string and then expanded unquoted) with a bash array. Each argument is now properly double-quoted when added to the array (e.g., ARGS=("scan" "$INPUT_PATH" "--fail-on" "$INPUT_FAIL_ON")), and the command is invoked with agentshield "${ARGS[@]}" which expands each array element as a separate, properly-quoted word. This prevents shell metacharacters in user-controlled input values from being interpreted as shell commands.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Determine version' step of action.yml. The VERSION variable (derived from user-controlled inputs.version) was being written directly to $GITHUB_OUTPUT without sanitization. Added `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` before the echo statement, and changed the echo to write `safe_version` instead of `VERSION`. Also properly quoted `$GITHUB_OUTPUT` in the echo redirection.

