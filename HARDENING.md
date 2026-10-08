<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.3** was hardened automatically. 16 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in action.yml. This allows template substitution to inject arbitrary shell metacharacters before the shell ever parses the command.

'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is attacker-controlled.

'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` and error message with `${{ runner.os }}-${{ runner.arch }}` — runner.* context values flow through YAML template substitution.

'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip ... -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar ... -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

'Run scan' step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`.

'Check result' step: `'${{ inputs.fail-on }}'`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}`.

All inputs.* values are attacker-controllable; all ${{ }} in run: blocks are script-injection risks.

Locations:

- `action.yml:71`
- `action.yml:82`
- `action.yml:95`
- `action.yml:100`
- `action.yml:108`
- `action.yml:109`
- `action.yml:114`
- `action.yml:117`
- `action.yml:119`
- `action.yml:122`
- `action.yml:123`
- `action.yml:133`
- `action.yml:144`
- `action.yml:145`
- `action.yml:146`
- `action.yml:149`
- `action.yml:150`
- `action.yml:153`
- `action.yml:156`
- `action.yml:157`
- `action.yml:160`
- `action.yml:161`
- `action.yml:164`
- `action.yml:202`
- `action.yml:204`
- `action.yml:208`

### github-env-injection (severity: high)

Multiple run: blocks write values derived from untrusted inputs or ${{ }} expressions to $GITHUB_OUTPUT, $GITHUB_ENV, or $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is derived from `${{ inputs.version }}` (attacker-controlled) without sanitization.

2. 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — direct ${{ runner.temp }} expression written to GITHUB_PATH without sanitization.

3. 'Use provided AgentShield' step: `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` — AGENTSHIELD_DEST is set to `${{ runner.temp }}/agentshield/agentshield` (a ${{ }} expression) without sanitization before the GITHUB_PATH write.

4. 'Run scan' step: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is set to `${{ runner.temp }}/agentshield-results.sarif` (a ${{ }} expression) without sanitization.

Locations:

- `action.yml:87`
- `action.yml:123`
- `action.yml:138`
- `action.yml:170`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4` which is pinned to a mutable tag (`@v4`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:191`

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

1. **script-injection / static-inline-injection**: Moved all ${{ }} expressions from run: shell strings to env: blocks in each step. Specifically:
   - 'Determine version': INPUT_VERSION=${{ inputs.version }}
   - 'Determine platform': RUNNER_OS_INPUT=${{ runner.os }}, RUNNER_ARCH_INPUT=${{ runner.arch }}
   - 'Download AgentShield': STEP_VERSION=${{ steps.version.outputs.version }}, STEP_TARGET=${{ steps.platform.outputs.target }}, RUNNER_TEMP_DIR=${{ runner.temp }}
   - 'Use provided AgentShield': AGENTSHIELD_BINARY_PATH=${{ inputs.binary-path }}, RUNNER_TEMP_DIR=${{ runner.temp }}
   - 'Run scan': RUNNER_TEMP_DIR=${{ runner.temp }}, INPUT_PATH=${{ inputs.path }}, INPUT_FAIL_ON=${{ inputs.fail-on }}, INPUT_FORMAT=${{ inputs.format }}, INPUT_CONFIG=${{ inputs.config }}, INPUT_BASELINE=${{ inputs.baseline }}, INPUT_IGNORE_TESTS=${{ inputs.ignore-tests }}
   - 'Check result': INPUT_FAIL_ON=${{ inputs.fail-on }}, STEP_NO_ADAPTER=${{ steps.scan.outputs.no_adapter }}, INPUT_STRICT=${{ inputs.strict }}
   Also converted ARGS string-building to bash arrays for proper argument handling.

2. **github-env-injection**: Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization before writing to $GITHUB_OUTPUT and $GITHUB_PATH in all affected steps.

3. **unpinned-uses**: Pinned `github/codeql-action/upload-sarif@v4` to `@24c54180a607b1449ed407dd24f251e4e9147c8d # v4`.

