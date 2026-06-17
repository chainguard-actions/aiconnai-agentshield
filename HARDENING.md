<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **aiconnai--agentshield/v0.8.3** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ ... }}` expressions are interpolated directly inside `run:` shell command strings (rule a), allowing script injection. Attacker-controllable inputs are embedded without going through env vars:

- 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`
- 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"`
- 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `${{ runner.temp }}` used in unzip/mkdir/chmod/echo lines
- 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ inputs.config }}`, `${{ inputs.ignore-tests }}`, `${{ runner.temp }}`
- 'Check result' step: `'${{ inputs.fail-on }}'` in error message

Any of the `inputs.*` values can be set by a calling workflow to inject shell metacharacters.

Locations:

- `action.yml:57`
- `action.yml:68`
- `action.yml:78`
- `action.yml:95`
- `action.yml:140`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `${{ runner.temp }}/agentshield` directly to `$GITHUB_PATH` without sanitization (`printf '%s' ... | tr -d '\n\r'`). Although `runner.temp` is GitHub-controlled, any `${{ ... }}` expression written to a special environment file without sanitization violates the check. Additionally, the 'Run scan' step constructs `$ARGS` by directly embedding `${{ inputs.path }}`, `${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ inputs.config }}`, and `${{ inputs.ignore-tests }}` — all caller-controlled values — without sanitization before use.

Locations:

- `action.yml:91`
- `action.yml:95`

### unpinned-uses (severity: high)

The composite action uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved. It should be pinned to a specific SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:130`

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

Fixed all security findings in action.yml:
1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions out of run: shell strings and into env: blocks for each affected step (Determine version, Determine platform, Download AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables.
2. github-env-injection: Sanitized the GITHUB_PATH write in 'Download AgentShield' using `printf '%s' "$RUNNER_TEMP_DIR/agentshield" | tr -d '\n\r'` before writing to $GITHUB_PATH.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif from mutable tag @v3 to full SHA @dd903d2e4f5405488e5ef1422510ee31c8b32357 # v3.
4. Also improved the 'Run scan' step to use a bash array (ARGS=()) for building command arguments, preventing flag/value packing issues and maintaining proper argument boundaries.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. 'Determine version' step (line 68): Sanitized VERSION before writing to GITHUB_OUTPUT using `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` and writing `$safe_version` instead.
2. 'Run scan' step (line 149): Sanitized SARIF_FILE before writing to GITHUB_OUTPUT using `safe_sarif=$(printf '%s' "$SARIF_FILE" | tr -d '\n\r')` and writing `$safe_sarif` instead.
Both changes prevent newline injection attacks via attacker-controllable inputs written to $GITHUB_OUTPUT.

