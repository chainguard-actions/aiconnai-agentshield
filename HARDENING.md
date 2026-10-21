<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.6** was hardened automatically. 17 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Step 'Determine version', rule (a): an expression is written straight into the run: script. Lines: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`.

Locations:

- `action.yml:57`
- `action.yml:64`

### script-injection (severity: high)

Step 'Determine platform', rule (a): an expression is written straight into the run: script. Lines: `case "${{ runner.os }}-${{ runner.arch }}" in` and `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`.

Locations:

- `action.yml:72`
- `action.yml:78`

### script-injection (severity: high)

Step 'Download AgentShield', rule (a): expressions are written straight into the run: script. Lines: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, and `${{ runner.temp }}` used unquoted in unzip/mkdir/tar/chmod/echo.

Locations:

- `action.yml:85`
- `action.yml:86`
- `action.yml:92`

### script-injection (severity: high)

Step 'Run scan', rule (a): inputs are written straight into the script, e.g. `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `ARGS="$ARGS --config ${{ inputs.config }}"`, plus `${{ inputs.ignore-tests }}` and `${{ runner.temp }}`. Rule (b) also applies: these values are later expanded unquoted in `agentshield $ARGS`.

Locations:

- `action.yml:107`
- `action.yml:108`
- `action.yml:115`
- `action.yml:119`
- `action.yml:127`

### script-injection (severity: high)

Step 'Check result', rule (a): an expression is written straight into the run: script. Line: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`.

Locations:

- `action.yml:157`

### github-env-injection (severity: high)

Step 'Determine version': VERSION comes from `${{ inputs.version }}` and is written with `echo "version=$VERSION" >> $GITHUB_OUTPUT` without the `printf '%s' ... | tr -d '\n\r'` sanitization step.

Locations:

- `action.yml:66`

### unpinned-uses (severity: high)

The composite step pins to a tag, not a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:147`

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

Moved every inputs.*, runner.* and steps.* expression from the run: scripts into step env: blocks, and quoted them where they are used. The agentshield command is now built as a bash array, so path, fail-on, format and config each reach it as one argument. The version, sarif-file and GITHUB_PATH values have newlines stripped before they are written. The python SARIF count now gets the file path as an argument instead of having it pasted into the code. Pinned github/codeql-action/upload-sarif to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (v3).

