<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ ... }}` expressions are directly interpolated inside `run:` shell command strings across several composite action steps in action.yml. This allows script injection because the expression values are substituted into the shell script before the shell parses it.

**Step: 'Determine version'** (sub-rule a):
- Line 70: `if [ "${{ inputs.version }}" = "latest" ]; then`
- Line 81: `VERSION="${{ inputs.version }}"`

**Step: 'Determine platform'** (sub-rule a):
- Line 100: `case "${{ runner.os }}-${{ runner.arch }}" in`
- Line 106: `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"; exit 1 ;;`

**Step: 'Download AgentShield'** (sub-rule a):
- Line 114: `VERSION="${{ steps.version.outputs.version }}"`
- Line 115: `TARGET="${{ steps.platform.outputs.target }}"`
- Line 121: `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`
- Line 125: `mkdir -p ${{ runner.temp }}/agentshield`
- Line 129: `chmod +x ${{ runner.temp }}/agentshield/agentshield*`
- Line 130: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

**Step: 'Use provided AgentShield'** (sub-rule a):
- Line 142: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`

**Step: 'Run scan'** (sub-rule a):
- Line 154: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`
- Line 155: `ARGS="scan ${{ inputs.path }}"`
- Line 156: `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`
- Line 159: `if [ "${{ inputs.format }}" = "sarif" ]; then`
- Line 160: `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`
- Line 163: `ARGS="$ARGS --format ${{ inputs.format }}"`
- Line 166: `if [ -n "${{ inputs.config }}" ]; then`
- Line 167: `ARGS="$ARGS --config ${{ inputs.config }}"`
- Line 170: `if [ -n "${{ inputs.baseline }}" ]; then`
- Line 171: `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`
- Line 174: `if [ "${{ inputs.ignore-tests }}" = "true" ]; then`

**Step: 'Check result'** (sub-rule a):
- Line 209: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`
- Line 212: `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]; then`
- Line 215: `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]; then`

All `inputs.*` values are attacker-controllable. All `${{ ... }}` expressions must be moved to `env:` variables and the env vars must be double-quoted in the shell script.

Locations:

- `action.yml:70`
- `action.yml:81`
- `action.yml:100`
- `action.yml:106`
- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:125`
- `action.yml:129`
- `action.yml:130`
- `action.yml:142`
- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:159`
- `action.yml:160`
- `action.yml:163`
- `action.yml:166`
- `action.yml:167`
- `action.yml:170`
- `action.yml:171`
- `action.yml:174`
- `action.yml:209`
- `action.yml:212`
- `action.yml:215`

### github-env-injection (severity: high)

Unsanitized values derived from untrusted inputs are written to GitHub special environment files without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

1. **'Determine version' step, line 93**: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — `$VERSION` is derived directly from `${{ inputs.version }}` (lines 70 and 81). An attacker can inject newlines into `inputs.version` to poison `$GITHUB_OUTPUT` with arbitrary key-value pairs.

2. **'Download AgentShield' step, line 130**: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — `${{ runner.temp }}` is a workflow-controllable context value written directly to `$GITHUB_PATH` without sanitization. A newline in `runner.temp` would allow injecting arbitrary paths.

Locations:

- `action.yml:93`
- `action.yml:130`

### unpinned-uses (severity: high)

The `uses:` reference `github/codeql-action/upload-sarif@v4` uses a mutable tag (`@v4`) instead of a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:200`

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

Fixed all findings in hardened/action/action.yml:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks to env: blocks in all affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain $ENV_VAR_NAME variables.
2. github-env-injection: Added `printf '%s' "$VERSION" | tr -d '\n\r'` sanitization before writing to $GITHUB_OUTPUT in 'Determine version' step, and `printf '%s' "$RUNNER_TEMP_DIR/agentshield" | tr -d '\n\r'` before writing to $GITHUB_PATH in 'Download AgentShield' step.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA @24c54180a607b1449ed407dd24f251e4e9147c8d # v4.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed two security findings in hardened/action/action.yml:

1. script-injection: In the 'Run scan' step, replaced unquoted string concatenation for building the ARGS variable with a bash array. Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) is now properly double-quoted as a separate array element, and the command is invoked as `agentshield "${ARGS[@]}"` to prevent shell metacharacter injection.

2. github-env-injection (two locations):
   - 'Use provided AgentShield' step: Added sanitization before writing to GITHUB_PATH using `safe_dir=$(printf '%s' "$(dirname "$AGENTSHIELD_DEST")" | tr -d '\n\r')` then `echo "$safe_dir" >> "$GITHUB_PATH"`.
   - 'Run scan' step: Added sanitization before writing sarif-file to GITHUB_OUTPUT using `safe_sarif=$(printf '%s' "$SARIF_FILE" | tr -d '\n\r')` then `echo "sarif-file=$safe_sarif" >> "$GITHUB_OUTPUT"`.

