<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions inside shell commands without routing through env: variables first. Affected steps and offending lines:

'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]; then` (line 70) and `VERSION="${{ inputs.version }}"` (line 81) — inputs.version is attacker-controlled.

'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` (line 100) and the error branch on line 106 — runner.* context values are interpolated directly.

'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"` (line 114), `TARGET="${{ steps.platform.outputs.target }}"` (line 115), `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield` (line 121), `mkdir -p ${{ runner.temp }}/agentshield` (line 125), `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield` (line 126), `chmod +x ${{ runner.temp }}/agentshield/agentshield*` (line 129), `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` (line 130).

'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` (line 142).

'Run scan' step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"` (line 154), `ARGS="scan ${{ inputs.path }}"` (line 155), `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"` (line 156), `if [ "${{ inputs.format }}" = "sarif" ]` (line 159), `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"` (line 160), `ARGS="$ARGS --format ${{ inputs.format }}"` (line 163), `if [ -n "${{ inputs.config }}" ]` (line 166), `ARGS="$ARGS --config ${{ inputs.config }}"` (line 167), `if [ -n "${{ inputs.baseline }}" ]` (line 170), `ARGS="$ARGS --baseline ${{ inputs.baseline }}"` (line 171), `if [ "${{ inputs.ignore-tests }}" = "true" ]` (line 174).

'Check result' step: `'${{ inputs.fail-on }}'` in error message, `${{ steps.scan.outputs.no_adapter }}` and `${{ inputs.strict }}` in conditionals.

All of these allow an attacker-controlled value to be parsed by the shell before quoting can protect it.

Locations:

- `action.yml:70`
- `action.yml:81`
- `action.yml:100`
- `action.yml:106`
- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:125`
- `action.yml:130`
- `action.yml:142`
- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:159`
- `action.yml:163`
- `action.yml:167`
- `action.yml:171`
- `action.yml:174`

### github-env-injection (severity: high)

Multiple steps write values derived from untrusted inputs to $GITHUB_OUTPUT or $GITHUB_PATH without the required sanitization step (printf '%s' "$VAR" | tr -d '\n\r'):

(a) 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` where VERSION is derived directly from `${{ inputs.version }}` (an attacker-controlled input) without sanitization. A newline in the input could inject arbitrary environment variables.

(b) 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — the runner.temp context value is interpolated directly into a GITHUB_PATH write without sanitization.

(c) 'Use provided AgentShield' step: `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` where AGENTSHIELD_DEST is set to `${{ runner.temp }}/agentshield/agentshield` — the runner.temp value flows into GITHUB_PATH without sanitization.

Locations:

- `action.yml:93`
- `action.yml:130`
- `action.yml:148`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v4`, which uses a mutable tag (`v4`) rather than a pinned 40-character commit SHA. A compromised or force-pushed tag could cause the action to execute arbitrary code in the runner. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:204`

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

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks to env: blocks across all steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables.

2. github-env-injection: Added sanitization using `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT (version in 'Determine version' step) and $GITHUB_PATH (path in 'Download AgentShield' and 'Use provided AgentShield' steps).

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA 24c54180a607b1449ed407dd24f251e4e9147c8d with # v4 comment for readability.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Replaced the string-based $ARGS accumulation (where unquoted input values were concatenated and then expanded unquoted) with a bash array. Each input value (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) is now properly double-quoted when added to the ARGS array, and the command is invoked as `agentshield "${ARGS[@]}"` which preserves argument boundaries and prevents word-splitting/glob expansion on attacker-controlled values.

