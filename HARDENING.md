<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v1.0.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v1.0.2** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run scan' step: multiple env vars sourced from `inputs.*` are expanded **unquoted** inside the run: shell script. Specifically, `ARGS="scan ${INPUT_PATH}"`, `ARGS="$ARGS --fail-on ${INPUT_FAIL_ON}"`, `ARGS="$ARGS --format ${INPUT_FORMAT}"`, `ARGS="$ARGS --config ${INPUT_CONFIG}"`, `ARGS="$ARGS --baseline ${INPUT_BASELINE}"`, and the final `agentshield $ARGS` invocation all use unquoted expansions of attacker-controlled inputs. A caller can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, globs) via any of these inputs to achieve command injection.

Locations:

- `action.yml:153`
- `action.yml:154`
- `action.yml:160`
- `action.yml:165`
- `action.yml:169`
- `action.yml:172`

### github-env-injection (severity: high)

The 'Determine version' step writes `echo "version=$VERSION" >> $GITHUB_OUTPUT` where VERSION is derived from the user-controlled `inputs.version` input (via the INPUT_VERSION env var) without the required sanitization step (`printf '%s' "$VERSION" | tr -d '\n\r'`). A newline embedded in the version input could inject arbitrary key=value pairs into GITHUB_OUTPUT.

Locations:

- `action.yml:89`

### github-env-injection (severity: high)

The 'Download AgentShield' step writes `echo "${RUNNER_TEMP_DIR}/agentshield" >> $GITHUB_PATH` where RUNNER_TEMP_DIR is sourced from `runner.temp` (a workflow-controlled context value) without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline in the runner.temp value could inject arbitrary paths into GITHUB_PATH.

Locations:

- `action.yml:120`

### github-env-injection (severity: high)

The 'Use provided AgentShield' step writes `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` where AGENTSHIELD_DEST is derived from RUNNER_TEMP_DIR (sourced from `runner.temp`, a workflow-controlled context value) without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline in the runner.temp value could inject arbitrary paths into GITHUB_PATH.

Locations:

- `action.yml:138`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all four findings in action.yml:
1. 'Determine version' step (line 89): Sanitized VERSION with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_OUTPUT.
2. 'Download AgentShield' step (line 120): Sanitized RUNNER_TEMP_DIR with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_PATH.
3. 'Use provided AgentShield' step (line 138): Sanitized the dirname result with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_PATH.
4. 'Run scan' step (lines 153-172): Replaced unquoted string-based ARGS construction with a bash array (ARGS=(...) and ARGS+=(...)) and invoked `agentshield "${ARGS[@]}"` to properly quote each user-controlled input argument, preventing shell metacharacter injection.

