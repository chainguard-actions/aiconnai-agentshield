<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.8** was hardened automatically. 21 finding(s) were identified and resolved across 5 iteration(s).

## Findings Fixed

### script-injection (severity: high)

(a) The 'Determine version' step puts inputs.version straight into the shell script: `if [ "${{ inputs.version }}" = "latest" ]` and `VERSION="${{ inputs.version }}"`. Anyone who controls the input can inject shell commands.

Locations:

- `action.yml:70`
- `action.yml:81`

### script-injection (severity: high)

(a) The 'Determine platform' step puts runner.os and runner.arch straight into the script: `case "${{ runner.os }}-${{ runner.arch }}" in` and in the error echo. Use $RUNNER_OS and $RUNNER_ARCH instead.

Locations:

- `action.yml:100`
- `action.yml:106`

### script-injection (severity: high)

(a) The 'Download AgentShield' step puts expressions straight into the script: `VERSION="${{ steps.version.outputs.version }}"`, `TARGET="${{ steps.platform.outputs.target }}"`, and several unquoted `${{ runner.temp }}` uses (unzip -d, mkdir -p, tar -C, chmod, echo to GITHUB_PATH).

Locations:

- `action.yml:114`
- `action.yml:115`
- `action.yml:121`
- `action.yml:130`

### script-injection (severity: high)

(a) The 'Use provided AgentShield' step puts runner.temp straight into the script: `AGENTSHIELD_DEST="${{ runner.temp }}/agentshield/agentshield"`.

Locations:

- `action.yml:142`

### script-injection (severity: high)

(a)/(b) The 'Run scan' step puts many inputs straight into the script: `ARGS="scan ${{ inputs.path }}"`, `--fail-on ${{ inputs.fail-on }}`, `${{ inputs.format }}`, `${{ inputs.config }}`, `${{ inputs.baseline }}`, `${{ inputs.ignore-tests }}` and `${{ runner.temp }}`. It then runs the combined string unquoted (`agentshield $ARGS`), so the shell splits and globs any input-supplied text. The SARIF path is also passed into python -c by string interpolation.

Locations:

- `action.yml:154`
- `action.yml:155`
- `action.yml:156`
- `action.yml:179`

### script-injection (severity: high)

(a) The 'Check result' step puts expressions straight into the script: `'${{ inputs.fail-on }}' threshold`, `"${{ steps.scan.outputs.no_adapter }}"` and `"${{ inputs.strict }}"`.

Locations:

- `action.yml:247`

### github-env-injection (severity: high)

The 'Determine version' step copies inputs.version into VERSION and writes it unsanitized with `echo "version=$VERSION" >> $GITHUB_OUTPUT`. It does not run printf '%s' | tr -d '\n\r' first, so a newline in the input can inject extra outputs.

Locations:

- `action.yml:93`

### unpinned-uses (severity: high)

A composite step uses a tag instead of a commit SHA: `uses: github/codeql-action/upload-sarif@v4`.

Locations:

- `action.yml:237`

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

Every inputs.*, steps.*.outputs.* expression is now in step env: blocks. The run: scripts read runner.temp, runner.os and runner.arch through $RUNNER_TEMP, $RUNNER_OS and $RUNNER_ARCH. The scan command is now built as a bash array, with each value double-quoted as a single argument. The python -c SARIF count gets the file path via sys.argv instead of having it pasted into the code. The version output is cleaned with tr -d '\n\r' before it goes to GITHUB_OUTPUT. github/codeql-action/upload-sarif is pinned to 9b3254085494b55a0f7c4c2b3d2d52cc712ce370 (v4). The incremental edits corrupted the file partway through, so I rewrote the whole action.yml cleanly with write_file.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In action.yml, the three flagged writes now strip newlines before writing. Each value goes through printf '%s' ... | tr -d '\n\r' first: the RUNNER_TEMP/agentshield path written to GITHUB_PATH, the dirname of AGENTSHIELD_DEST written to GITHUB_PATH, and SARIF_FILE written to GITHUB_OUTPUT. The dirname result is saved to a variable on its own line and cleaned on the next line, so cleaning doesn't wrap a command substitution. Nothing else changed.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

'Use provided AgentShield': put back `cp "$AGENTSHIELD_BINARY_PATH" "$AGENTSHIELD_DEST"` and the closing `fi`, and deleted the unsanitized duplicate `$GITHUB_PATH` write. Only the sanitized SAFE_DEST_DIR write is left. 'Run scan': added the `fi` that closes the grep if/else, removed the corrupted `B_OUTPUT"` text and the unsanitized sarif-file line, and kept the sanitized SAFE_SARIF_FILE write. One addition the findings didn't ask for: I added `echo "exit-code=$EXIT_CODE" >> "$GITHUB_OUTPUT"`. This is a guess at what the broken edit overwrote. The action's `exit-code` output reads `steps.scan.outputs.exit-code`, and nothing else in the file writes it. I didn't check upstream's file, so compare this line with upstream before release. Nothing was run, so I haven't confirmed that the two repaired steps now parse.

### Iteration 4

**Fixes applied:** invalid-yaml

**Notes:**

Repaired damage from an earlier edit in the 'Run scan' step: removed a duplicated, truncated 'echo "no_adapter=false" >>' fragment, and turned the stray 'if available' line at column 0, which ended the block scalar early, back into the '# Count findings from SARIF if available' comment at the correct indentation. No other changes were made.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

action.yml:152: changed DEST_DIR capture to 'DEST_DIR="$(dirname "$AGENTSHIELD_DEST")" || true' to keep upstream's non-fatal behaviour; sanitization before GITHUB_PATH is unchanged.

