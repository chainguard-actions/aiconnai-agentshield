<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 16 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings in action.yml, violating rule (a). This allows an attacker who controls the inputs to inject arbitrary shell commands.

Affected steps and expressions:
- 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`
- 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo `${{ runner.os }}-${{ runner.arch }}`
- 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`
- 'Run scan' step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format sarif --output $SARIF_FILE"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `if [ -n "${{ inputs.baseline }}" ]`, `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`, `if [ "${{ inputs.ignore-tests }}" = "true" ]`
- 'Check result' step: `'${{ inputs.fail-on }}'`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}`

All these should be moved to env: blocks and referenced as shell variables with proper quoting.

Locations:

- `action.yml:57`
- `action.yml:63`
- `action.yml:78`
- `action.yml:88`
- `action.yml:100`
- `action.yml:107`
- `action.yml:130`
- `action.yml:145`
- `action.yml:148`
- `action.yml:152`
- `action.yml:155`
- `action.yml:159`
- `action.yml:163`
- `action.yml:167`
- `action.yml:171`
- `action.yml:175`
- `action.yml:214`
- `action.yml:220`
- `action.yml:224`

### github-env-injection (severity: high)

Two unsanitized writes to GitHub special environment files:

1. In the 'Determine version' step: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — $VERSION is set directly from `${{ inputs.version }}` which is interpolated into the shell script without sanitization. An attacker can inject newlines into `inputs.version` to poison GITHUB_OUTPUT.

2. In the 'Download AgentShield' step: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — `${{ runner.temp }}` is directly interpolated into the run block and written to $GITHUB_PATH without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

Neither write is preceded by the required sanitization pipeline.

Locations:

- `action.yml:75`
- `action.yml:115`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v4`, which is a mutable tag reference. If the tag is moved (e.g., by a supply-chain compromise), the action will execute arbitrary code. It must be pinned to a full 40-character commit SHA, e.g. `github/codeql-action/upload-sarif@<sha> # v4`.

Locations:

- `action.yml:209`

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

Fixed all findings in action.yml:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: shell blocks to env: blocks in every affected step (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Converted ARGS string concatenation to a bash array for proper argument boundary handling.

2. github-env-injection: Added sanitization pipelines before writing to $GITHUB_OUTPUT and $GITHUB_PATH: 'safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')' in Determine version step, and 'safe_path=$(printf '%s' "$RUNNER_TEMP_DIR/agentshield" | tr -d '\n\r')' in Download AgentShield step.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full commit SHA ff2f1c621b7f889edc0d3c761ac2e6a3f8cdb0dd with # v4 comment for readability.

