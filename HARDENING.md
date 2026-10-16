<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ ... }}` expressions are interpolated directly inside `run:` shell command strings in action.yml, allowing script injection. Affected steps and offending lines:

**Determine version** step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`

**Determine platform** step: `case "${{ runner.os }}-${{ runner.arch }}" in` and `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`

**Download AgentShield** step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

**Use provided AgentShield** step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`

**Run scan** step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`

**Check result** step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]`, `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]`

All inputs.* values are caller-controlled and must be routed through env: variables and double-quoted in the shell. runner.* and steps.*.outputs.* values should also be passed via env: to avoid template injection before the shell parses the script.

Locations:

- `action.yml:73`
- `action.yml:84`
- `action.yml:101`
- `action.yml:106`
- `action.yml:114`
- `action.yml:115`
- `action.yml:120`
- `action.yml:123`
- `action.yml:124`
- `action.yml:126`
- `action.yml:127`
- `action.yml:140`
- `action.yml:152`
- `action.yml:153`
- `action.yml:154`
- `action.yml:156`
- `action.yml:157`
- `action.yml:160`
- `action.yml:163`
- `action.yml:164`
- `action.yml:167`
- `action.yml:168`
- `action.yml:171`
- `action.yml:209`
- `action.yml:211`
- `action.yml:214`

### github-env-injection (severity: high)

Unsanitized values derived from `${{ runner.temp }}` (a workflow-expression) are written directly to `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. **Download AgentShield** step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — the `${{ runner.temp }}` expression is interpolated directly into the run: script and then written to GITHUB_PATH with no newline sanitization.

2. **Use provided AgentShield** step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` is set via a direct expression, and then `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` writes it to GITHUB_PATH without sanitization. Routing through a shell variable does not sanitize the value.

Locations:

- `action.yml:127`
- `action.yml:146`

### unpinned-uses (severity: high)

The step `Upload SARIF to GitHub Code Scanning` uses `github/codeql-action/upload-sarif@v4`, which is pinned to a mutable tag (`@v4`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, making this a supply-chain risk. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:199`

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
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions into env: blocks for each affected step (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables.
2. github-env-injection: Both GITHUB_PATH writes (in 'Download AgentShield' and 'Use provided AgentShield' steps) now sanitize the path with `safe_path=$(printf '%s' "..." | tr -d '\n\r')` before writing to $GITHUB_PATH.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif from @v4 to @6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee # v4.

### Iteration 2

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Fixed two high-severity findings in action.yml:

1. github-env-injection (line 83): Added newline sanitization before writing VERSION to GITHUB_OUTPUT. Added `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` and changed the echo to use `safe_version` instead of `VERSION`.

2. script-injection (lines 143-170): Replaced the unquoted string-based `$ARGS` variable with a bash array. Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) is now properly double-quoted when added to the array with `ARGS+=(--flag "$VALUE")`, and the command is invoked with `agentshield "${ARGS[@]}"` to preserve argument boundaries and prevent word splitting/glob expansion.

