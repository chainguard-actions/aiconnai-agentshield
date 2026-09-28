<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.5** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ }}` expressions are interpolated directly inside `run:` shell command strings (sub-rule a). This allows an attacker who controls input values to inject arbitrary shell commands.

'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`

'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` and the error echo line.

'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`.

'Check result' step: `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`.

All inputs should be mapped to env vars and the env vars used in the shell script instead.

Locations:

- `action.yml:53`
- `action.yml:58`
- `action.yml:68`
- `action.yml:74`
- `action.yml:81`
- `action.yml:82`
- `action.yml:87`
- `action.yml:90`
- `action.yml:91`
- `action.yml:94`
- `action.yml:95`
- `action.yml:102`
- `action.yml:103`
- `action.yml:106`
- `action.yml:107`
- `action.yml:110`
- `action.yml:113`
- `action.yml:114`
- `action.yml:117`
- `action.yml:151`

### github-env-injection (severity: high)

Untrusted input values are written to GitHub special environment files without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

(1) 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` where `$VERSION` is derived from `${{ inputs.version }}` (user-controlled) without sanitization.

(2) 'Determine platform' step: `echo "target=$TARGET" >> $GITHUB_OUTPUT` where `$TARGET` is derived from `${{ runner.os }}-${{ runner.arch }}` without sanitization.

(3) 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — direct write of a `${{ runner.temp }}` expression to `$GITHUB_PATH` without sanitization.

(4) 'Run scan' step: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` where `$SARIF_FILE` contains `${{ runner.temp }}` without sanitization.

An attacker who can influence these values could inject newlines to set arbitrary environment variables or path entries.

Locations:

- `action.yml:60`
- `action.yml:75`
- `action.yml:95`
- `action.yml:131`

### unpinned-uses (severity: high)

The composite action uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. This means the action could be silently updated to a malicious version without any change to this file. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:141`

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

Fixed all findings in action.yml:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions out of run: shell strings into env: blocks for each step. 'Determine version' uses INPUT_VERSION; 'Determine platform' uses RUNNER_OS and RUNNER_ARCH; 'Download AgentShield' uses VERSION, TARGET, and RUNNER_TEMP; 'Run scan' uses INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_IGNORE_TESTS, and RUNNER_TEMP; 'Check result' uses INPUT_FAIL_ON.

2. github-env-injection: All values written to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH are now sanitized with `printf '%s' "$VAR" | tr -d '\n\r'` before writing. Specifically: version output, target output, GITHUB_PATH entry, sarif-file output, and AGENTSHIELD_EXIT env var.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v3 to its full commit SHA: github/codeql-action/upload-sarif@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Replaced the string-based ARGS construction (where input values were concatenated without quoting and then expanded unquoted) with a bash array. Each input value ($INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG) is now double-quoted when appended to the ARGS array, and the command is executed with `agentshield "${ARGS[@]}"` which preserves proper argument boundaries and prevents shell metacharacter interpretation.

