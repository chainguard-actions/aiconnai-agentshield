<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.3** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ ... }}` expressions are directly interpolated inside `run:` shell command strings across several steps in action.yml. This includes user-controllable inputs and context values that are YAML-template-substituted before the shell processes them, enabling script injection.

'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` (line 63) and `VERSION="${{ inputs.version }}"` (line 74).

'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` (line 83) and `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"` (line 88).

'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"` (line 95), `TARGET="${{ steps.platform.outputs.target }}"` (line 96), `unzip ... -d ${{ runner.temp }}/agentshield` (line 101), `mkdir -p ${{ runner.temp }}/agentshield` (line 104), `chmod +x ${{ runner.temp }}/agentshield/agentshield*` (line 107), `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` (line 108).

'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` (line 116).

'Run scan' step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"` (line 124), `ARGS="scan ${{ inputs.path }}"` (line 125), `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"` (line 126), `if [ "${{ inputs.format }}" = "sarif" ]` (line 129), `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"` (line 130), `ARGS="$ARGS --format ${{ inputs.format }}"` (line 133), `if [ -n "${{ inputs.config }}" ]` (line 136), `ARGS="$ARGS --config ${{ inputs.config }}"` (line 137), `if [ -n "${{ inputs.baseline }}" ]` (line 140), `ARGS="$ARGS --baseline ${{ inputs.baseline }}"` (line 141), `if [ "${{ inputs.ignore-tests }}" = "true" ]` (line 144).

'Check result' step: `'${{ inputs.fail-on }}'` (line 187), `${{ steps.scan.outputs.no_adapter }}` and `${{ inputs.strict }}` (lines 190, 193).

Locations:

- `action.yml:63`
- `action.yml:74`
- `action.yml:83`
- `action.yml:88`
- `action.yml:95`
- `action.yml:96`
- `action.yml:101`
- `action.yml:104`
- `action.yml:107`
- `action.yml:108`
- `action.yml:116`
- `action.yml:124`
- `action.yml:125`
- `action.yml:126`
- `action.yml:129`
- `action.yml:130`
- `action.yml:133`
- `action.yml:136`
- `action.yml:137`
- `action.yml:140`
- `action.yml:141`
- `action.yml:144`
- `action.yml:187`
- `action.yml:190`
- `action.yml:193`

### github-env-injection (severity: high)

Multiple writes to $GITHUB_OUTPUT and $GITHUB_PATH use values derived from untrusted inputs without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. 'Determine version' step (line 81): `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is set from `${{ inputs.version }}` (a user-controlled input) without newline sanitization.

2. 'Determine platform' step (line 90): `echo "target=$TARGET" >> $GITHUB_OUTPUT` — TARGET is set from `${{ runner.os }}-${{ runner.arch }}` without sanitization.

3. 'Download AgentShield' step (line 108): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — direct expression write to GITHUB_PATH without sanitization.

4. 'Use provided AgentShield' step (line 122): `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` — AGENTSHIELD_DEST is derived from `${{ runner.temp }}` without sanitization.

Locations:

- `action.yml:81`
- `action.yml:90`
- `action.yml:108`
- `action.yml:122`

### unpinned-uses (severity: high)

The `uses:` reference `github/codeql-action/upload-sarif@v4` uses a mutable tag ref (`@v4`) instead of a full 40-character SHA commit hash. This means the action could be silently updated to a different (potentially malicious) version without any change to the workflow file, creating a supply-chain risk.

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

Fixed all security findings in hardened/action/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks to env: blocks across all 5 affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS_INPUT, $RUNNER_TEMP_DIR, etc.) instead of inline template expressions.

2. github-env-injection: Added sanitization using `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT and $GITHUB_PATH in all 4 affected locations (version output, target output, download path, provided binary path).

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to the full commit SHA @24c54180a607b1449ed407dd24f251e4e9147c8d with a # v4 comment for readability.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Converted the ARGS string variable to a bash array (ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")), with all user-controlled inputs (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) properly double-quoted as individual array elements. Optional arguments use ARGS+=(...) with quoted values. The final command invocation was changed from 'agentshield $ARGS' to 'agentshield "${ARGS[@]}"', which safely expands each array element as a separate, properly-quoted argument, preventing shell word-splitting and metacharacter injection from attacker-controlled input values.

