<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.1** was hardened automatically. 22 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Determine version' step directly interpolates `${{ inputs.version }}` inside the run: shell script on two lines. This allows an attacker-controlled value to be injected into the shell command before the shell ever parses it. Offending lines: `if [ "${{ inputs.version }}" = "latest" ]; then` and `VERSION="${{ inputs.version }}"`

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

Sub-rule (a): The 'Determine platform' step directly interpolates `${{ runner.os }}` and `${{ runner.arch }}` inside the run: shell script. Any ${{ }} expression in a run: block is a script-injection risk. Offending lines: `case "${{ runner.os }}-${{ runner.arch }}" in` and the error echo line.

Locations:

- `action.yml:100`
- `action.yml:106`

### script-injection (severity: high)

Sub-rule (a): The 'Download AgentShield' step directly interpolates `${{ steps.version.outputs.version }}`, `${{ steps.platform.outputs.target }}`, and `${{ runner.temp }}` (multiple occurrences) inside the run: shell script. Offending lines include: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, and `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

Locations:

- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:125`
- `action.yml:126`
- `action.yml:129`
- `action.yml:130`

### script-injection (severity: high)

Sub-rule (a): The 'Use provided AgentShield' step directly interpolates `${{ runner.temp }}` inside the run: shell script. Offending line: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

Locations:

- `action.yml:142`

### script-injection (severity: high)

Sub-rule (a): The 'Run scan' step directly interpolates multiple ${{ }} expressions inside the run: shell script: `${{ runner.temp }}`, `${{ inputs.path }}`, `${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ inputs.config }}`, `${{ inputs.baseline }}`, and `${{ inputs.ignore-tests }}`. Attacker-controlled inputs (path, fail-on, format, config, baseline, ignore-tests) are injected directly into shell command strings, enabling command injection.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:160`
- `action.yml:161`
- `action.yml:164`
- `action.yml:167`
- `action.yml:170`
- `action.yml:174`

### script-injection (severity: high)

Sub-rule (a): The 'Check result' step directly interpolates `${{ inputs.fail-on }}`, `${{ steps.scan.outputs.no_adapter }}`, and `${{ inputs.strict }}` inside the run: shell script. Offending lines include the echo and conditional expressions using these values.

Locations:

- `action.yml:200`
- `action.yml:202`
- `action.yml:204`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `${{ runner.temp }}/agentshield` directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. The value is derived from a ${{ }} expression and is not passed through `printf '%s' ... | tr -d '\n\r'` before the write.

Locations:

- `action.yml:130`

### github-env-injection (severity: high)

The 'Use provided AgentShield' step writes a path derived from `${{ runner.temp }}` to $GITHUB_PATH without sanitization: `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH`, where AGENTSHIELD_DEST was set from `${{ runner.temp }}/agentshield/agentshield`. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write.

Locations:

- `action.yml:148`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4`, which is pinned to a mutable tag (`@v4`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:195`

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

Fixed all security findings in action.yml:
1. script-injection: Moved all ${{ }} expressions from run: blocks into env: blocks for all 6 affected steps (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain $VAR_NAME environment variables.
2. github-env-injection: Both GITHUB_PATH writes now sanitize values via `printf '%s' "$VAR" | tr -d '\n\r'` before writing.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to full SHA @24c54180a607b1449ed407dd24f251e4e9147c8d # v4.
4. static-inline-injection: All instances resolved as part of the script-injection fixes.
The inputs.path value (which may be a list of paths) is tokenized safely using the xargs/while-read-NUL pattern into a bash array.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Determine version' step of action.yml. Added sanitization using `safe=$(printf '%s' "$VERSION" | tr -d '\n\r')` before writing to $GITHUB_OUTPUT, and changed the write to use `$safe` instead of the raw `$VERSION`. This prevents a caller from injecting arbitrary key=value pairs into GITHUB_OUTPUT by supplying a newline-containing version string. Also properly quoted `"$GITHUB_OUTPUT"` in the echo statement.

