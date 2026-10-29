<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.3** was hardened automatically. 21 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Step 'Determine version' breaks rule (a): it puts ${{ inputs.version }} straight into the shell script: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

Step 'Determine platform' breaks rule (a): it puts ${{ runner.os }} and ${{ runner.arch }} straight into the script: `case "${{ runner.os }}-${{ runner.arch }}" in`. The same expressions appear again in the error echo.

Locations:

- `action.yml:100`
- `action.yml:106`

### script-injection (severity: high)

Step 'Download AgentShield' breaks rule (a): it puts step outputs and runner context straight into the script: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, and unquoted `${{ runner.temp }}` in the unzip/mkdir/tar/chmod lines and the echo to $GITHUB_PATH. The version output comes from the user-controlled inputs.version.

Locations:

- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:130`

### script-injection (severity: high)

Step 'Use provided AgentShield' breaks rule (a): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` puts an expression straight into the script. It should use "$RUNNER_TEMP" instead.

Locations:

- `action.yml:142`

### script-injection (severity: high)

Step 'Run scan' breaks rule (a): it puts many expressions straight into the script, including `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `${{ inputs.ignore-tests }}` and `${{ runner.temp }}`. It also breaks rule (b): the input-derived string is expanded unquoted in `agentshield $ARGS 2>&1 | tee "$SCAN_LOG"`, so the shell word-splits and glob-expands it.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:159`
- `action.yml:167`
- `action.yml:171`
- `action.yml:179`

### script-injection (severity: high)

Step 'Check result' breaks rule (a): it puts expressions straight into the script: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`, plus `${{ steps.scan.outputs.no_adapter }}` and `${{ inputs.strict }}` in the if conditions.

Locations:

- `action.yml:247`

### github-env-injection (severity: high)

Step 'Determine version' takes VERSION from the user-controlled inputs.version (VERSION="${{ inputs.version }}", with only a 'v' prefix added) and writes it with `echo "version=$VERSION" >> $GITHUB_OUTPUT`. There is no `printf '%s' ... | tr -d '\n\r'` sanitization before the write, so a newline in the input can inject extra outputs.

Locations:

- `action.yml:93`

### unpinned-uses (severity: high)

The composite step points to a mutable tag instead of a 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v4`.

Locations:

- `action.yml:237`

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

Changes in action.yml: inputs.version, the step outputs (version, target, no_adapter), inputs.path/fail-on/format/config/baseline/ignore-tests/strict now go through each step's env: block. runner.os/arch/temp are replaced with $RUNNER_OS/$RUNNER_ARCH/$RUNNER_TEMP. The Run scan step builds a bash array, so each value stays one quoted argument (optional ones drop out when empty, as upstream's unquoted expansion did). The SARIF path is passed to python as an argument (sys.argv) instead of being written into the script text. VERSION has newlines stripped before it is written to $GITHUB_OUTPUT. github/codeql-action/upload-sarif is pinned to 9b3254085494b55a0f7c4c2b3d2d52cc712ce370 (# v4).

