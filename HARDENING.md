<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.9.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.9.3** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ ... }} expressions are directly interpolated inside run: shell command strings across several steps in action.yml, violating sub-rule (a). This allows an attacker-controlled value to be injected into the shell before quoting can protect it.

1. 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is directly interpolated.
2. 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` and `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"` — runner.* expressions directly in run block.
3. 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `${{ runner.temp }}/agentshield` (multiple occurrences) — all directly interpolated.
4. 'Run scan' step: `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `${{ inputs.format }}`, `${{ inputs.config }}`, `${{ inputs.baseline }}`, `${{ inputs.ignore-tests }}`, `${{ runner.temp }}` — all directly interpolated into shell commands.
5. 'Check result' step: `'${{ inputs.fail-on }}'`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}` — directly interpolated.

All of these should be moved to env: blocks and referenced as quoted shell variables (e.g., "$INPUT_VERSION").

Locations:

- `action.yml:68`
- `action.yml:81`
- `action.yml:92`
- `action.yml:100`
- `action.yml:103`
- `action.yml:104`
- `action.yml:113`
- `action.yml:116`
- `action.yml:119`
- `action.yml:121`
- `action.yml:131`
- `action.yml:132`
- `action.yml:135`
- `action.yml:138`
- `action.yml:142`
- `action.yml:146`
- `action.yml:150`
- `action.yml:200`
- `action.yml:203`
- `action.yml:205`

### github-env-injection (severity: high)

In the 'Download AgentShield' step, the value `${{ runner.temp }}/agentshield` is written directly to $GITHUB_PATH without sanitization: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`. Although runner.temp is GitHub-controlled, any ${{ ... }} expression interpolated directly into a run: block and then written to a special environment file is a violation — the sanitization step (`printf '%s' ... | tr -d '\n\r'`) is required before every write. The safe pattern would be to assign to an env var and sanitize before writing.

Locations:

- `action.yml:121`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v4`, which is a mutable tag reference rather than a pinned full 40-character commit SHA. This means the action could be silently updated to a different (potentially malicious) version without any change to this file. It should be pinned to a specific commit SHA, e.g., `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:193`

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

Fixed all security findings in hardened/action/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions out of run: shell blocks and into env: blocks for each affected step (Determine version, Determine platform, Download AgentShield, Use provided AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS, $RUNNER_ARCH, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_BASELINE, $INPUT_IGNORE_TESTS, $INPUT_STRICT, $STEP_NO_ADAPTER).

2. github-env-injection: In the 'Download AgentShield' step, the path written to $GITHUB_PATH is now sanitized with `safe_path=$(printf '%s' "$RUNNER_TEMP/agentshield" | tr -d '\n\r')` before writing to prevent newline injection.

3. unpinned-uses: Pinned `github/codeql-action/upload-sarif@v4` to the full commit SHA `ff2f1c621b7f889edc0d3c761ac2e6a3f8cdb0dd` with a `# v4` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Fixed two high-severity findings in hardened/action/action.yml:
1. github-env-injection (line 100): Added sanitization of the VERSION variable before writing to GITHUB_OUTPUT. Now uses `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` and writes `$safe_version` instead of `$VERSION` directly.
2. script-injection (lines 163-183): Replaced the ARGS string variable with a bash array. All user-controlled inputs (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) are now properly double-quoted when appended to the array, and the array is expanded safely with `"${ARGS[@]}"` when invoking agentshield.

