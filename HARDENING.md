<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 16 finding(s) were identified and resolved across 4 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ }}` expressions are directly interpolated inside `run:` shell command strings throughout action.yml (sub-rule a). This allows script injection if any of these values contain shell metacharacters. Affected expressions and steps:

**Determine version step** (lines ~58, 68):
- `if [ "${{ inputs.version }}" = "latest" ]; then`
- `VERSION="${{ inputs.version }}"`

**Determine platform step** (lines ~81, 87):
- `case "${{ runner.os }}-${{ runner.arch }}" in`
- `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"`

**Download AgentShield step** (lines ~93–106):
- `VERSION="${{ steps.version.outputs.version }}"`
- `TARGET="${{ steps.platform.outputs.target }}"`
- `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`
- `mkdir -p ${{ runner.temp }}/agentshield`
- `chmod +x ${{ runner.temp }}/agentshield/agentshield*`
- `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`

**Use provided AgentShield step** (line ~113):
- `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`

**Run scan step** (lines ~123–142):
- `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`
- `ARGS="scan ${{ inputs.path }}"`
- `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`
- `if [ "${{ inputs.format }}" = "sarif" ]; then`
- `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`
- `ARGS="$ARGS --format ${{ inputs.format }}"`
- `if [ -n "${{ inputs.config }}" ]; then`
- `ARGS="$ARGS --config ${{ inputs.config }}"`
- `if [ -n "${{ inputs.baseline }}" ]; then`
- `ARGS="$ARGS --baseline ${{ inputs.baseline }}"`
- `if [ "${{ inputs.ignore-tests }}" = "true" ]; then`

**Check result step** (lines ~174, 176, 179):
- `echo "::error::AgentShield found findings above the '${{ inputs.fail-on }}' threshold"`
- `if [ "${{ steps.scan.outputs.no_adapter }}" = "true" ] && [ "${{ inputs.strict }}" = "false" ]; then`
- `elif [ "${{ steps.scan.outputs.no_adapter }}" = "true" ]; then`

All `inputs.*` values are attacker-controllable. All `${{ ... }}` expressions in `run:` blocks should be moved to `env:` variables and then referenced as quoted shell variables.

Locations:

- `action.yml:58`
- `action.yml:68`
- `action.yml:81`
- `action.yml:87`
- `action.yml:93`
- `action.yml:94`
- `action.yml:99`
- `action.yml:102`
- `action.yml:105`
- `action.yml:106`
- `action.yml:113`
- `action.yml:123`
- `action.yml:124`
- `action.yml:125`
- `action.yml:127`
- `action.yml:128`
- `action.yml:131`
- `action.yml:134`
- `action.yml:135`
- `action.yml:138`
- `action.yml:139`
- `action.yml:142`
- `action.yml:174`
- `action.yml:176`
- `action.yml:179`

### github-env-injection (severity: high)

In the 'Determine version' step, the `VERSION` variable is derived directly from `${{ inputs.version }}` (an attacker-controllable input) and written to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' "$VERSION" | tr -d '\n\r'`). A malicious version string containing newlines could inject arbitrary key=value pairs into the GitHub output environment, potentially overwriting subsequent step outputs or environment variables.

Offending write (line ~79):
```
echo "version=$VERSION" >> $GITHUB_OUTPUT
```
where `VERSION` was set from `${{ inputs.version }}` without sanitization.

Locations:

- `action.yml:79`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v4`, which is pinned to a mutable tag (`@v4`) rather than an immutable full-length 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Offending line:
```yaml
uses: github/codeql-action/upload-sarif@v4
```

Fix: pin to a specific commit SHA, e.g.:
```yaml
uses: github/codeql-action/upload-sarif@65c74964a9ed8c44ed9f19d4bbc5757a6a8af9a4 # v4
```

Locations:

- `action.yml:168`

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

Fixed all security findings in hardened/action/action.yml:

1. **script-injection / static-inline-injection**: Moved all `${{ }}` expressions out of `run:` blocks into `env:` blocks for every step:
   - 'Determine version': `INPUT_VERSION: ${{ inputs.version }}`
   - 'Determine platform': `RUNNER_OS_INPUT: ${{ runner.os }}`, `RUNNER_ARCH_INPUT: ${{ runner.arch }}`
   - 'Download AgentShield': `STEP_VERSION`, `STEP_TARGET`, `RUNNER_TEMP_DIR`
   - 'Use provided AgentShield': added `RUNNER_TEMP_DIR: ${{ runner.temp }}`
   - 'Run scan': `INPUT_PATH`, `INPUT_FAIL_ON`, `INPUT_FORMAT`, `INPUT_CONFIG`, `INPUT_BASELINE`, `INPUT_IGNORE_TESTS`, `RUNNER_TEMP_DIR`
   - 'Check result': `INPUT_FAIL_ON`, `INPUT_STRICT`, `SCAN_NO_ADAPTER`

2. **github-env-injection**: Added sanitization of VERSION before writing to GITHUB_OUTPUT: `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` then `echo "version=$safe_version" >> "$GITHUB_OUTPUT"`

3. **unpinned-uses**: Pinned `github/codeql-action/upload-sarif@v4` to full commit SHA `ff2f1c621b7f889edc0d3c761ac2e6a3f8cdb0dd` with `# v4` comment for readability.

