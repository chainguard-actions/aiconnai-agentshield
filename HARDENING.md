<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.6** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ ... }}` expressions are directly interpolated inside `run:` shell command strings across four steps in action.yml.

**Step 'Determine version'** (line 57): `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` (line 62) — user-controlled input interpolated directly into shell.

**Step 'Determine platform'** (line 71): `case "${{ runner.os }}-${{ runner.arch }}"` and (line 76) `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"` — context expressions interpolated directly.

**Step 'Download AgentShield'** (lines 82–96): `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `${{ runner.temp }}/agentshield` (multiple occurrences) — step outputs and runner context interpolated directly.

**Step 'Run scan'** (lines 102–118): `ARGS="scan ${{ inputs.path }}"`, `${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ runner.temp }}`, `${{ inputs.config }}`, `${{ inputs.ignore-tests }}` — all user-controllable inputs interpolated directly into shell commands.

**Step 'Check result'** (line 143): `'${{ inputs.fail-on }}'` interpolated directly into an echo command.

All of these allow an attacker (via a calling workflow) to inject arbitrary shell commands by supplying crafted input values.

Locations:

- `action.yml:57`
- `action.yml:62`
- `action.yml:71`
- `action.yml:76`
- `action.yml:82`
- `action.yml:83`
- `action.yml:88`
- `action.yml:91`
- `action.yml:92`
- `action.yml:95`
- `action.yml:96`
- `action.yml:102`
- `action.yml:103`
- `action.yml:106`
- `action.yml:107`
- `action.yml:111`
- `action.yml:114`
- `action.yml:115`
- `action.yml:118`
- `action.yml:143`

### github-env-injection (severity: high)

Two steps write values derived from untrusted/workflow-controlled context expressions to GitHub special environment files without the required sanitization (`printf '%s' ... | tr -d '\n\r'`).

**Step 'Download AgentShield'** (line 96): `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — the `${{ runner.temp }}` expression is interpolated directly and written to `$GITHUB_PATH` without sanitization. A calling workflow can influence this value.

**Step 'Run scan'** (line 107): `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"` is set from a context expression, and then `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` (line ~124) writes it to `$GITHUB_OUTPUT` without sanitization.

Newline characters in these values could be used to inject additional environment variable assignments or PATH entries.

Locations:

- `action.yml:96`
- `action.yml:107`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which references a mutable tag (`@v3`) rather than a full 40-character immutable commit SHA. This means the action could be silently updated to a different (potentially malicious) version without any change to this file. It should be pinned to a specific commit SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:136`

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

Rewrote action.yml to fix all findings:
1. script-injection/static-inline-injection: Moved all ${{ }} expressions from run: shell strings into env: blocks for all five affected steps (Determine version, Determine platform, Download AgentShield, Run scan, Check result). Shell scripts now reference plain environment variables.
2. github-env-injection: Added sanitization with `printf '%s' "$VAR" | tr -d '\n\r'` before writing values to $GITHUB_PATH (in Download AgentShield) and $GITHUB_OUTPUT (in Determine version and Run scan).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif from @v3 to @1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml. Replaced the unquoted string-concatenation approach ($ARGS string variable) with a bash array (ARGS array). Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG) is now added as a separate double-quoted array element via ARGS+=("--flag" "$VALUE"), and the command is invoked as `agentshield "${ARGS[@]}"`. This prevents word-splitting and glob expansion of attacker-controlled values, eliminating the command injection vulnerability.

