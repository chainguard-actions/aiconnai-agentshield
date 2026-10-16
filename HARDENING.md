<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions from untrusted/workflow-controllable contexts are directly interpolated inside run: shell command strings across several steps in action.yml. This includes: (a) inputs.version directly in shell comparison and assignment in 'Determine version' step (`if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`); (b) runner.os and runner.arch in a case statement in 'Determine platform' step (`case "${{ runner.os }}-${{ runner.arch }}"`); (c) steps.version.outputs.version and steps.platform.outputs.target assigned to shell variables in 'Download AgentShield' step; (d) runner.temp used unquoted in mkdir, unzip, chmod, and echo commands; (e) inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.baseline, inputs.ignore-tests all directly interpolated into the ARGS string in the 'Run scan' step; (f) inputs.fail-on, steps.scan.outputs.no_adapter, and inputs.strict directly interpolated in the 'Check result' step. Any of these can allow shell metacharacter injection by a caller supplying a crafted input value.

Locations:

- `action.yml:68`
- `action.yml:72`
- `action.yml:86`
- `action.yml:95`
- `action.yml:96`
- `action.yml:101`
- `action.yml:104`
- `action.yml:107`
- `action.yml:116`
- `action.yml:122`
- `action.yml:130`
- `action.yml:133`
- `action.yml:143`
- `action.yml:148`
- `action.yml:153`
- `action.yml:196`
- `action.yml:200`
- `action.yml:203`

### github-env-injection (severity: high)

Untrusted input values are written to GitHub special environment files without sanitization. (1) In the 'Determine version' step, VERSION is derived from ${{ inputs.version }} (caller-controlled) and written to $GITHUB_OUTPUT via `echo "version=$VERSION" >> $GITHUB_OUTPUT` with no `printf '%s' ... | tr -d '\n\r'` sanitization step. (2) In the 'Download AgentShield' step, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes a ${{ }} expression directly to $GITHUB_PATH without sanitization. (3) In the 'Run scan' step, SARIF_FILE (derived from ${{ runner.temp }}) is written to $GITHUB_OUTPUT via `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` without sanitization.

Locations:

- `action.yml:83`
- `action.yml:107`
- `action.yml:170`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4` which is pinned to a mutable tag (`v4`) rather than an immutable 40-character commit SHA. This means the referenced action could be changed by the upstream repository without notice, enabling a supply-chain attack.

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

Rewrote hardened/action/action.yml with the following changes:
1. script-injection / static-inline-injection: Moved all ${{ }} expressions out of run: shell strings into step-level env: blocks. Affected steps: 'Determine version' (inputs.version), 'Determine platform' (runner.os, runner.arch), 'Download AgentShield' (steps.version.outputs.version, steps.platform.outputs.target, runner.temp), 'Use provided AgentShield' (runner.temp), 'Run scan' (inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.baseline, inputs.ignore-tests, runner.temp), 'Check result' (inputs.fail-on, inputs.strict, steps.scan.outputs.no_adapter). All are now referenced as plain $ENV_VAR in shell.
2. github-env-injection: Sanitized values written to $GITHUB_OUTPUT and $GITHUB_PATH using `printf '%s' "$VAR" | tr -d '\n\r'` before writing. Applied to: VERSION written to GITHUB_OUTPUT in 'Determine version', runner.temp path written to GITHUB_PATH in 'Download AgentShield', SARIF_FILE written to GITHUB_OUTPUT in 'Run scan'.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to @6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee # v4.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Replaced the string-based ARGS accumulation (where user-controlled inputs were expanded unquoted) with a bash array. Changed:
- `ARGS="scan $INPUT_PATH"` → `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")`
- All subsequent `ARGS="$ARGS --flag $INPUT_VAR"` → `ARGS+=(--flag "$INPUT_VAR")` with proper double-quoting
- `agentshield $ARGS` → `agentshield "${ARGS[@]}"` to properly expand the array

This ensures each user-controlled input value is treated as a single argument and shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) cannot be injected to execute arbitrary commands.

