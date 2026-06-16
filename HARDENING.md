<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **aiconnai--agentshield/v0.8.6** was hardened automatically. 17 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Determine version' step directly interpolates ${{ inputs.version }} inside the run: shell script (both in the if condition and the else branch). An attacker-controlled input value is embedded directly into the shell command string before the shell parses it, enabling command injection. Offending lines: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`

Locations:

- `action.yml:55`
- `action.yml:62`

### script-injection (severity: high)

Sub-rule (a): The 'Determine platform' step directly interpolates ${{ runner.os }} and ${{ runner.arch }} inside the run: shell script in a case statement and an error message. Any ${{ ... }} expression inside a run: block is a script-injection risk. Offending lines: `case "${{ runner.os }}-${{ runner.arch }}" in` and `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`

Locations:

- `action.yml:70`
- `action.yml:76`

### script-injection (severity: high)

Sub-rule (a): The 'Download AgentShield' step directly interpolates ${{ steps.version.outputs.version }}, ${{ steps.platform.outputs.target }}, and ${{ runner.temp }} inside the run: shell script. These context values are embedded directly into shell commands. Offending lines include: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

Locations:

- `action.yml:84`
- `action.yml:85`
- `action.yml:90`
- `action.yml:94`
- `action.yml:98`
- `action.yml:99`

### script-injection (severity: high)

Sub-rule (a): The 'Run scan' step directly interpolates multiple inputs.* and runner.* expressions inside the run: shell script. Attacker-controlled inputs (inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests) and runner.temp are embedded directly into shell command strings. Offending lines include: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`

Locations:

- `action.yml:105`
- `action.yml:106`
- `action.yml:109`
- `action.yml:110`
- `action.yml:114`
- `action.yml:117`
- `action.yml:118`
- `action.yml:121`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes ${{ runner.temp }}/agentshield directly to $GITHUB_PATH without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). The runner.temp context value flows directly into the special environment file. Offending line: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

Locations:

- `action.yml:99`

### github-env-injection (severity: high)

The 'Run scan' step sets SARIF_FILE to a value containing ${{ runner.temp }} (a context expression) and then writes it to $GITHUB_OUTPUT without sanitization: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT`. The value is derived from a workflow context expression and is written to a special environment file without the required `printf '%s' ... | tr -d '\n\r'` sanitization.

Locations:

- `action.yml:110`
- `action.yml:131`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable version tag (@v3) rather than an immutable 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:142`

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all findings in action.yml:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: shell scripts into env: blocks for each affected step (Determine version, Determine platform, Download AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables.
2. github-env-injection: Added printf '%s' ... | tr -d '\n\r' sanitization before writing values to $GITHUB_PATH (runner.temp path in Download AgentShield) and $GITHUB_OUTPUT (sarif-file in Run scan, version in Determine version, target in Determine platform).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v3 to full SHA dd903d2e4f5405488e5ef1422510ee31c8b32357 with # v3 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml. Replaced the string-based ARGS variable (which concatenated unquoted user-controlled values and was expanded unquoted in `agentshield $ARGS`) with a bash array. Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG) is now properly double-quoted as a separate array element (e.g., `ARGS=(scan "$INPUT_PATH")`, `ARGS+=(--fail-on "$INPUT_FAIL_ON")`, etc.). The command is executed as `agentshield "${ARGS[@]}"` which preserves argument boundaries and prevents word splitting and shell metacharacter interpretation on attacker-controlled values.

