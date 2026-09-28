<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are interpolated directly inside run: shell command strings across five steps in action.yml. This allows an attacker (or any caller of this composite action) to inject arbitrary shell commands via workflow-controlled inputs and context values.

'Determine version' step (~line 68): `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`

'Determine platform' step (~line 88): `case "${{ runner.os }}-${{ runner.arch }}"` and error message echo with same expressions.

'Download AgentShield' step (~line 99): `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip ... -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

'Use provided AgentShield' step (~line 120): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

'Run scan' step (~line 130): `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`.

'Check result' step (~line 196): `'${{ inputs.fail-on }}'`, `"${{ steps.scan.outputs.no_adapter }}"`, `"${{ inputs.strict }}"`.

All inputs.* values are caller-controlled and must be routed through env: variables and double-quoted in the shell instead of being interpolated directly.

Locations:

- `action.yml:68`
- `action.yml:78`
- `action.yml:88`
- `action.yml:93`
- `action.yml:99`
- `action.yml:100`
- `action.yml:104`
- `action.yml:107`
- `action.yml:109`
- `action.yml:110`
- `action.yml:120`
- `action.yml:130`
- `action.yml:131`
- `action.yml:132`
- `action.yml:134`
- `action.yml:135`
- `action.yml:138`
- `action.yml:141`
- `action.yml:142`
- `action.yml:145`
- `action.yml:146`
- `action.yml:149`
- `action.yml:196`
- `action.yml:198`
- `action.yml:201`

### github-env-injection (severity: high)

In the 'Download AgentShield' step, the value `${{ runner.temp }}/agentshield` is written directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The runner.temp context value flows through YAML template substitution before the shell sees it, making it a workflow-controlled value. A newline embedded in this value could inject additional entries into GITHUB_PATH. The sanitization step (`printf '%s' ... | tr -d '\n\r'`) must be applied before the write.

Locations:

- `action.yml:110`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `uses: github/codeql-action/upload-sarif@v4`. The ref `@v4` is a mutable tag, not a pinned 40-character SHA commit hash. This means the action could be silently updated to a different (potentially malicious) version without any change to this file. It should be pinned to a full SHA, e.g. `uses: github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:183`

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

Fixed all findings in action.yml:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: shell blocks into env: blocks for each affected step (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference them as plain $VAR_NAME environment variables.
2. github-env-injection: runner.temp is now captured via RUNNER_TEMP_DIR env var, then sanitized with `printf '%s' "$RUNNER_TEMP_DIR" | tr -d '\n\r'` before being used in paths written to $GITHUB_PATH (in both Download AgentShield and Use provided AgentShield steps).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA 2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2 with # v4 comment preserved for readability.

### Iteration 2

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Fixed two high-severity findings in hardened/action/action.yml:

1. github-env-injection (line 94): Added sanitization of the VERSION variable before writing to GITHUB_OUTPUT. Now uses `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` and writes `safe_version` instead of `VERSION`, preventing newline injection into GITHUB_OUTPUT.

2. script-injection (lines 176-200): Replaced the string-based ARGS variable with a bash array. Changed `ARGS="scan $INPUT_PATH"` and subsequent string concatenations to `ARGS=("scan" "$INPUT_PATH")` with `ARGS+=(...)` appends. Changed the final invocation from `agentshield $ARGS` (unquoted) to `agentshield "${ARGS[@]}"`. Each user-controlled input (path, fail-on, format, config, baseline) is now a properly double-quoted, separate array element, preventing shell metacharacter injection.

