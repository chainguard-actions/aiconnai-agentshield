<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.6** was hardened automatically. 13 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings (rule a), allowing script injection. Affected steps and lines:
- "Determine version" step: `if [ "${{ inputs.version }}" = "latest" ]` (line 57) and `VERSION="${{ inputs.version }}"` (line 62) — inputs.version is attacker-controlled.
- "Determine platform" step: `case "${{ runner.os }}-${{ runner.arch }}" in` (line 67) and the error branch (line 73) — runner.* context values flow through YAML template substitution before the shell sees them.
- "Download AgentShield" step: `VERSION="${{ steps.version.outputs.version }}"` (line 79), `TARGET="${{ steps.platform.outputs.target }}"` (line 80), `unzip ... -d ${{ runner.temp }}/agentshield` (line 84), `mkdir -p ${{ runner.temp }}/agentshield` (line 87), `chmod +x ${{ runner.temp }}/agentshield/agentshield*` (line 90), `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` (line 91).
- "Run scan" step: `ARGS="scan ${{ inputs.path }}"` (line 94), `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"` (line 95), `if [ "${{ inputs.format }}" = "sarif" ]` (line 97), `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"` (line 98), `ARGS="$ARGS --format ${{ inputs.format }}"` (line 101), `if [ -n "${{ inputs.config }}" ]` (line 104), `ARGS="$ARGS --config ${{ inputs.config }}"` (line 105), `if [ "${{ inputs.ignore-tests }}" = "true" ]` (line 108).
- "Check result" step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"` (line 138).
All these must be moved to env: variables and the shell expansions must be double-quoted.

Locations:

- `action.yml:57`
- `action.yml:62`
- `action.yml:67`
- `action.yml:73`
- `action.yml:79`
- `action.yml:80`
- `action.yml:84`
- `action.yml:87`
- `action.yml:90`
- `action.yml:91`
- `action.yml:94`
- `action.yml:95`
- `action.yml:97`
- `action.yml:98`
- `action.yml:101`
- `action.yml:104`
- `action.yml:105`
- `action.yml:108`
- `action.yml:138`

### github-env-injection (severity: high)

Untrusted or workflow-controlled values are written to special GitHub environment files without sanitization (no `printf '%s' ... | tr -d '\n\r'` applied before the write):
1. "Determine version" step (line 63): `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is derived from `${{ inputs.version }}` (attacker-controlled) without sanitization.
2. "Download AgentShield" step (line 91): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — `${{ runner.temp }}` is a workflow-controlled context value written directly to GITHUB_PATH without sanitization.
3. "Run scan" step (line 119): `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is derived from `${{ runner.temp }}` without sanitization.
An attacker who can influence these values could inject newlines to poison the environment.

Locations:

- `action.yml:63`
- `action.yml:91`
- `action.yml:119`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3` — a mutable tag reference instead of a pinned 40-character SHA commit hash. If the tag is moved (e.g. by a supply-chain compromise), the action will silently execute different code. Pin to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:131`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:57`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:64`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.path }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:108`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:111`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:115`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:118`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:119`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.ignore-tests }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:122`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Check result"; move to env: map

Locations:

- `action.yml:157`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, static-inline-injection

**Notes:**

Rewrote action.yml to fix all findings:
1. script-injection / static-inline-injection: Moved all ${{ }} expressions (inputs.version, inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests, runner.os, runner.arch, runner.temp, steps.version.outputs.version, steps.platform.outputs.target) out of run: shell strings into env: blocks. Shell scripts now reference plain environment variables.
2. github-env-injection: Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization before writing to $GITHUB_OUTPUT (version, sarif-file) and $GITHUB_PATH (runner temp path).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v3 to full SHA ce5e7eeac396d720fe2d802714996c8ce561e311 with # v3 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the 'Run scan' step in action.yml by converting the ARGS string variable to a bash array. Changed:
- `ARGS="scan $INPUT_PATH"` → `ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON")`
- Subsequent string concatenations → array appends with `ARGS+=(...)` with each value properly double-quoted
- `agentshield $ARGS` → `agentshield "${ARGS[@]}"`

This ensures each user-controlled input (path, fail-on, format, config) is treated as a single argument regardless of its content, preventing word splitting and glob expansion on attacker-controlled data.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml (line 131). The original code embedded `$SARIF_FILE` unquoted inside a Python `-c` string literal: `python3 -c "import json; d=json.load(open('$SARIF_FILE')); ..."`. This was replaced with `python3 -c "import json,sys; d=json.load(open(sys.argv[1])); ..." "$SARIF_FILE"`, passing the file path as a properly double-quoted shell argument and reading it via `sys.argv[1]` in Python. This eliminates the injection vector entirely — `$SARIF_FILE` is no longer expanded inside the Python string literal.