### Iteration 2

**Fixes applied:** script-injection, missing-permissions, unpinned-uses

**Notes:**

Fixed all 20 findings across 11 files:

1. action.yml: Fixed script injection in 'Run scan' step by converting ARGS string concatenation to a bash array (ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON" ...)) and using "${ARGS[@]}" for safe expansion.

2. feature-matrix.yml: Added permissions: contents: read; pinned actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2 to full SHAs; fixed script injection by moving ${{ matrix.command }} to env var and using xargs tokenization.

3. action-e2e.yml: Pinned actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, github/codeql-action/upload-sarif@v4 to full SHAs; fixed script injection by moving all ${{ runner.temp }} and step output expressions into env: blocks.

4. docker.yml: Pinned 7 docker/actions refs to full SHAs; fixed script injection by moving ${{ steps.build.outputs.digest }} and ${{ needs.metadata.outputs.json }} into env: blocks.

5. release.yml: Pinned 6 action refs to full SHAs; fixed script injection by moving ${{ matrix.target }} and ${{ github.ref_name }} into env: blocks for all affected steps (unix, windows, smoke check).

6. gitleaks.yml: Pinned actions/checkout@v6 and github/codeql-action/upload-sarif@v4 to full SHAs; fixed script injection by moving ${{ github.workspace }} into env: block.

7. semgrep.yml: Pinned actions/checkout@v6 and github/codeql-action/upload-sarif@v4 to full SHAs; fixed script injection by moving ${{ github.workspace }} into env: block.

8. ci.yml: Added top-level permissions: contents: read; pinned 5 action refs to full SHAs.

9. agentshield.yml: Pinned actions/checkout@v6 and aiconnai/agentshield@v0.8.7 to full SHAs.

10. codeql.yml: Pinned actions/checkout@v6, github/codeql-action/init@v3, github/codeql-action/analyze@v3 to full SHAs.

11. vscode.yml: Added top-level permissions: contents: read; pinned actions/checkout@v6 and actions/setup-node@v6 to full SHAs.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. 'Download AgentShield' step (line 133): Added sanitization before writing to $GITHUB_PATH — `safe_path=$(printf '%s' "$RUNNER_TEMP_DIR/agentshield" | tr -d '\n\r')` then `echo "$safe_path" >> "$GITHUB_PATH"`.
2. 'Use provided AgentShield' step (line 152): Added sanitization before writing to $GITHUB_PATH — `safe_path=$(printf '%s' "$(dirname "$AGENTSHIELD_DEST")" | tr -d '\n\r')` then `echo "$safe_path" >> "$GITHUB_PATH"`. Both fixes strip newline and carriage-return characters to prevent injection of additional entries into $GITHUB_PATH.

### Iteration 4

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed three security findings across two workflow files:

1. release.yml - script-injection (line 103): Quoted $BINARY inside command substitutions, changing `$(dirname $BINARY)` and `$(basename $BINARY)` to `$(dirname "$BINARY")` and `$(basename "$BINARY")` to prevent shell metacharacter injection from matrix.target values.

2. release.yml - github-env-injection (line 105): Added newline sanitization before writing ARCHIVE to GITHUB_ENV. Now uses `safe_archive=$(printf '%s' "$ARCHIVE" | tr -d '\n\r')` and writes `$safe_archive` instead of `$ARCHIVE`. Also quoted `$GITHUB_ENV` in the redirection.

3. docker.yml - script-injection (line 144): Replaced the unquoted `$tags` variable (built via xargs) with a properly constructed bash array. Each tag from jq output is read line-by-line into `tag_args` as separate `-t "$tag"` pairs, then expanded as `"${tag_args[@]}"` to prevent word splitting and glob expansion on attacker-influenced metadata content.

