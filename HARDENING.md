<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **aiconnai--agentshield/v0.8.7** was hardened automatically. 15 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ inputs.* }}`, `${{ runner.* }}`, and `${{ steps.*.outputs.* }}` expressions inside shell command strings (rule a). This allows an attacker-controlled value to be injected into the shell before quoting can protect it.

Affected lines and offending expressions:
- Step 'Determine version' (line 57): `if [ "${{ inputs.version }}" = "latest" ]`
- Step 'Determine version' (line 64): `VERSION="${{ inputs.version }}"`
- Step 'Determine platform' (line 70): `case "${{ runner.os }}-${{ runner.arch }}" in`
- Step 'Determine platform' (line 76): `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`
- Step 'Download AgentShield' (line 82): `VERSION="${{ steps.version.outputs.version }}"`
- Step 'Download AgentShield' (line 83): `TARGET="${{ steps.platform.outputs.target }}"`
- Step 'Download AgentShield' (line 87): `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`
- Step 'Download AgentShield' (line 90): `mkdir -p ${{ runner.temp }}/agentshield`
- Step 'Download AgentShield' (line 93): `chmod +x ${{ runner.temp }}/agentshield/agentshield*`
- Step 'Download AgentShield' (line 94): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`
- Step 'Use provided AgentShield' (line 100): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`
- Step 'Run scan' (line 108): `ARGS="scan ${{ inputs.path }}"`
- Step 'Run scan' (line 109): `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`
- Step 'Run scan' (line 111): `if [ "${{ inputs.format }}" = "sarif" ]`
- Step 'Run scan' (line 112): `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`
- Step 'Run scan' (line 114): `ARGS="$ARGS --format ${{ inputs.format }}"`
- Step 'Run scan' (line 117): `if [ -n "${{ inputs.config }}" ]`
- Step 'Run scan' (line 118): `ARGS="$ARGS --config ${{ inputs.config }}"`
- Step 'Run scan' (line 121): `if [ -n "${{ inputs.baseline }}" ]`
- Step 'Run scan' (line 122): `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`
- Step 'Run scan' (line 125): `if [ "${{ inputs.ignore-tests }}" = "true" ]`
- Step 'Check result' (line 155): `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`

Fix: move all `${{ inputs.* }}` and `${{ runner.* }}` values into `env:` variables and reference them as `"$VAR"` inside the shell script.

Locations:

- `action.yml:57`
- `action.yml:64`
- `action.yml:70`
- `action.yml:76`
- `action.yml:82`
- `action.yml:83`
- `action.yml:87`
- `action.yml:90`
- `action.yml:93`
- `action.yml:94`
- `action.yml:100`
- `action.yml:108`
- `action.yml:109`
- `action.yml:111`
- `action.yml:112`
- `action.yml:114`
- `action.yml:117`
- `action.yml:118`
- `action.yml:121`
- `action.yml:122`
- `action.yml:125`
- `action.yml:155`

### github-env-injection (severity: high)

Multiple `run:` steps write values derived from untrusted inputs or workflow-controlled contexts to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`).

- Step 'Determine version' (line 66): `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is set from `${{ inputs.version }}` (attacker-controlled) without sanitization.
- Step 'Determine platform' (line 78): `echo "target=$TARGET" >> $GITHUB_OUTPUT` — TARGET is derived from `${{ runner.os }}-${{ runner.arch }}` without sanitization.
- Step 'Download AgentShield' (line 94): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — runner.temp written directly to GITHUB_PATH without sanitization.
- Step 'Run scan' (line 130): `echo "exit-code=$EXIT_CODE" >> $GITHUB_OUTPUT` and `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is derived from `${{ runner.temp }}` and `${{ inputs.format }}` without sanitization.
- Step 'Run scan' (line 143): `echo "AGENTSHIELD_EXIT=$EXIT_CODE" >> $GITHUB_ENV` — writes to GITHUB_ENV without sanitization.

A newline character embedded in any of these values could allow an attacker to inject arbitrary environment variables or path entries.

Locations:

- `action.yml:66`
- `action.yml:78`
- `action.yml:94`
- `action.yml:130`
- `action.yml:143`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v4` using a mutable tag (`@v4`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. Pin to a specific SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:148`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:66`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Determine version"; move to env: map

Locations:

- `action.yml:77`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.path }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:140`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:141`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:144`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.format }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:148`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:151`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.config }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:152`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.baseline }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:155`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.baseline }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:156`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.ignore-tests }}" appears directly in run: block of step "Run scan"; move to env: map

Locations:

- `action.yml:159`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on }}" appears directly in run: block of step "Check result"; move to env: map

Locations:

- `action.yml:194`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all security findings in actions/hardened/aiconnai--agentshield/v0.8.7/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks into env: blocks. Each step now has an env: section with named variables (INPUT_VERSION, INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE, INPUT_IGNORE_TESTS, RUNNER_TEMP_DIR, RUNNER_OS_INPUT, RUNNER_ARCH_INPUT, STEP_VERSION, STEP_TARGET). Shell scripts reference these as plain $VAR_NAME. The Run scan step uses a bash array (args=()) to safely build the command without shell injection risk.

2. github-env-injection: All writes to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH now sanitize values first using `printf '%s' "$VAR" | tr -d '\n\r'` to strip embedded newlines that could allow injection of additional environment variables or path entries.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif from @v4 to @8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4 using the resolved SHA.

