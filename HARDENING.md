<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 21 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Composite step 'Upload SARIF to GitHub Code Scanning' uses a tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v4`.

Locations:

- `action.yml:237`

### script-injection (severity: high)

(a) Step 'Determine version' puts the input straight into the shell script: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

(a) Step 'Determine platform' puts runner context expressions straight into the shell script: `case "${{ runner.os }}-${{ runner.arch }}" in`.

Locations:

- `action.yml:100`

### script-injection (severity: high)

(a) Step 'Download AgentShield' puts step outputs and runner.temp straight into the shell script: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, and unquoted `${{ runner.temp }}` in the unzip, mkdir, tar, chmod and echo commands.

Locations:

- `action.yml:114`

### script-injection (severity: high)

(a) Step 'Use provided AgentShield' puts an expression straight into the shell script: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

Locations:

- `action.yml:142`

### script-injection (severity: high)

(a) Step 'Run scan' puts several inputs straight into the shell script: `ARGS="scan ${{ inputs.path }}"`, `--fail-on ${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ inputs.config }}`, `${{ inputs.baseline }}`, `${{ inputs.ignore-tests }}`, `${{ runner.temp }}`. (b) It then expands the input-derived ARGS without quotes: `agentshield $ARGS 2>&1 | tee "$SCAN_LOG"`.

Locations:

- `action.yml:155`
- `action.yml:179`

### script-injection (severity: high)

(a) Step 'Check result' puts expressions straight into the shell script: `${{ inputs.fail-on }}`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}`.

Locations:

- `action.yml:247`

### github-env-injection (severity: high)

Step 'Determine version' writes VERSION to GITHUB_OUTPUT without the `printf '%s' ... | tr -d '\n\r'` sanitization: `echo "version=$VERSION" >> $GITHUB_OUTPUT`. VERSION comes from `${{ inputs.version }}`, so a value containing a newline can inject extra outputs.

Locations:

- `action.yml:93`

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

**Fixes applied:** unpinned-uses, script-injection, github-env-injection, static-inline-injection

**Notes:**

All changes are in action.yml. Nothing was run or tested.

- **Pinned action:** I pinned github/codeql-action/upload-sarif to commit 9b3254085494b55a0f7c4c2b3d2d52cc712ce370 (v4), using the SHA returned by the lookup tool.
- **Expressions moved out of shell code:** every ${{ }} expression in a run: block now goes into that step's env: block. This covers inputs.version, path, fail-on, format, config, baseline, ignore-tests and strict, plus runner.os, runner.arch, runner.temp, the step outputs and the no_adapter output. The scripts now read them as quoted shell variables.
- **Scan command:** the scan arguments are now built as a bash array and expanded quoted, instead of as one string expanded unquoted.
- **Behaviour change:** a `path`, `config` or `baseline` value with spaces now reaches agentshield as one argument instead of being split into several. Upstream split them, but all three are documented as single paths.
- **Newline stripping:** newlines are removed before the version and sarif-file values are written to GITHUB_OUTPUT, and before the install directory is written to GITHUB_PATH. All `>> $GITHUB_*` targets are now quoted.
- **Extra change:** the inline python3 call that counts findings now gets the SARIF file path as an argument. Before, the path was pasted into the Python code inside quotes.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

action.yml:159 now reads DEST_DIR="$(dirname "$AGENTSHIELD_DEST")" || true, preserving upstream's non-aborting behaviour while still sanitizing the value written to GITHUB_PATH.

