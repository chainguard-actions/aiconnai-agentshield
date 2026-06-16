<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **aiconnai--agentshield/v0.8.5** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions inside shell command strings (rule a). This allows shell metacharacter injection before the shell ever quotes the values.

Affected steps and offending lines:
- 'Determine version' step: if [ "${{ inputs.version }}" = "latest" ] (line 57) and VERSION="${{ inputs.version }}" (line 62) — inputs.version is attacker-controlled.
- 'Determine platform' step: case "${{ runner.os }}-${{ runner.arch }}" (line 68) and error echo with ${{ runner.os }}-${{ runner.arch }} (line 74).
- 'Download AgentShield' step: VERSION="${{ steps.version.outputs.version }}" (line 79), TARGET="${{ steps.platform.outputs.target }}" (line 80), ${{ runner.temp }}/agentshield in unzip/mkdir/tar/chmod/echo lines (lines 85, 88, 89, 92, 93).
- 'Run scan' step: ARGS="scan ${{ inputs.path }}" (line 97), ${{ inputs.fail-on }} (line 98), ${{ inputs.format }} (lines 101, 106), ${{ runner.temp }} (line 102), ${{ inputs.config }} (lines 109-110), ${{ inputs.ignore-tests }} (line 113).
- 'Check result' step: '${{ inputs.fail-on }}' (line 147).

All ${{ inputs.* }} values are attacker-controllable. All ${{ steps.*.outputs.* }} and ${{ runner.* }} values flow through YAML template substitution before the shell processes them. None are routed through env vars before use in the shell.

Locations:

- `action.yml:57`
- `action.yml:62`
- `action.yml:68`
- `action.yml:74`
- `action.yml:79`
- `action.yml:80`
- `action.yml:85`
- `action.yml:88`
- `action.yml:89`
- `action.yml:92`
- `action.yml:93`
- `action.yml:97`
- `action.yml:98`
- `action.yml:101`
- `action.yml:102`
- `action.yml:106`
- `action.yml:109`
- `action.yml:110`
- `action.yml:113`
- `action.yml:147`

### github-env-injection (severity: high)

Two run: blocks write values derived from workflow-controlled expressions to special GitHub environment files without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. 'Download AgentShield' step (line 93): echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH — the value of ${{ runner.temp }} is interpolated directly and written to GITHUB_PATH without sanitization.

2. 'Run scan' step (line 127): echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT — SARIF_FILE was set to "${{ runner.temp }}/agentshield-results.sarif" (line 102), so it carries the unsanitized runner.temp value into GITHUB_OUTPUT.

Neither write is preceded by the required printf '%s' ... | tr -d '\n\r' sanitization pipeline.

Locations:

- `action.yml:93`
- `action.yml:127`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references github/codeql-action/upload-sarif@v3 using a mutable tag (v3) instead of a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. Fix: pin to a specific commit SHA, e.g. uses: github/codeql-action/upload-sarif@<40-char-sha> # v3

Locations:

- `action.yml:140`

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

Rewrote action.yml to fix all findings:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks into env: blocks for each step (Determine version, Determine platform, Download AgentShield, Run scan, Check result). Shell scripts now reference plain env vars.
2. github-env-injection: Added printf '%s' ... | tr -d '\n\r' sanitization before writing to $GITHUB_PATH (runner.temp path in Download AgentShield) and $GITHUB_OUTPUT (sarif-file in Run scan, version in Determine version).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v3 to full SHA dd903d2e4f5405488e5ef1422510ee31c8b32357 with # v3 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml. Replaced the string-based ARGS variable (which concatenated unquoted user-controlled inputs and was invoked unquoted as `agentshield $ARGS`) with a bash array. Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG) is now added to the array as a properly double-quoted element, and the command is invoked as `agentshield "${args[@]}"`. This prevents word-splitting, glob expansion, and shell metacharacter injection from any of the four affected inputs.

