<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ ... }}` expressions are interpolated directly inside `run:` shell command strings across several steps in action.yml, violating sub-rule (a). This includes user-controlled `inputs.*` values and other context values that flow through YAML template substitution before the shell processes them.

'Determine version' step (lines ~70, 81):
  - `if [ "${{ inputs.version }}" = "latest" ]; then`
  - `VERSION="${{ inputs.version }}"`

'Determine platform' step (lines ~100, 106):
  - `case "${{ runner.os }}-${{ runner.arch }}" in`
  - `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"; exit 1 ;;`

'Download AgentShield' step (lines ~114-130):
  - `VERSION="${{ steps.version.outputs.version }}"`
  - `TARGET="${{ steps.platform.outputs.target }}"`
  - `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`
  - `mkdir -p ${{ runner.temp }}/agentshield`
  - `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`
  - `chmod +x ${{ runner.temp }}/agentshield/agentshield* 2>/dev/null || true`
  - `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

'Use provided AgentShield' step (line ~140):
  - `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`

'Run scan' step (lines ~150-170):
  - `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`
  - `ARGS="scan ${{ inputs.path }}"`
  - `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`
  - `if [ "${{ inputs.format }}" = "sarif" ]; then`
  - `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`
  - `ARGS="$ARGS --format ${{ inputs.format }}"`
  - `if [ -n "${{ inputs.config }}" ]; then`
  - `ARGS="$ARGS --config ${{ inputs.config }}"`
  - `if [ -n "${{ inputs.baseline }}" ]; then`
  - `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`
  - `if [ "${{ inputs.ignore-tests }}" = "true" ]; then`

'Check result' step (lines ~202-207):
  - `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`
  - `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]; then`
  - `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]; then`

All `inputs.*` values are attacker-controllable via the calling workflow. These should be moved to `env:` variables and referenced as `$ENV_VAR` (double-quoted) in the shell script.

Locations:

- `action.yml:70`
- `action.yml:81`
- `action.yml:100`
- `action.yml:106`
- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:125`
- `action.yml:126`
- `action.yml:129`
- `action.yml:130`
- `action.yml:140`
- `action.yml:150`
- `action.yml:151`
- `action.yml:152`
- `action.yml:154`
- `action.yml:155`
- `action.yml:158`
- `action.yml:161`
- `action.yml:162`
- `action.yml:165`
- `action.yml:166`
- `action.yml:169`
- `action.yml:202`
- `action.yml:204`
- `action.yml:207`

### github-env-injection (severity: high)

Several `run:` blocks write values derived from untrusted inputs or workflow-controlled contexts to `$GITHUB_OUTPUT` and `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. 'Determine version' step: `VERSION` is derived from `${{ inputs.version }}` (user-controlled) and written unsanitized to `$GITHUB_OUTPUT`:
   `echo "version=$VERSION" >> $GITHUB_OUTPUT`

2. 'Download AgentShield' step: `${{ runner.temp }}/agentshield` is written directly to `$GITHUB_PATH` without sanitization:
   `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

3. 'Use provided AgentShield' step: `AGENTSHIELD_DEST` contains `${{ runner.temp }}` and its dirname is written to `$GITHUB_PATH` without sanitization:
   `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH`

4. 'Run scan' step: `$SARIF_FILE` (containing `${{ runner.temp }}` and `${{ inputs.format }}` values) is written to `$GITHUB_OUTPUT` without sanitization:
   `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT`

An attacker controlling `inputs.version`, `inputs.format`, or other inputs could inject newlines to set arbitrary environment variables or path entries.

Locations:

- `action.yml:93`
- `action.yml:130`
- `action.yml:148`
- `action.yml:183`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v4`, which references a mutable tag (`@v4`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit without notice, creating a supply-chain attack vector. It should be pinned to a specific SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:196`

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

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.* }} expressions from run: shell blocks into env: blocks for all affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference them as double-quoted $ENV_VAR_NAME variables.

2. github-env-injection: Added sanitization (printf '%s' "$VAR" | tr -d '\n\r') before writing to $GITHUB_OUTPUT and $GITHUB_PATH in all four affected locations: version output in Determine version step, path in Download AgentShield step, path in Use provided AgentShield step, and sarif-file output in Run scan step.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full SHA 2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2 with # v4 comment preserved for readability.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml by converting the ARGS string variable to a bash array. Changed ARGS="scan $INPUT_PATH" to ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON") and subsequent string concatenations to array appends with ARGS+=(...). Each input variable (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) is now properly double-quoted within the array. The final invocation was changed from 'agentshield $ARGS' to 'agentshield "${ARGS[@]}"' to properly expand the array while preserving argument boundaries, preventing shell metacharacter injection.

