<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 16 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell blocks, violating sub-rule (a). This allows template substitution to inject arbitrary shell code before the shell parses the command.

'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is attacker-controlled.

'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo — runner.os/runner.arch are interpolated directly.

'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip ... -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

'Run scan' step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`.

'Check result' step: `'${{ inputs.fail-on }}'`, `"${{ steps.scan.outputs.no_adapter }}"`, `"${{ inputs.strict }}"`.

All inputs.* values are attacker-controllable; all ${{ ... }} in run: blocks are script-injection risks regardless of context.

Locations:

- `action.yml:65`
- `action.yml:76`
- `action.yml:88`
- `action.yml:93`
- `action.yml:100`
- `action.yml:101`
- `action.yml:105`
- `action.yml:108`
- `action.yml:111`
- `action.yml:112`
- `action.yml:120`
- `action.yml:129`
- `action.yml:130`
- `action.yml:131`
- `action.yml:134`
- `action.yml:135`
- `action.yml:137`
- `action.yml:140`
- `action.yml:141`
- `action.yml:144`
- `action.yml:145`
- `action.yml:148`
- `action.yml:232`
- `action.yml:234`

### github-env-injection (severity: high)

Unsanitized values derived from untrusted inputs are written to special GitHub environment files without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

(1) 'Determine version' step: `VERSION` is set directly from `${{ inputs.version }}` (attacker-controlled) and then written to $GITHUB_OUTPUT via `echo "version=$VERSION" >> $GITHUB_OUTPUT` without sanitization. A newline in inputs.version would allow injection of arbitrary key=value pairs into GITHUB_OUTPUT.

(2) 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes a ${{ }} expression directly to $GITHUB_PATH without sanitization.

Locations:

- `action.yml:84`
- `action.yml:112`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4`, which is pinned to a mutable tag (`v4`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks. It should be pinned to a specific SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:222`

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

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks into env: blocks for every step. Shell scripts now reference only environment variables ($INPUT_VERSION, $RUNNER_OS_INPUT, $RUNNER_ARCH_INPUT, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP_DIR, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $SCAN_NO_ADAPTER, $INPUT_STRICT).

2. github-env-injection: (a) 'Determine version' step: VERSION is sanitized with `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` before writing to $GITHUB_OUTPUT. (b) 'Download AgentShield' step: path is sanitized with `safe_path=$(printf '%s' "$RUNNER_TEMP_DIR/agentshield" | tr -d '\n\r')` before writing to $GITHUB_PATH.

3. unpinned-uses: Pinned `github/codeql-action/upload-sarif` from @v4 to @24c54180a607b1449ed407dd24f251e4e9147c8d # v4.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml. Replaced the string-based ARGS variable accumulation (where unquoted user-controlled inputs like INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, and INPUT_BASELINE were concatenated into a string and then passed to `agentshield $ARGS` unquoted) with a bash array. Each input value is now properly double-quoted as a separate array element (e.g., `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")`), and the command is invoked as `agentshield "${ARGS[@]}"`. This ensures shell metacharacters in input values are treated as literal data rather than shell syntax, preventing command injection.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. 'Use provided AgentShield' step (line 154): Added sanitization before writing to $GITHUB_PATH. Changed `echo "$(dirname "$AGENTSHIELD_DEST")" >> "$GITHUB_PATH"` to capture the dirname into a safe_path variable via `printf '%s' ... | tr -d '\n\r'` before echoing to $GITHUB_PATH.
2. 'Run scan' step (line 186): Added sanitization before writing sarif-file to $GITHUB_OUTPUT. Changed `echo "sarif-file=$SARIF_FILE" >> "$GITHUB_OUTPUT"` to first sanitize into safe_sarif via `printf '%s' "$SARIF_FILE" | tr -d '\n\r'` then echo the sanitized value. Both fixes follow the same pattern already used in the 'Download AgentShield' step.

