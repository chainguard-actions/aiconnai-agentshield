<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v1.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v1.0.1** was hardened automatically. 10 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Multiple ${{ ... }} expressions are interpolated directly inside run: shell command strings in action-e2e.yml. Examples include: `mkdir -p ${{ runner.temp }}/agentshield` (Install binary step), `agentshield scan ... --output ${{ runner.temp }}/safe.sarif` (Test 1 step), `if [ "${{ steps.no-adapter-permissive.outputs.exit-code }}" != "2" ]` (Test 9c step), and many others. All ${{ runner.temp }}, ${{ steps.*.outputs.* }}, and ${{ steps.*.outcome }} expressions flow through YAML template substitution before the shell sees them and must not appear directly in run: blocks.

Locations:

- `.github/workflows/action-e2e.yml:36`
- `.github/workflows/action-e2e.yml:37`
- `.github/workflows/action-e2e.yml:38`
- `.github/workflows/action-e2e.yml:47`
- `.github/workflows/action-e2e.yml:60`
- `.github/workflows/action-e2e.yml:80`
- `.github/workflows/action-e2e.yml:100`
- `.github/workflows/action-e2e.yml:115`
- `.github/workflows/action-e2e.yml:130`
- `.github/workflows/action-e2e.yml:155`
- `.github/workflows/action-e2e.yml:175`
- `.github/workflows/action-e2e.yml:195`

### script-injection (severity: high)

Rule (a): `${{ matrix.command }}` is used directly as the entire run: value in feature-matrix.yml. The matrix.command context value flows through YAML template substitution before the shell executes it, allowing arbitrary shell command injection if the matrix is ever modified to include attacker-controlled values. Offending line: `- run: ${{ matrix.command }}`

Locations:

- `.github/workflows/feature-matrix.yml:37`

### script-injection (severity: high)

Rule (a): `${{ matrix.target }}` is interpolated directly inside run: shell command strings in release.yml. Examples: `run: cargo build --release --target ${{ matrix.target }} --features full` and `target/${{ matrix.target }}/release/agentshield --help | grep wrap`. These expressions flow through YAML template substitution before the shell sees them.

Locations:

- `.github/workflows/release.yml:57`
- `.github/workflows/release.yml:61`
- `.github/workflows/release.yml:66`
- `.github/workflows/release.yml:71`

### script-injection (severity: high)

Rule (a): `${{ github.workspace }}` is interpolated directly inside a run: shell command string in gitleaks.yml. Offending line: `-v "${{ github.workspace }}:/src"`. This expression flows through YAML template substitution before the shell sees it.

Locations:

- `.github/workflows/gitleaks.yml:22`

### script-injection (severity: high)

Rule (a): `${{ github.workspace }}` is interpolated directly inside a run: shell command string in semgrep.yml. Offending line: `-v "${{ github.workspace }}:/src"`. This expression flows through YAML template substitution before the shell sees it.

Locations:

- `.github/workflows/semgrep.yml:22`

### script-injection (severity: high)

Rule (b): In action.yml 'Run scan' step, user-controlled inputs are expanded unquoted inside the ARGS string and then passed to the shell unquoted via `agentshield $ARGS`. Specifically: `ARGS="scan ${INPUT_PATH}"` (INPUT_PATH = inputs.path), `ARGS="$ARGS --fail-on ${INPUT_FAIL_ON}"` (INPUT_FAIL_ON = inputs.fail-on), `ARGS="$ARGS --format ${INPUT_FORMAT}"` (INPUT_FORMAT = inputs.format), `ARGS="$ARGS --config ${INPUT_CONFIG}"` (INPUT_CONFIG = inputs.config), `ARGS="$ARGS --baseline ${INPUT_BASELINE}"` (INPUT_BASELINE = inputs.baseline). The final `agentshield $ARGS` is also unquoted, allowing word-splitting and glob expansion on attacker-controlled values.

Locations:

- `action.yml:155`

### github-env-injection (severity: high)

In action.yml 'Determine version' step, the VERSION variable is derived from INPUT_VERSION (which holds ${{ inputs.version }}, a user-controlled input). It is written to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`): `echo "version=$VERSION" >> $GITHUB_OUTPUT`. A malicious version input containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:100`

### permissions (severity: medium)

missing-permissions: ci.yml has no top-level `permissions:` key and none of its jobs (release-invariants, test, clippy, fmt, supply-chain, smoke, vscode) define job-level `permissions:` blocks. This means the workflow runs with the default (potentially write) token permissions.

Locations:

- `.github/workflows/ci.yml:1`

### permissions (severity: medium)

missing-permissions: feature-matrix.yml has no top-level `permissions:` key and its only job (feature-matrix) has no job-level `permissions:` block. This means the workflow runs with the default (potentially write) token permissions.

Locations:

- `.github/workflows/feature-matrix.yml:1`

### permissions (severity: medium)

missing-permissions: vscode.yml has no top-level `permissions:` key and its only job (test-and-package) has no job-level `permissions:` block. This means the workflow runs with the default (potentially write) token permissions.

Locations:

- `.github/workflows/vscode.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, permissions

**Notes:**

Fixed all 10 findings across 7 files:

1. action-e2e.yml: Moved all ${{ runner.temp }}, ${{ steps.*.outputs.* }}, and ${{ steps.*.outcome }} expressions from run: blocks into env: blocks, referencing them as shell variables (RUNNER_TEMP_DIR, SUBDIR_EXIT_CODE, NO_ADAPTER_EXIT_CODE, etc.).

2. feature-matrix.yml: Fixed ${{ matrix.command }} used as entire run: value by moving to env: block and using xargs-based tokenization (while/read/printf loop) to safely execute the command. Added top-level permissions: contents: read.

3. release.yml: Fixed ${{ matrix.target }} in run: blocks by moving to env: blocks as MATRIX_TARGET. Updated PowerShell step to use $env:MATRIX_TARGET syntax.

4. gitleaks.yml: Fixed ${{ github.workspace }} in run: block by moving to env: block as GITHUB_WORKSPACE_DIR.

5. semgrep.yml: Fixed ${{ github.workspace }} in run: block by moving to env: block as GITHUB_WORKSPACE_DIR.

6. action.yml Run scan step: Replaced string-concatenated ARGS variable with a bash array ARGS=() with properly quoted arguments, expanded as "${ARGS[@]}" to prevent word-splitting and glob expansion on user inputs.

7. action.yml Determine version step: Added sanitization using printf '%s' "$VERSION" | tr -d '\n\r' before writing to GITHUB_OUTPUT to prevent newline injection.

8. ci.yml: Added top-level permissions: contents: read.

9. vscode.yml: Added top-level permissions: contents: read.

