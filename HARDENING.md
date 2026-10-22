<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.0** was hardened automatically. 21 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Step 'Determine version' breaks rule (a): it puts expressions straight into the shell script. Offending lines: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`. A crafted version input can run commands.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

Step 'Determine platform' breaks rule (a): `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo `${{ runner.os }}-${{ runner.arch }}` put expressions straight into run:. Use $RUNNER_OS and $RUNNER_ARCH instead.

Locations:

- `action.yml:100`
- `action.yml:106`

### script-injection (severity: high)

Step 'Download AgentShield' breaks rule (a): `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, and unquoted `${{ runner.temp }}` are used in the unzip, mkdir, tar, chmod and GITHUB_PATH lines. The version output comes from the user-supplied version input.

Locations:

- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:130`

### script-injection (severity: high)

Step 'Use provided AgentShield' breaks rule (a): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` puts an expression straight into run:.

Locations:

- `action.yml:142`

### script-injection (severity: high)

Step 'Run scan' breaks rule (a): `ARGS="scan ${{ inputs.path }}"`, `--fail-on ${{ inputs.fail-on }}`, `[ "${{ inputs.format }}" = "sarif" ]`, `--format ${{ inputs.format }}`, `[ -n "${{ inputs.config }}" ]` / `--config ${{ inputs.config }}`, `--baseline ${{ inputs.baseline }}`, `${{ inputs.ignore-tests }}`, and `${{ runner.temp }}` all put expressions straight into the script. It also breaks rule (b): `agentshield $ARGS` expands input-derived data without quotes.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:159`
- `action.yml:166`
- `action.yml:170`
- `action.yml:174`
- `action.yml:179`

### script-injection (severity: high)

Step 'Check result' breaks rule (a): `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"` and `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]` put expressions straight into run:.

Locations:

- `action.yml:245`
- `action.yml:248`

### github-env-injection (severity: high)

Step 'Determine version' writes VERSION to $GITHUB_OUTPUT with `echo "version=$VERSION" >> $GITHUB_OUTPUT`. VERSION comes from inputs.version, or from the GitHub API response when the input is 'latest'. The value is not passed through `printf '%s' ... | tr -d '\n\r'` first, so a newline in it can inject extra outputs.

Locations:

- `action.yml:93`

### unpinned-uses (severity: high)

action.yml has a uses: reference that is not pinned to a commit SHA: `uses: github/codeql-action/upload-sarif@v4`. Pin it to a full 40-character commit SHA.

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, static-inline-injection

**Notes:**

Moved all ${{ }} expressions out of run: blocks into step env: (INPUT_VERSION, VERSION/TARGET, INPUT_PATH/FAIL_ON/FORMAT/CONFIG/BASELINE/IGNORE_TESTS, INPUT_FAIL_ON/INPUT_STRICT/NO_ADAPTER). Swapped runner.os/arch/temp for $RUNNER_OS/$RUNNER_ARCH/$RUNNER_TEMP, quoted. Replaced the string-built, unquoted 'agentshield $ARGS' with a bash array so each input stays one quoted argument (path, config and baseline are single values). Removed newlines from the version before writing it to GITHUB_OUTPUT. Pinned github/codeql-action/upload-sarif to 9b3254085494b55a0f7c4c2b3d2d52cc712ce370 (v4). The SARIF path now goes to the python3 count one-liner as argv instead of being placed inside the code string. Incremental edits garbled the file, so I rewrote it in full.

