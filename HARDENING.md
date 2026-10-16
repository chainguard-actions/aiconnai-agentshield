<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings across several steps in action.yml, violating rule (a). This includes attacker-controllable inputs.* values and other context values:

- 'Determine version' step (line 66): `if [ "${{ inputs.version }}" = "latest" ]` and (line 76) `VERSION="${{ inputs.version }}"`
- 'Determine platform' step (line 89): `case "${{ runner.os }}-${{ runner.arch }}" in` and (line 94) `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`
- 'Download AgentShield' step (lines 102-114): `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`
- 'Use provided AgentShield' step (line 127): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`
- 'Run scan' step (lines 137-156): `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`
- 'Check result' step (lines 207-213): `'${{ inputs.fail-on }}'`, `"${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false"`, `"${{ steps.scan.outputs.no_adapter }}" = "true"`

All ${{ }} expressions inside run: blocks are script-injection findings regardless of context.

Locations:

- `action.yml:66`
- `action.yml:76`
- `action.yml:89`
- `action.yml:94`
- `action.yml:102`
- `action.yml:103`
- `action.yml:107`
- `action.yml:110`
- `action.yml:113`
- `action.yml:114`
- `action.yml:127`
- `action.yml:137`
- `action.yml:138`
- `action.yml:139`
- `action.yml:141`
- `action.yml:142`
- `action.yml:145`
- `action.yml:148`
- `action.yml:149`
- `action.yml:152`
- `action.yml:153`
- `action.yml:156`
- `action.yml:207`
- `action.yml:210`
- `action.yml:213`

### github-env-injection (severity: high)

Several run: blocks write values derived from untrusted inputs to special GitHub environment files without the required sanitization (`printf '%s' ... | tr -d '\n\r'`):

1. 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` where VERSION is set from `${{ inputs.version }}` (an attacker-controlled input) without sanitization. A newline in inputs.version could inject additional key=value pairs into GITHUB_OUTPUT.

2. 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes runner.temp directly to GITHUB_PATH without sanitization.

3. 'Run scan' step: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` where SARIF_FILE is constructed from `${{ runner.temp }}` without sanitization.

Locations:

- `action.yml:82`
- `action.yml:114`
- `action.yml:168`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v4`, which uses a mutable tag (`v4`) instead of a pinned 40-character commit SHA. This is vulnerable to supply-chain attacks where the tag could be moved to point to malicious code.

Locations:

- `action.yml:198`

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
1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks into env: blocks for all affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Each step now references environment variables in the shell script instead of inline expressions.
2. github-env-injection: Added sanitization using `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT (version in 'Determine version' step, sarif-file in 'Run scan' step) and $GITHUB_PATH (path in 'Download AgentShield' step).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA @6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee with # v4 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml by replacing the unsafe string concatenation approach (ARGS="scan $INPUT_PATH", etc.) with a bash array. Each user-controlled input value is now a properly double-quoted array element: ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON"), with subsequent ARGS+=(...) calls for optional arguments. The command is invoked as agentshield "${ARGS[@]}" which expands each element as a separate, properly-quoted argument, preventing shell metacharacters in input values from breaking out of the string context and injecting arbitrary shell commands.

