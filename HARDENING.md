<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 21 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Determine version' step puts ${{ inputs.version }} straight into its run: script: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

Rule (a): the 'Determine platform' step puts ${{ runner.os }} and ${{ runner.arch }} straight into its run: script: `case "${{ runner.os }}-${{ runner.arch }}" in`, and again in the error message.

Locations:

- `action.yml:100`
- `action.yml:106`

### script-injection (severity: high)

Rule (a): the 'Download AgentShield' step puts ${{ steps.version.outputs.version }}, ${{ steps.platform.outputs.target }} and ${{ runner.temp }} straight into its run: script, e.g. `VERSION="${{ steps.version.outputs.version }}"` and `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`. The runner.temp uses are also unquoted.

Locations:

- `action.yml:114`
- `action.yml:115`
- `action.yml:121`

### script-injection (severity: high)

Rule (a): the 'Use provided AgentShield' step puts ${{ runner.temp }} straight into its run: script: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

Locations:

- `action.yml:142`

### script-injection (severity: high)

Rule (a): the 'Run scan' step puts several inputs and runner.temp straight into its run: script, e.g. `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `ARGS="$ARGS --config ${{ inputs.config }}"` and `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`. Rule (b): it then runs `agentshield $ARGS` with $ARGS unquoted, so the shell splits and glob-expands those input values.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:179`

### script-injection (severity: high)

Rule (a): the 'Check result' step puts ${{ inputs.fail-on }}, ${{ steps.scan.outputs.no_adapter }} and ${{ inputs.strict }} straight into its run: script, e.g. `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`.

Locations:

- `action.yml:247`
- `action.yml:250`

### github-env-injection (severity: high)

The 'Determine version' step sets VERSION from ${{ inputs.version }}, adding a 'v' prefix if missing, then writes it to $GITHUB_OUTPUT with `echo "version=$VERSION" >> $GITHUB_OUTPUT`. The value is not passed through `printf '%s' ... | tr -d '\n\r'` first, so a newline in the input can inject extra outputs.

Locations:

- `action.yml:93`

### unpinned-uses (severity: high)

A composite step uses a tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v4`.

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

All findings fixed in action.yml. Every ${{ }} expression in a run: block (inputs.version, path, fail-on, format, config, baseline, ignore-tests, strict, runner.os/arch/temp, step outputs) now goes through the step's env: block and is read as a quoted shell variable. The Run scan step now builds the agentshield command as a bash array, so path, config and baseline each stay one argument. This is a behaviour change: before, the unquoted $ARGS was split on whitespace and glob-expanded. These inputs are single values, so a path containing spaces now works, but a value that relied on splitting into several arguments would break. The SARIF file path is passed to the python counter as sys.argv instead of being pasted into the python code. The version output (and the sarif-file output and the GITHUB_PATH entry) has newlines stripped with printf | tr -d '\n\r' before it is written. github/codeql-action/upload-sarif@v4 is pinned to 9b3254085494b55a0f7c4c2b3d2d52cc712ce370 (# v4). My first batch of parallel edits garbled the file, so I rewrote it in one pass and re-read it to check. The action was not run.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Use provided AgentShield' step, the directory name is now saved to a variable first (DEST_DIR="$(dirname ...)"). Newlines and carriage returns are then stripped with printf '%s' | tr -d '\n\r' before the path is added to $GITHUB_PATH. This is the same SAFE_PATH approach the 'Download AgentShield' step uses. Saving the dirname result first means a failure there still stops the step, because bash -e sees its exit status.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

action.yml:158 now uses 'DEST_DIR="$(dirname "$AGENTSHIELD_DEST")" || true' to keep upstream's non-aborting behaviour while still sanitizing before writing to GITHUB_PATH.

