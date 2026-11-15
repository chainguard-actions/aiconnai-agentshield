<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v1.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v1.1.0** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

Step 'Determine version': VERSION comes from inputs.version (through INPUT_VERSION) or from the GitHub API response. It is written with `echo "version=$VERSION" >> $GITHUB_OUTPUT` and the sanitizer `printf '%s' ... | tr -d '\n\r'` is not applied first. A newline in the value could inject extra outputs.

Locations:

- `action.yml:103`

### github-env-injection (severity: high)

Step 'Download AgentShield': `echo "${RUNNER_TEMP_DIR}/agentshield" >> $GITHUB_PATH` writes a value taken from an env var set from runner.temp (not a literal set inside the script) and does not apply the `printf '%s' ... | tr -d '\n\r'` sanitizer first.

Locations:

- `action.yml:167`

### github-env-injection (severity: high)

Step 'Use provided AgentShield': `echo "$(dirname "$AGENTSHIELD_DEST")" >> $GITHUB_PATH` writes a path built from RUNNER_TEMP_DIR (an env var set from runner.temp) and does not apply the `printf '%s' ... | tr -d '\n\r'` sanitizer first.

Locations:

- `action.yml:186`

### github-env-injection (severity: high)

Step 'Run scan': `echo "sarif-file=$SARIF_FILE" >> $GITHUB_OUTPUT` writes SARIF_FILE, which is built from RUNNER_TEMP_DIR (an env var set from runner.temp), and does not apply the `printf '%s' ... | tr -d '\n\r'` sanitizer first.

Locations:

- `action.yml:245`

### script-injection (severity: high)

Rule (b), unquoted expansion of untrusted data, in step 'Run scan'. The script builds a single string ARGS from inputs.path, inputs.fail-on, inputs.format, inputs.config and inputs.baseline, then runs it unquoted: `agentshield $ARGS 2>&1 | tee "$SCAN_LOG"`. The shell splits it on whitespace and expands glob characters, so a crafted input can add extra arguments or change existing ones. Fix: build a bash array, e.g. ARGS=(scan "$INPUT_PATH" --fail-on "$INPUT_FAIL_ON" ...), and run it as `agentshield "${ARGS[@]}"`.

Locations:

- `action.yml:234`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

All changes are in action.yml. Each value written to GITHUB_OUTPUT or GITHUB_PATH now has newlines stripped first (printf '%s' | tr -d '\n\r'). This covers version, the agentshield bin directory (in both the download step and the provided-binary step) and sarif-file. The 'Run scan' step now builds its arguments as a bash array, with each single-value input (path, fail-on, format, config, baseline) as one quoted argument, and runs agentshield "${ARGS[@]}". Optional flags are only added when their input is set, as before. One behaviour change: path, config and baseline used to be split on whitespace and glob-expanded, and now each reaches agentshield as exactly one argument. A path containing spaces now works instead of breaking into several arguments. Nothing was run or tested.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

action.yml:188: added '|| true' to the DEST_DIR dirname capture. Upstream ran that command inside echo, where a failure never stopped the step, and this keeps that behaviour.

