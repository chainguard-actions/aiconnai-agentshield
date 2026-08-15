<!-- markdownlint-disable -->

# Hardening Report: aiconnai--agentshield/v0.8.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **aiconnai--agentshield/v0.8.5** was hardened automatically. 17 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings in action.yml, violating sub-rule (a). User-controlled inputs (inputs.version, inputs.path, inputs.fail-on, inputs.format, inputs.config, inputs.ignore-tests) and runner/step contexts (runner.os, runner.arch, runner.temp, steps.version.outputs.version, steps.platform.outputs.target) are all interpolated before the shell sees them, enabling command injection by any caller of this composite action. Offending lines include: `if [ "${{ inputs.version }}" = "latest" ]`, `VERSION="${{ inputs.version }}"`, `case "${{ runner.os }}-${{ runner.arch }}"`, `ARGS="scan ${{ inputs.path }}"`, `ARGS="$ARGS --fail-on ${{ inputs.fail-on }}"`, `ARGS="$ARGS --format ${{ inputs.format }}"`, `ARGS="$ARGS --config ${{ inputs.config }}"`, `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH`.

Locations:

- `action.yml:56`
- `action.yml:60`
- `action.yml:68`
- `action.yml:78`
- `action.yml:79`
- `action.yml:84`
- `action.yml:89`
- `action.yml:97`
- `action.yml:98`
- `action.yml:102`
- `action.yml:106`
- `action.yml:130`

### script-injection (severity: high)

Multiple ${{ }} expressions are directly interpolated inside run: shell command strings in release.yml, violating sub-rule (a). matrix.target and github.ref_name are interpolated directly in shell commands: `cargo build --release --target ${{ matrix.target }}`, `target/${{ matrix.target }}/release/agentshield --help | grep wrap`, `BINARY=target/${{ matrix.target }}/release/agentshield`, `ARCHIVE=agentshield-${{ github.ref_name }}-${{ matrix.target }}.tar.gz`, and equivalent Windows PowerShell variants.

Locations:

- `.github/workflows/release.yml:57`
- `.github/workflows/release.yml:61`
- `.github/workflows/release.yml:65`
- `.github/workflows/release.yml:71`
- `.github/workflows/release.yml:76`
- `.github/workflows/release.yml:77`
- `.github/workflows/release.yml:84`
- `.github/workflows/release.yml:85`

### script-injection (severity: high)

A ${{ steps.build.outputs.digest }} expression is directly interpolated inside a run: shell command string in docker.yml, violating sub-rule (a). The steps.*.outputs.* context flows through YAML template substitution before the shell sees it. Offending line: `digest="${{ steps.build.outputs.digest }}"`

Locations:

- `.github/workflows/docker.yml:79`

### github-env-injection (severity: high)

In action.yml, values derived from user-controlled inputs are written to GITHUB_OUTPUT and GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r'). (1) Step 'Determine version': VERSION is set from ${{ inputs.version }} via direct shell interpolation, then `echo "version=$VERSION" >> $GITHUB_OUTPUT` — no sanitization. (2) Step 'Determine platform': TARGET is computed from ${{ runner.os }}-${{ runner.arch }}, then `echo "target=$TARGET" >> $GITHUB_OUTPUT` — no sanitization. (3) Step 'Download AgentShield': `echo "${{ runner.temp }}/agentshield" >> $GITHUB_PATH` — direct expression write to GITHUB_PATH. (4) Step 'Run scan': SARIF_FILE is derived from ${{ runner.temp }} and written to GITHUB_OUTPUT without sanitization.

Locations:

- `action.yml:63`
- `action.yml:73`
- `action.yml:91`
- `action.yml:116`
- `action.yml:117`
- `action.yml:122`

### github-env-injection (severity: high)

In release.yml 'Package (unix)' step, ARCHIVE is constructed from ${{ github.ref_name }} and ${{ matrix.target }} via direct shell interpolation, then written to GITHUB_ENV without sanitization: `echo "ARCHIVE=$ARCHIVE" >> $GITHUB_ENV`. A tag name containing newline characters could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/release.yml:79`

### unpinned-uses (severity: high)

All uses: references across action.yml and all workflow files use mutable tag/version strings instead of immutable 40-character SHA digests, making the action vulnerable to supply-chain attacks if any referenced action's tag is moved or the action is compromised.

action.yml: github/codeql-action/upload-sarif@v3

ci.yml: actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2

action-e2e.yml: actions/checkout@v4, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, github/codeql-action/upload-sarif@v3

docker.yml: actions/checkout@v6, docker/metadata-action@v6, docker/login-action@v4, docker/setup-buildx-action@v4, docker/build-push-action@v7, actions/upload-artifact@v7, actions/download-artifact@v7

release.yml: actions/checkout@v6, dtolnay/rust-toolchain@stable, Swatinem/rust-cache@v2, actions/upload-artifact@v7, actions/download-artifact@v7, softprops/action-gh-release@v3, docker/setup-qemu-action@v3, docker/setup-buildx-action@v3, docker/login-action@v3, docker/build-push-action@v6

Locations:

- `action.yml:138`
- `.github/workflows/ci.yml:16`
- `.github/workflows/ci.yml:17`
- `.github/workflows/ci.yml:18`
- `.github/workflows/action-e2e.yml:22`
- `.github/workflows/action-e2e.yml:25`
- `.github/workflows/action-e2e.yml:26`
- `.github/workflows/action-e2e.yml:161`
- `.github/workflows/docker.yml:18`
- `.github/workflows/docker.yml:37`
- `.github/workflows/docker.yml:60`
- `.github/workflows/docker.yml:65`
- `.github/workflows/docker.yml:70`
- `.github/workflows/docker.yml:91`
- `.github/workflows/docker.yml:101`
- `.github/workflows/release.yml:18`
- `.github/workflows/release.yml:44`
- `.github/workflows/release.yml:47`
- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:107`
- `.github/workflows/release.yml:113`
- `.github/workflows/release.yml:131`
- `.github/workflows/release.yml:135`
- `.github/workflows/release.yml:139`
- `.github/workflows/release.yml:143`

