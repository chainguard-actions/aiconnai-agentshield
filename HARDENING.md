<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 24 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Determine version' step directly interpolates `${{ inputs.version }}` inside the run: shell script on two lines. This allows an attacker-controlled input to be injected into the shell before quoting can protect it. Offending lines: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`

Locations:

- `action.yml:71`
- `action.yml:83`

### script-injection (severity: high)

Sub-rule (a): The 'Determine platform' step directly interpolates `${{ runner.os }}` and `${{ runner.arch }}` inside the run: shell script. Any `${{ ... }}` expression inside a run: block is a script-injection risk regardless of context. Offending line: `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo.

Locations:

- `action.yml:101`
- `action.yml:107`

### script-injection (severity: high)

Sub-rule (a): The 'Download AgentShield' step directly interpolates `${{ steps.version.outputs.version }}`, `${{ steps.platform.outputs.target }}`, and `${{ runner.temp }}` inside the run: shell script. Offending lines include: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, and `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

Locations:

- `action.yml:116`
- `action.yml:117`
- `action.yml:122`
- `action.yml:125`
- `action.yml:128`
- `action.yml:129`

### script-injection (severity: high)

Sub-rule (a): The 'Use provided AgentShield' step directly interpolates `${{ runner.temp }}` inside the run: shell script. Offending line: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

Locations:

- `action.yml:143`

### script-injection (severity: high)

Sub-rule (a): The 'Run scan' step directly interpolates multiple `${{ inputs.* }}` and `${{ runner.temp }}` expressions inside the run: shell script. Offending lines include: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`. All inputs (path, fail-on, format, config, baseline, ignore-tests) are attacker-controlled.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:158`
- `action.yml:159`
- `action.yml:161`
- `action.yml:164`
- `action.yml:165`
- `action.yml:168`
- `action.yml:169`
- `action.yml:172`

### script-injection (severity: high)

Sub-rule (a): The 'Check result' step directly interpolates `${{ inputs.fail-on }}`, `${{ steps.scan.outputs.no_adapter }}`, and `${{ inputs.strict }}` inside the run: shell script. Offending lines: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]`, and `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]`.

Locations:

- `action.yml:225`
- `action.yml:227`
- `action.yml:230`

### github-env-injection (severity: high)

The 'Determine version' step writes `$VERSION` (derived from `${{ inputs.version }}` without sanitization) to `$GITHUB_OUTPUT` via `echo "version=$VERSION" >> $GITHUB_OUTPUT`. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write. An attacker-controlled `inputs.version` containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:92`

### github-env-injection (severity: high)

The 'Determine platform' step writes `$TARGET` (derived from `${{ runner.os }}-${{ runner.arch }}` without sanitization) to `$GITHUB_OUTPUT` via `echo "target=$TARGET" >> $GITHUB_OUTPUT`. No sanitization is applied before the write.

Locations:

- `action.yml:108`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `${{ runner.temp }}/agentshield` directly to `$GITHUB_PATH` via `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The `${{ runner.temp }}` expression is interpolated directly into the shell and then written to GITHUB_PATH without sanitization.

Locations:

- `action.yml:129`

### github-env-injection (severity: high)

The 'Run scan' step writes `$SARIF_FILE` (which contains `${{ runner.temp }}/agentshield-results.sarif`, derived from the runner.temp context) to `$GITHUB_OUTPUT` via `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` without sanitization. Additionally, `echo "AGENTSHIELD_EXIT=$EXIT_CODE" >> $GITHUB_ENV` writes to GITHUB_ENV (EXIT_CODE is locally computed and safe, but the SARIF_FILE write is not).

Locations:

- `action.yml:183`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4` which is pinned to a mutable tag (`@v4`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved to a different commit. It should be pinned to a specific SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:236`

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

1. **script-injection / static-inline-injection**: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks into env: blocks for all 5 affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables.

2. **github-env-injection**: Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization before writing to $GITHUB_OUTPUT (version, target, sarif-file) and $GITHUB_PATH (agentshield directory path). The AGENTSHIELD_EXIT write to $GITHUB_ENV uses a locally-computed integer EXIT_CODE which is safe.

3. **unpinned-uses**: Pinned `github/codeql-action/upload-sarif@v4` to full commit SHA `@24c54180a607b1449ed407dd24f251e4e9147c8d # v4`.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection vulnerability in the 'Run scan' step of action.yml. Replaced the string-based ARGS variable (which concatenated unquoted user-controlled inputs and was then expanded unquoted as `agentshield $ARGS`) with a bash array. The array is initialized as `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")` and elements are appended with `ARGS+=(...)` using proper double-quoting. The final command uses `agentshield "${ARGS[@]}"` which expands each array element as a separate, properly-quoted argument, preventing shell metacharacters in input values (inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.baseline) from breaking out of the argument list.

