<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.5** was hardened automatically. 17 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Determine version' step puts an expression straight into the run: script, where the shell sees it as code: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`.

Locations:

- `action.yml:56`
- `action.yml:63`

### script-injection (severity: high)

Rule (a): the 'Determine platform' step puts runner context expressions straight into the run: script: `case "${{ runner.os }}-${{ runner.arch }}" in` and `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`. Use $RUNNER_OS and $RUNNER_ARCH instead.

Locations:

- `action.yml:71`
- `action.yml:77`

### script-injection (severity: high)

Rule (a): the 'Download AgentShield' step puts expressions straight into the run: script: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"` and several unquoted `${{ runner.temp }}` uses, e.g. `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`.

Locations:

- `action.yml:84`
- `action.yml:85`
- `action.yml:91`
- `action.yml:100`

### script-injection (severity: high)

Rule (a): the 'Run scan' step puts inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests and runner.temp straight into the run: script, e.g. `ARGS="scan ${{ inputs.path }}"` and `ARGS="$ARGS --config ${{ inputs.config }}"`. Rule (b): `agentshield $ARGS` expands the input-derived ARGS without quotes, so the shell word-splits it and expands globs in it.

Locations:

- `action.yml:106`
- `action.yml:107`
- `action.yml:117`
- `action.yml:126`

### script-injection (severity: high)

Rule (a): the 'Check result' step puts an expression straight into the run: script: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`.

Locations:

- `action.yml:156`

### github-env-injection (severity: high)

The 'Determine version' step sets VERSION from inputs.version (`VERSION="${{ inputs.version }}"`) and writes it with `echo "version=$VERSION" >> $GITHUB_OUTPUT`. Newlines are not stripped first (no printf '%s' | tr -d '\n\r'), so a crafted input could inject extra outputs.

Locations:

- `action.yml:65`

### unpinned-uses (severity: high)

A composite step references an action by tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:146`

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

All changes are in action.yml. Every input and step output now goes through step env: blocks. RUNNER_OS, RUNNER_ARCH and RUNNER_TEMP are read as environment variables. The scan command is built as a bash array, so each value stays quoted. The version value has newlines stripped before it is written to GITHUB_OUTPUT. The python finding counter now gets the SARIF path through sys.argv instead of having it pasted into the code. upload-sarif is pinned to commit 4bfa242aa49c5f7c6770b98670d354a7dfac05f8, with a '# v3' comment. Behaviour change: path, format and config are now passed as single values. Upstream left them unquoted, so a path with spaces used to split into several arguments.

