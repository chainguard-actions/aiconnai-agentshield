<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.5** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings, violating rule (a). This allows an attacker (or any caller of this composite action) to inject arbitrary shell commands via the substituted values before the shell ever parses them.

Affected steps and offending lines:

**"Determine version" step:**
- `if [ "${{ inputs.version }}" = "latest" ]; then` — inputs.version interpolated directly
- `VERSION="${{ inputs.version }}"` — inputs.version interpolated directly

**"Determine platform" step:**
- `case "${{ runner.os }}-${{ runner.arch }}" in` — runner context interpolated directly
- `*) echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"; exit 1 ;;` — runner context interpolated directly

**"Download AgentShield" step:**
- `VERSION="${{ steps.version.outputs.version }}"` — step output interpolated directly
- `TARGET="${{ steps.platform.outputs.target }}"` — step output interpolated directly
- `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield` — runner.temp interpolated directly
- `mkdir -p ${{ runner.temp }}/agentshield` — runner.temp interpolated directly
- `tar xzf agentshield.tar.gz -C ${{ runner.temp }}/agentshield` — runner.temp interpolated directly
- `chmod +x ${{ runner.temp }}/agentshield/agentshield*` — runner.temp interpolated directly
- `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — runner.temp interpolated directly

**"Run scan" step:**
- `ARGS="scan ${{ inputs.path }}"` — inputs.path interpolated directly
- `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"` — inputs.fail-on interpolated directly
- `if [ "${{ inputs.format }}" = "sarif" ]; then` — inputs.format interpolated directly
- `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"` — runner.temp interpolated directly
- `ARGS="$ARGS --format ${{ inputs.format }}"` — inputs.format interpolated directly
- `if [ -n "${{ inputs.config }}" ]; then` — inputs.config interpolated directly
- `ARGS="$ARGS --config ${{ inputs.config }}"` — inputs.config interpolated directly
- `if [ "${{ inputs.ignore-tests }}" = "true" ]; then` — inputs.ignore-tests interpolated directly

**"Check result" step:**
- `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"` — inputs.fail-on interpolated directly

All `inputs.*` values should be passed via `env:` variables and referenced as `"$VAR"` in the shell. `runner.*` and `steps.*.outputs.*` values should similarly be moved to env vars.

Locations:

- `action.yml:57`
- `action.yml:63`
- `action.yml:74`
- `action.yml:79`
- `action.yml:87`
- `action.yml:88`
- `action.yml:93`
- `action.yml:96`
- `action.yml:97`
- `action.yml:100`
- `action.yml:101`
- `action.yml:108`
- `action.yml:109`
- `action.yml:112`
- `action.yml:113`
- `action.yml:116`
- `action.yml:119`
- `action.yml:120`
- `action.yml:123`
- `action.yml:152`

### github-env-injection (severity: high)

Multiple `run:` steps write values derived from untrusted inputs to `$GITHUB_OUTPUT`, `$GITHUB_PATH`, and `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. **"Determine version" step**: `echo "version=$VERSION" >> $GITHUB_OUTPUT` — `$VERSION` is set from `${{ inputs.version }}` (attacker-controlled) without newline sanitization. A newline in `inputs.version` can inject additional key=value pairs into GITHUB_OUTPUT.

2. **"Determine platform" step**: `echo "target=$TARGET" >> $GITHUB_OUTPUT` — `$TARGET` is derived from `${{ runner.os }}-${{ runner.arch }}` without sanitization.

3. **"Download AgentShield" step**: `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — `runner.temp` is interpolated directly and written to GITHUB_PATH without sanitization. A newline in the value would inject an additional path entry.

4. **"Run scan" step**: `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` — `$SARIF_FILE` is derived from `${{ runner.temp }}` (and `${{ inputs.format }}`) without sanitization. Also `echo "AGENTSHIELD_EXIT=$EXIT_CODE" >> $GITHUB_ENV` — while EXIT_CODE is locally computed and safe, the pattern of unsanitized writes to GITHUB_ENV is present in this step.

Locations:

- `action.yml:65`
- `action.yml:81`
- `action.yml:101`
- `action.yml:131`
- `action.yml:140`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. If the tag is moved (e.g. by a supply-chain compromise of the upstream repository), the action will silently execute different code. Fix: pin to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:143`

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, static-inline-injection

**Notes:**

Fixed all findings in hardened/action/action.yml:

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions out of run: blocks and into env: blocks for each step. Shell scripts now reference plain environment variables ($INPUT_VERSION, $RUNNER_OS, $RUNNER_ARCH, $STEP_VERSION, $STEP_TARGET, $RUNNER_TEMP, $INPUT_PATH, $INPUT_FAIL_ON, $INPUT_FORMAT, $INPUT_CONFIG, $INPUT_IGNORE_TESTS).

2. github-env-injection: Added sanitization (printf '%s' "$VAR" | tr -d '\n\r') before writing values to $GITHUB_OUTPUT and $GITHUB_PATH in the 'Determine version', 'Determine platform', 'Download AgentShield', and 'Run scan' steps. EXIT_CODE is a locally computed integer and is safe as-is.

3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v3 to the full commit SHA ce5e7eeac396d720fe2d802714996c8ce561e311 with a # v3 comment for readability.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the 'Run scan' step in action.yml by converting the ARGS string variable to a bash array. Changed:
- ARGS="scan $INPUT_PATH" → ARGS=(scan "$INPUT_PATH")
- ARGS="$ARGS --fail-on $INPUT_FAIL_ON" → ARGS+=("--fail-on" "$INPUT_FAIL_ON")
- ARGS="$ARGS --format sarif --output $SARIF_FILE" → ARGS+=("--format" "sarif" "--output" "$SARIF_FILE")
- ARGS="$ARGS --format $INPUT_FORMAT" → ARGS+=("--format" "$INPUT_FORMAT")
- ARGS="$ARGS --config $INPUT_CONFIG" → ARGS+=("--config" "$INPUT_CONFIG")
- ARGS="$ARGS --ignore-tests" → ARGS+=("--ignore-tests")
- agentshield $ARGS → agentshield "${ARGS[@]}"

This ensures each input value is treated as a single argument regardless of shell metacharacters or whitespace, preventing injection attacks via attacker-controlled inputs.

