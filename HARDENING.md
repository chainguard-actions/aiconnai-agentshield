<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.3** was hardened automatically. 21 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Determine version' step puts ${{ inputs.version }} straight into the run script, at line 70 ('if [ "${{ inputs.version }}" = "latest" ]') and line 81 ('VERSION="${{ inputs.version }}"'). Pass the value through an env: variable and quote it when the script uses it.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

Rule (a): the 'Determine platform' step puts ${{ runner.os }} and ${{ runner.arch }} straight into the run script: 'case "${{ runner.os }}-${{ runner.arch }}" in' at line 100 and the error echo at line 106. Use "$RUNNER_OS" and "$RUNNER_ARCH" instead.

Locations:

- `action.yml:100`
- `action.yml:106`

### script-injection (severity: high)

Rule (a): the 'Download AgentShield' step puts expressions straight into the run script: 'VERSION="${{ steps.version.outputs.version }}"', 'TARGET="${{ steps.platform.outputs.target }}"', and unquoted ${{ runner.temp }} in the unzip, mkdir, tar, chmod and echo lines. Rule (b): the step also uses ${{ runner.temp }} unquoted in shell commands.

Locations:

- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:125`
- `action.yml:130`

### script-injection (severity: high)

Rule (a): the 'Use provided AgentShield' step puts an expression straight into the run script: 'AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"'. Use "$RUNNER_TEMP" instead.

Locations:

- `action.yml:142`

### script-injection (severity: high)

Rule (a): the 'Run scan' step puts several inputs straight into the run script: 'ARGS="scan ${{ inputs.path }}"', '--fail-on ${{ inputs.fail-on }}', '${{ inputs.format }}', '${{ inputs.config }}', '${{ inputs.baseline }}', '${{ inputs.ignore-tests }}' and '${{ runner.temp }}'. Rule (b): it then runs 'agentshield $ARGS' with $ARGS unquoted, and $ARGS is built from those inputs. This is a plain command, not an array assignment, so the exemption does not apply.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:167`
- `action.yml:171`
- `action.yml:179`

### script-injection (severity: high)

Rule (a): the 'Check result' step puts expressions straight into the run script: "echo \"::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold\"", plus '${{ steps.scan.outputs.no_adapter }}' and '${{ inputs.strict }}' in the test conditions.

Locations:

- `action.yml:247`

### github-env-injection (severity: high)

The 'Determine version' step writes VERSION to $GITHUB_OUTPUT ('echo "version=$VERSION" >> $GITHUB_OUTPUT'). VERSION comes from inputs.version or from the GitHub API response. There is no printf '%s' | tr -d '\n\r' step before the write, so a value containing a newline can add extra outputs.

Locations:

- `action.yml:93`

### unpinned-uses (severity: high)

action.yml references an action by tag instead of a full commit SHA: 'uses: github/codeql-action/upload-sarif@v4'.

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

I moved every ${{ }} expression in the run: scripts of action.yml into step env: blocks: the version, path, fail-on, format, config, baseline, ignore-tests and strict inputs, plus the step outputs. The scripts now use the runner's own $RUNNER_OS, $RUNNER_ARCH and $RUNNER_TEMP variables, double-quoted, instead of the runner.* expressions. The scan command is now built as a bash array and run as "${ARGS[@]}", with each value quoted. The SARIF finding count now passes the file path to python3 as an argument instead of pasting it into the Python code. Newlines are stripped from VERSION before it is written to GITHUB_OUTPUT. I pinned github/codeql-action/upload-sarif to 1bd86f2fdb4b86187fa4059f16f31a3202acc9ea (v4). Nothing was run to test these changes. One behaviour change: upstream split the scan arguments on whitespace, so a path, config or baseline value containing spaces now reaches agentshield as one argument instead of several.

