<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v1.0.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v1.0.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The 'Determine version' step copies VERSION from the INPUT_VERSION env var (set from inputs.version), or from the GitHub API response when the version is 'latest'. It then writes it with `echo "version=$VERSION" >> $GITHUB_OUTPUT` and never runs the required `printf '%s' "$VERSION" | tr -d '\n\r'` step first. A newline in the input could inject extra step outputs.

Locations:

- `action.yml:103`

### script-injection (severity: high)

Rule (b) violation in the 'Run scan' step. Values from inputs (INPUT_PATH, INPUT_FAIL_ON, INPUT_FORMAT, INPUT_CONFIG, INPUT_BASELINE) are joined into the ARGS string, starting with `ARGS="scan ${INPUT_PATH}"`. ARGS is then expanded unquoted in `agentshield $ARGS 2>&1 | tee "$SCAN_LOG"`. The shell splits and glob-expands this workflow-controlled data, so whitespace or glob characters in an input can add arguments. This is not the exempt NAME=($VAR) array form with a shellcheck directive. Fix: build a bash array, e.g. ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON" ...), and run it as "${ARGS[@]}".

Locations:

- `action.yml:225`
- `action.yml:201`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Determine version: VERSION is sanitized with printf '%s' | tr -d '\n\r' before being written to "$GITHUB_OUTPUT". Run scan: the space-joined ARGS string was replaced with a bash array (scan "$INPUT_PATH" --fail-on ..., with the optional --format/--output/--config/--baseline/--ignore-tests flags appended through ARGS+=), and it is run as agentshield "${ARGS[@]}". Every input is a single value (a path, a severity or a format), so each one is one quoted argument.

