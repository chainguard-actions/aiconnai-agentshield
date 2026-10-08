<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 23 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Determine version' step directly interpolates ${{ inputs.version }} inside the run: shell script. Attacker-controlled input is substituted into the shell command string before the shell parses it, enabling command injection. Offending lines: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`

Locations:

- `action.yml:66`
- `action.yml:76`

### script-injection (severity: high)

Rule (a): The 'Determine platform' step directly interpolates ${{ runner.os }} and ${{ runner.arch }} inside the run: shell script. Any ${{ ... }} expression in a run: block is a script-injection risk. Offending line: `case "${{ runner.os }}-${{ runner.arch }}" in`

Locations:

- `action.yml:93`

### script-injection (severity: high)

Rule (a): The 'Download AgentShield' step directly interpolates ${{ steps.version.outputs.version }}, ${{ steps.platform.outputs.target }}, and ${{ runner.temp }} inside the run: shell script. Offending lines include: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, and `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

Locations:

- `action.yml:105`
- `action.yml:106`
- `action.yml:110`
- `action.yml:113`
- `action.yml:116`
- `action.yml:117`

### script-injection (severity: high)

Rule (a): The 'Use provided AgentShield' step directly interpolates ${{ runner.temp }} inside the run: shell script. Offending line: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`

Locations:

- `action.yml:127`

### script-injection (severity: high)

Rule (a): The 'Run scan' step directly interpolates multiple ${{ inputs.* }} and ${{ runner.temp }} expressions inside the run: shell script. Attacker-controlled inputs (path, fail-on, format, config, baseline, ignore-tests) are substituted directly into shell command strings. Offending lines include: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`

Locations:

- `action.yml:138`
- `action.yml:139`
- `action.yml:140`
- `action.yml:143`
- `action.yml:144`
- `action.yml:147`
- `action.yml:150`
- `action.yml:151`
- `action.yml:154`
- `action.yml:155`
- `action.yml:158`

### script-injection (severity: high)

Rule (a): The 'Check result' step directly interpolates ${{ inputs.fail-on }}, ${{ steps.scan.outputs.no_adapter }}, and ${{ inputs.strict }} inside the run: shell script. Offending lines include: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]`, and `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]`

Locations:

- `action.yml:196`
- `action.yml:198`
- `action.yml:202`

### github-env-injection (severity: high)

The 'Determine version' step writes $VERSION (derived from ${{ inputs.version }}, an attacker-controlled input) to $GITHUB_OUTPUT without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). A malicious version value containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:86`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `${{ runner.temp }}/agentshield` directly to $GITHUB_PATH without sanitization. Although runner.temp is GitHub-controlled, the ${{ ... }} expression is substituted before the shell runs, and no sanitization (tr -d newlines) is applied before the write to $GITHUB_PATH.

Locations:

- `action.yml:117`

### github-env-injection (severity: high)

The 'Run scan' step writes $SARIF_FILE (derived from ${{ runner.temp }}, interpolated directly) to $GITHUB_OUTPUT, and writes ${{ inputs.path }}, ${{ inputs.fail-on }}, ${{ inputs.format }}, ${{ inputs.config }}, ${{ inputs.baseline }} (all attacker-controlled inputs) into the $ARGS variable which is then used in shell execution — and also writes AGENTSHIELD_EXIT=$EXIT_CODE to $GITHUB_ENV. None of these writes are preceded by the required `printf '%s' ... | tr -d '\n\r'` sanitization.

Locations:

- `action.yml:168`
- `action.yml:170`
- `action.yml:188`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v4`, which is pinned to a mutable tag (`v4`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved to a different commit. It should be pinned to a specific SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:185`

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

Fixed all security findings in hardened/action/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.* }} expressions from run: blocks into env: blocks for all 6 affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS, $RUNNER_ARCH, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $STEP_NO_ADAPTER, $INPUT_STRICT).

2. github-env-injection: Added printf '%s' "$VAR" | tr -d '\n\r' sanitization before all writes to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH (version, sarif-file, finding-count, AGENTSHIELD_EXIT, and path values).

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA @24c54180a607b1449ed407dd24f251e4e9147c8d # v4.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Replaced the unquoted $ARGS string concatenation pattern with a bash array: changed `ARGS="scan $INPUT_PATH"` and subsequent `ARGS="$ARGS --flag $VALUE"` concatenations to `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")` and `ARGS+=(--flag "$VALUE")` array operations. Changed the final command from `agentshield $ARGS` (unquoted) to `agentshield "${ARGS[@]}"` (properly quoted array expansion). This ensures each user-controlled input (path, fail-on, format, config, baseline) is treated as a single argument and cannot inject shell metacharacters.

