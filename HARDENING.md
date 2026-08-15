<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v1.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v1.0.0** was hardened automatically. 16 finding(s) were identified and resolved across 5 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings (rule a), allowing script injection. Affected steps:

1. 'Determine version' step: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"` — inputs.version is user-controlled and interpolated directly into the shell.

2. 'Determine platform' step: `case "${{ runner.os }}-${{ runner.arch }}"` and `echo "::error::Unsupported platform: ${{ runner.os }}-${{ runner.arch }}"` — runner.* expressions interpolated directly in run:.

3. 'Download AgentShield' step: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, `unzip -o agentshield.zip -d ${{ runner.temp }}/agentshield`, `mkdir -p ${{ runner.temp }}/agentshield`, `chmod +x ${{ runner.temp }}/agentshield/agentshield*`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — multiple ${{ }} expressions in run:.

4. 'Use provided AgentShield' step: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` — runner.temp in run:.

5. 'Run scan' step: `SCAN_LOG="${{ runner.temp }}/agentshield-scan.log"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `if [ "${{ inputs.format }}" = "sarif" ]`, `SARIF_FILE="${{ runner.temp }}/agentshield-results.sarif"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `if [ -n "${{ inputs.config }}" ]`, `if [ -n "${{ inputs.baseline }}" ]`, `if [ "${{ inputs.ignore-tests }}" = "true" ]` — multiple user-controlled inputs.* expressions directly in run:.

6. 'Check result' step: `'${{ inputs.fail-on }}'`, `${{ steps.scan.outputs.no_adapter }}`, `${{ inputs.strict }}` — directly interpolated in run:.

Locations:

- `action.yml:68`
- `action.yml:79`
- `action.yml:91`
- `action.yml:97`
- `action.yml:103`
- `action.yml:104`
- `action.yml:110`
- `action.yml:113`
- `action.yml:116`
- `action.yml:117`
- `action.yml:127`
- `action.yml:138`
- `action.yml:139`
- `action.yml:140`
- `action.yml:143`
- `action.yml:144`
- `action.yml:147`
- `action.yml:150`
- `action.yml:154`
- `action.yml:158`
- `action.yml:194`
- `action.yml:196`
- `action.yml:199`

### github-env-injection (severity: high)

In the 'Download AgentShield' step, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` writes a value derived from a ${{ }} expression directly to $GITHUB_PATH without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Similarly, in the 'Use provided AgentShield' step, `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"` is set and then `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` writes it to $GITHUB_PATH without sanitization. Any ${{ }} expression written to special environment files must be sanitized first.

Locations:

- `action.yml:117`
- `action.yml:133`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v4` which is pinned to a mutable tag (`v4`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved. It should be pinned to a specific commit SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:187`

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

Rewrote action.yml with the following changes:
1. All ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions moved from run: blocks to env: blocks in each step. Shell scripts now reference plain $VAR_NAME environment variables.
2. Both GITHUB_PATH writes now sanitize values with `printf '%s' "$VAR" | tr -d '\n\r'` before writing.
3. github/codeql-action/upload-sarif@v4 pinned to full SHA ff2f1c621b7f889edc0d3c761ac2e6a3f8cdb0dd # v4.
4. Run scan step refactored to use bash arrays (ARGS=()) for safe argument passing instead of string concatenation with unquoted ${{ }} expressions.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Determine version' step in action.yml (line 68): replaced `echo "version=$VERSION" >> $GITHUB_OUTPUT` with a two-step sanitized write: `safe_version=$(printf '%s' "$VERSION" | tr -d '\n\r')` followed by `echo "version=$safe_version" >> "$GITHUB_OUTPUT"`. This strips embedded newlines and carriage returns from the caller-controlled version input before writing to GITHUB_OUTPUT, preventing injection of additional key-value pairs. Also properly quoted the $GITHUB_OUTPUT variable reference.

### Iteration 3

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all findings across 9 workflow files:

1. action-e2e.yml: Moved all ${{ runner.temp }}, ${{ steps.*.outputs.* }}, and ${{ steps.*.outcome }} expressions from run: blocks to env: blocks. Sanitized GITHUB_PATH write with printf/tr. Pinned actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, github/codeql-action/upload-sarif@v4 to full SHAs.

2. gitleaks.yml: Moved ${{ github.workspace }} to env: block. Pinned actions/checkout@v6 and github/codeql-action/upload-sarif@v4.

3. semgrep.yml: Moved ${{ github.workspace }} to env: block. Pinned actions/checkout@v6 and github/codeql-action/upload-sarif@v4.

4. release.yml: Moved ${{ matrix.target }} and ${{ github.ref_name }} to env: blocks. Added sanitization (printf/tr for bash, -replace for PowerShell) before writing to GITHUB_ENV. Pinned all 6 action references.

5. docker.yml: Moved ${{ steps.build.outputs.digest }} and ${{ needs.metadata.outputs.json }} to env: blocks. Pinned all 7 action references.

6. ci.yml: Added top-level permissions: contents: read. Pinned all 5 action references.

7. agentshield.yml: Pinned actions/checkout@v6 and aiconnai/agentshield@v0.8.7.

8. codeql.yml: Pinned actions/checkout@v6, github/codeql-action/init@v3, github/codeql-action/analyze@v3.

9. feature-matrix.yml: Added top-level permissions: contents: read. Pinned all 3 action references.

10. pages.yml: Pinned all 4 action references.

11. vscode.yml: Added top-level permissions: contents: read. Pinned actions/checkout@v6 and actions/setup-node@v6.

### Iteration 4

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities:

1. hardened/action/.github/workflows/feature-matrix.yml (line 38): Replaced `- run: ${{ matrix.command }}` with an env-var indirection pattern. `matrix.command` is now assigned to `MATRIX_COMMAND` in the step's `env:` block, then tokenized via xargs into a bash array `cmd_args` and executed as `"${cmd_args[@]}"`. This prevents shell metacharacter injection while correctly handling multi-word commands like `cargo test --no-default-features --locked`.

2. hardened/action/.github/workflows/docker.yml (line 130): Replaced the unquoted `$tags` and `$sources` expansions in `docker buildx imagetools create $tags $sources` with properly-constructed bash arrays. Tags are read line-by-line from `jq -r '.tags[]'` output into `tag_args` (each prefixed with `-t`), and digest sources are built into a `sources` array by iterating over files in the working directory. Both arrays are expanded with double-quotes: `"${tag_args[@]}" "${sources[@]}"`, preventing word-splitting and command injection from attacker-controlled `needs.metadata.outputs.json` content.

### Iteration 5

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings:

1. hardened/action/.github/workflows/release.yml (lines 70, 74): Added `env: MATRIX_TARGET: ${{ matrix.target }}` to both 'Build (native)' and 'Build (cross)' steps, replacing direct `${{ matrix.target }}` interpolation in `run:` commands with `"$MATRIX_TARGET"` shell variable references.

2. hardened/action/.github/workflows/action-e2e.yml (line ~200, Test 8c): Changed Python invocation from `python3 -c "... Path('${SUBDIR_SARIF_FILE}').read_text() ..."` (which interpolated the shell variable directly into Python source code) to `python3 - "$SUBDIR_SARIF_FILE" << 'EOF' ... sarif = Path(sys.argv[1]).read_text() ... EOF` (passing the path as a CLI argument read via sys.argv[1], eliminating injection into Python source).

