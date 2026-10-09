<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.5** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ }}` expressions are directly interpolated into run: shell scripts across four steps in action.yml. Attacker-controllable inputs are injected directly into shell command strings before the shell processes them, enabling shell metacharacter injection.

'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`

'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` and the wildcard error branch `${{ runner.os }}-${{ runner.arch }}`

'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip ... -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar ... -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`

'Check result' step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`

All inputs (path, fail-on, format, config, ignore-tests, version) are caller-controlled and must be passed via env: variables and properly quoted, never interpolated directly into run: scripts.

Locations:

- `action.yml:57`
- `action.yml:62`
- `action.yml:68`
- `action.yml:74`
- `action.yml:79`
- `action.yml:80`
- `action.yml:86`
- `action.yml:89`
- `action.yml:91`
- `action.yml:93`
- `action.yml:94`
- `action.yml:98`
- `action.yml:99`
- `action.yml:101`
- `action.yml:102`
- `action.yml:105`
- `action.yml:108`
- `action.yml:109`
- `action.yml:112`
- `action.yml:141`

### github-env-injection (severity: high)

Untrusted or workflow-controlled values are written to special GitHub environment files without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. 'Download AgentShield' step (line 94): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — the `${{ runner.temp }}` expression is written directly to GITHUB_PATH without sanitization. A newline embedded in the value could inject arbitrary entries into PATH.

2. 'Determine version' step (line 64): `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is derived from `${{ inputs.version }}` (caller-controlled) without sanitization. A newline in the value could inject additional key=value pairs into GITHUB_OUTPUT.

3. 'Run scan' step (line 120): `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is set from `${{ runner.temp }}/agentshield-results.sarif` (runner.temp is workflow-controlled) without sanitization before the write.

Locations:

- `action.yml:94`
- `action.yml:64`
- `action.yml:120`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v3` which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Rewrote action.yml to fix all findings:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: shell scripts into env: blocks for all five affected steps (Determine version, Determine platform, Download AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS, $RUNNER_ARCH, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_IGNORE_TESTS).

2. github-env-injection: Added sanitization with `printf '%s' "$VAR" | tr -d '\n\r'` before writing to GITHUB_OUTPUT (version in Determine version step, sarif-file in Run scan step) and GITHUB_PATH (path in Download AgentShield step).

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v3 to the full commit SHA @9f759ee644a3e7c15c1390abf49868036c00067b with # v3 comment for readability.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in action.yml:
1. Line 145: Replaced unquoted string-based `$ARGS` expansion (`agentshield $ARGS`) with a bash array approach. Arguments are now accumulated with `ARGS=("scan" "$INPUT_PATH")` and `ARGS+=(...)`, then expanded as `agentshield "${ARGS[@]}"`. This prevents word splitting and glob expansion on attacker-controlled input values (path, fail-on, format, config).
2. Line 155: Replaced `python3 -c "import json; d=json.load(open('$SARIF_FILE')); ..."` with `python3 -c "import json,sys; d=json.load(open(sys.argv[1])); ..." "$SARIF_FILE"`. The SARIF file path is now passed as a command-line argument (accessed via `sys.argv[1]`) rather than being interpolated inside the Python code string, eliminating injection risk from special characters in the runner.temp path.

