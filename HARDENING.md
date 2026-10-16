<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings, violating sub-rule (a). This allows YAML template substitution to inject arbitrary shell metacharacters before the shell parses the command.

• 'Determine version' step (line 70): `if [ "${{ inputs.version }}" = "latest" ]; then` and (line 81): `VERSION="${{ inputs.version }}"`
• 'Determine platform' step (line 100): `case "${{ runner.os }}-${{ runner.arch }}" in` and (line 106): `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"; exit 1 ;;`
• 'Download AgentShield' step (line 114): `VERSION="${{ steps.version.outputs.version }}"`, (line 115): `TARGET="${{ steps.platform.outputs.target }}"`, (lines 121,125,126,129,130): multiple `${{ runner.temp }}` usages including the GITHUB_PATH write
• 'Use provided AgentShield' step (line 142): `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`
• 'Run scan' step (lines 154-174): `${{ runner.temp }}`, `${{ inputs.path }}`, `${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ inputs.config }}`, `${{ inputs.baseline }}`, `${{ inputs.ignore-tests }}` all interpolated directly into shell commands
• 'Check result' step: `${{ inputs.fail-on }}`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}` interpolated directly into shell commands

All inputs.* values are caller-controlled and can contain shell metacharacters. runner.* and steps.*.outputs.* are also workflow-controlled expressions that flow through YAML template substitution before the shell sees them.

Locations:

- `action.yml:70`
- `action.yml:81`
- `action.yml:100`
- `action.yml:106`
- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:125`
- `action.yml:126`
- `action.yml:129`
- `action.yml:130`
- `action.yml:142`
- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:159`
- `action.yml:160`
- `action.yml:163`
- `action.yml:166`
- `action.yml:167`
- `action.yml:170`
- `action.yml:171`
- `action.yml:174`

### github-env-injection (severity: high)

Several run: blocks write values derived from untrusted inputs to $GITHUB_OUTPUT or $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. 'Determine version' step (line 93): `echo "version=$VERSION" >> $GITHUB_OUTPUT` — VERSION is derived directly from `${{ inputs.version }}` (a caller-controlled input) without sanitization. A newline in the input could inject additional key=value pairs into GITHUB_OUTPUT.

2. 'Download AgentShield' step (line 130): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — a ${{ }} expression is written directly to $GITHUB_PATH without sanitization.

3. 'Use provided AgentShield' step (line 148): `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` — AGENTSHIELD_DEST is set to `${{ runner.temp }}/agentshield/agentshield` (a workflow-controlled expression) and its dirname is written to $GITHUB_PATH without sanitization.

4. 'Run scan' step (line 190): `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — SARIF_FILE is constructed from `${{ runner.temp }}` without sanitization before the write.

Locations:

- `action.yml:93`
- `action.yml:130`
- `action.yml:148`
- `action.yml:190`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `uses: github/codeql-action/upload-sarif@v4`. The ref `@v4` is a mutable tag, not a pinned 40-character commit SHA. A compromised or updated tag could silently execute different code. It should be pinned to a full SHA, e.g. `uses: github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:235`

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

Fixed all findings in hardened/action/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks into env: blocks for every affected step (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS_INPUT, $RUNNER_ARCH_INPUT, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP_DIR, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $SCAN_NO_ADAPTER, $INPUT_STRICT).

2. github-env-injection: Added sanitization (printf '%s' "$VAR" | tr -d '\n\r') before all writes to $GITHUB_OUTPUT and $GITHUB_PATH that use caller-controlled or workflow-controlled values: version output in 'Determine version', path in 'Download AgentShield', path in 'Use provided AgentShield', and sarif-file output in 'Run scan'.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to its full commit SHA: github/codeql-action/upload-sarif@6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee # v4

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml by replacing the unquoted string-based ARGS variable with a bash array. Changed: (1) ARGS="scan $INPUT_PATH" → ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON"), (2) all subsequent ARGS="$ARGS --flag $INPUT_VAR" string concatenations → ARGS+=(--flag "$INPUT_VAR") array appends with proper quoting, (3) agentshield $ARGS → agentshield "${ARGS[@]}" to expand the array safely. This ensures each input value is treated as a single argument regardless of shell metacharacters it may contain.

