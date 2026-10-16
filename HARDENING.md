<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 21 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are directly interpolated inside run: shell commands in the 'Determine version' step. The expression `${{ inputs.version }}` appears directly in shell command strings (e.g., `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`). Any ${{ }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the value, allowing an attacker to inject shell metacharacters.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

Sub-rule (a): The 'Determine platform' step directly interpolates `${{ runner.os }}` and `${{ runner.arch }}` inside a run: shell command string: `case "${{ runner.os }}-${{ runner.arch }}" in`. Any ${{ }} expression in a run: block is a script-injection finding regardless of which context it reads from, as YAML template substitution happens before shell quoting.

Locations:

- `action.yml:99`
- `action.yml:105`

### script-injection (severity: high)

Sub-rule (a): The 'Download AgentShield' step directly interpolates multiple ${{ }} expressions inside run: shell commands: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, and `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. These are all direct ${{ }} interpolations inside shell run blocks.

Locations:

- `action.yml:113`
- `action.yml:114`
- `action.yml:119`
- `action.yml:122`
- `action.yml:125`
- `action.yml:126`

### script-injection (severity: high)

Sub-rule (a): The 'Use provided AgentShield' step directly interpolates `${{ runner.temp }}` inside a run: shell command string: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`. This is a direct ${{ }} interpolation inside a shell run block.

Locations:

- `action.yml:134`

### script-injection (severity: high)

Sub-rule (a): The 'Run scan' step directly interpolates multiple ${{ }} expressions inside run: shell commands, including attacker-controllable inputs: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `if [ -n "${{ inputs.baseline }}" ]`, and `if [ "${{ inputs.ignore-tests }}" = "true" ]`. Attacker-controlled inputs (path, fail-on, format, config, baseline, ignore-tests) are interpolated directly into shell command strings, enabling command injection.

Locations:

- `action.yml:145`
- `action.yml:146`
- `action.yml:147`
- `action.yml:150`
- `action.yml:153`
- `action.yml:156`
- `action.yml:160`
- `action.yml:164`

### script-injection (severity: high)

Sub-rule (a): The 'Check result' step directly interpolates attacker-controllable ${{ }} expressions inside run: shell commands: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]`, and `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]`. The inputs.fail-on and inputs.strict values are attacker-controlled and interpolated directly into shell.

Locations:

- `action.yml:204`
- `action.yml:206`
- `action.yml:209`

### github-env-injection (severity: high)

The 'Determine version' step writes the value of `inputs.version` (an attacker-controllable input) to $GITHUB_OUTPUT without sanitization. The value is assigned via `VERSION="${{ inputs.version }}"` and then written as `echo "version=$VERSION" >> $GITHUB_OUTPUT`. No `printf '%s' ... | tr -d '\n\r'` sanitization step is applied before the write. A newline-containing input value could inject additional key=value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:81`
- `action.yml:92`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4` which references a mutable tag (`@v4`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks where the tag could be moved to point to malicious code. It should be pinned to a specific commit SHA, e.g., `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:195`

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

Fixed all findings in action.yml:
1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: shell blocks into env: blocks for every affected step (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS_INPUT, $RUNNER_ARCH_INPUT, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP_DIR, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $INPUT_STRICT, $STEP_NO_ADAPTER).
2. github-env-injection: Added sanitization of the version value before writing to $GITHUB_OUTPUT using `safe_version="$(printf '%s' "$VERSION" | tr -d '\n\r')"` and writing `$safe_version` instead of `$VERSION`.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA @6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee # v4.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the 'Run scan' step in action.yml by replacing the string-based ARGS accumulation with a bash array. Changed `ARGS="scan $INPUT_PATH"` and subsequent unquoted concatenations to `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")` with `ARGS+=(...)` for subsequent additions. All user-controlled inputs ($INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE) are now properly double-quoted within the array. The final invocation was changed from `agentshield $ARGS` to `agentshield "${ARGS[@]}"` to safely expand the array with proper argument boundaries.

