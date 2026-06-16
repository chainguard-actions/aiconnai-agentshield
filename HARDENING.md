<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **aiconnai--agentshield/v0.8.4** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ ... }} expressions are directly interpolated inside run: shell command strings across four composite action steps, violating rule (a). Attacker-controlled inputs (path, fail-on, format, config, ignore-tests, version) and workflow-controllable contexts (runner.os, runner.arch, runner.temp, steps.*.outputs.*) are substituted into shell commands before the shell parses them, enabling command injection. Affected expressions include: ${{ inputs.version }} (lines 53, 57), ${{ runner.os }}/${{ runner.arch }} (lines 63, 69), ${{ steps.version.outputs.version }} and ${{ steps.platform.outputs.target }} (lines 74-75), ${{ runner.temp }} (lines 80, 83, 86, 87), ${{ inputs.path }} (line 91), ${{ inputs.fail-on }} (lines 92, 130), ${{ inputs.format }} (lines 95, 99), ${{ runner.temp }} (line 96), ${{ inputs.config }} (lines 102-103), ${{ inputs.ignore-tests }} (line 106). All ${{ ... }} expressions must be moved to env: blocks and the resulting shell variables must be double-quoted in the run: script.

Locations:

- `action.yml:53`
- `action.yml:57`
- `action.yml:63`
- `action.yml:69`
- `action.yml:74`
- `action.yml:75`
- `action.yml:80`
- `action.yml:83`
- `action.yml:86`
- `action.yml:87`
- `action.yml:91`
- `action.yml:92`
- `action.yml:95`
- `action.yml:96`
- `action.yml:99`
- `action.yml:102`
- `action.yml:103`
- `action.yml:106`
- `action.yml:130`

### github-env-injection (severity: high)

Two unsanitized writes to GitHub special environment files: (1) Step 'Determine version' (line ~60): echo "version=$VERSION" >> $GITHUB_OUTPUT where VERSION is derived from ${{ inputs.version }} — an attacker-controlled input — without applying the required printf '%s' ... | tr -d '\n\r' sanitization before the write. A newline in the input value can inject arbitrary key=value pairs into GITHUB_OUTPUT. (2) Step 'Download AgentShield' (line ~87): echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH writes the workflow-controllable runner.temp context directly to GITHUB_PATH without sanitization. A newline embedded in runner.temp could inject additional paths.

Locations:

- `action.yml:60`
- `action.yml:87`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses github/codeql-action/upload-sarif@v3 — a mutable tag reference rather than a pinned 40-character commit SHA. If the v3 tag is moved or the repository is compromised, the action will silently execute different code. Pin to a full SHA, e.g. github/codeql-action/upload-sarif@<40-char-sha> # v3.

Locations:

- `action.yml:122`

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

Rewrote action.yml with the following fixes:
1. script-injection / static-inline-injection: Moved all ${{ }} expressions from run: blocks into env: blocks for all five steps (Determine version, Determine platform, Download AgentShield, Run scan, Check result). All resulting shell variables are double-quoted in the run scripts.
2. github-env-injection: Added printf '%s' ... | tr -d '\n\r' sanitization before writing to $GITHUB_OUTPUT (version value in 'Determine version' step) and $GITHUB_PATH (runner.temp path in 'Download AgentShield' step).
3. unpinned-uses: Pinned github/codeql-action/upload-sarif from @v3 to @dd903d2e4f5405488e5ef1422510ee31c8b32357 # v3.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run scan' step of action.yml by replacing the string-based ARGS accumulation with a bash array. Each user-controlled input (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG) is now properly double-quoted when added to the array, and the array is expanded with "${ARGS[@]}" when invoking agentshield. This prevents word-splitting and glob expansion of attacker-controlled values while keeping each argument as a separate, properly-quoted shell word.