### missing-permissions (severity: medium)

ci.yml has no top-level permissions: block and none of its four jobs (test, clippy, fmt, smoke) define job-level permissions. The workflow therefore runs with GitHub's default token permissions, which include write access to contents on push events. All jobs should declare explicit minimal permissions.

Locations:

- `.github/workflows/ci.yml:1`

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yml, .github/workflows/ci.yml, .github/workflows/docker.yml, .github/workflows/release.yml, and .github/workflows/action-e2e.yml:

1. script-injection & static-inline-injection (action.yml): Moved all ${{ inputs.* }}, ${{ runner.* }}, and ${{ steps.*.outputs.* }} expressions from run: blocks into env: blocks. Shell scripts now reference plain $VAR_NAME environment variables.

2. script-injection (release.yml): Moved ${{ matrix.target }} and ${{ github.ref_name }} from run: blocks into env: blocks (MATRIX_TARGET, REF_NAME).

3. script-injection (docker.yml): Moved ${{ steps.build.outputs.digest }} and ${{ needs.metadata.outputs.json }} from run: blocks into env: blocks (BUILD_DIGEST, METADATA_JSON).

4. github-env-injection (action.yml): All values written to GITHUB_OUTPUT and GITHUB_PATH are sanitized with `printf '%s' ... | tr -d '\n\r'` before writing.

5. github-env-injection (release.yml): ARCHIVE value written to GITHUB_ENV is sanitized with `printf '%s' ... | tr -d '\n\r'`.

6. unpinned-uses: All action references pinned to full SHA digests with tag comments: actions/checkout@v4→11d5960a, actions/checkout@v6→d23441a4, dtolnay/rust-toolchain@stable→4cda84d5, Swatinem/rust-cache@v2→e18b4977, github/codeql-action/upload-sarif@v3→b7351df7, docker/metadata-action@v6→dc802804, docker/login-action@v4→af1e73f9, docker/setup-buildx-action@v4→bb05f3f5, docker/build-push-action@v7→53b7df96, actions/upload-artifact@v7→043fb46d, actions/download-artifact@v7→37930b1c, softprops/action-gh-release@v3→3d0d9888, docker/setup-qemu-action@v3→c7c53464, docker/setup-buildx-action@v3→8d2750c6, docker/login-action@v3→c94ce9fb, docker/build-push-action@v6→10e90e36.

7. missing-permissions (ci.yml): Added top-level `permissions: contents: read` block.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run scan' step of action.yml. Replaced the string-based $ARGS construction (where user-controlled inputs were concatenated unquoted and then expanded with `agentshield $ARGS`) with a bash array approach. Each argument is now added to the array with proper double-quoting (e.g., `ARGS=("scan" "$INPUT_PATH")`, `ARGS+=("--fail-on" "$INPUT_FAIL_ON")`), and the command is invoked as `agentshield "${ARGS[@]}"`. This ensures each argument is treated as a separate, properly-quoted word, preventing word splitting, glob expansion, and shell metacharacter injection from attacker-controlled values like inputs.path, inputs.fail-on, inputs.format, and inputs.config.

### Iteration 3

**Fixes applied:** github-env-injection, script-injection

**Notes:**

1. release.yml Package (windows) step: Added PowerShell newline-stripping sanitization using `-replace` before writing ARCHIVE to GITHUB_ENV. The value is now stored in `$safe_archive` with CR and LF stripped before being written to the environment file.
2. docker.yml Create and push manifest list step: Replaced the unquoted `$tags` expansion (built via `jq | xargs`) with a bash array approach. Tags are read one-by-one from `jq -r '.tags[]'` into a `tag_args` array as `-t "$tag"` pairs, and sources are also built into an array. The docker command uses `"${tag_args[@]}" "${sources[@]}"` for safe, properly-quoted expansion that prevents shell metacharacter injection.

