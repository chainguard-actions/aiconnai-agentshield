#!/bin/sh
# Fake curl: intercepts agentshield download and GitHub API requests.
# Supports both "curl URL | sh" (stdout) and "curl -o FILE URL" (file) forms.

out=""
prev=""
url=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  case "$arg" in
    http*) url="$arg" ;;
  esac
  prev="$arg"
done

# Intercept GitHub API latest release query
case "$url" in
  *api.github.com/repos/limaronaldo/agentshield/releases/latest*)
    PAYLOAD='{"tag_name":"v0.0.0-fake","name":"fake"}'
    if [ -n "$out" ]; then
      echo "$PAYLOAD" > "$out"
    else
      echo "$PAYLOAD"
    fi
    exit 0
    ;;
esac

# Intercept agentshield binary download
case "$url" in
  *limaronaldo/agentshield/releases/download*agentshield*.tar.gz*)
    # Build a tarball containing the fake agentshield binary
    TMPDIR_FAKE="$(mktemp -d)"
    cp "$GITHUB_WORKSPACE/tests/fixtures/fake-agentshield.sh" "$TMPDIR_FAKE/agentshield"
    chmod +x "$TMPDIR_FAKE/agentshield"
    TARBALL="$(mktemp).tar.gz"
    tar czf "$TARBALL" -C "$TMPDIR_FAKE" agentshield
    rm -rf "$TMPDIR_FAKE"
    if [ -n "$out" ]; then
      cp "$TARBALL" "$out"
    else
      cat "$TARBALL"
    fi
    rm -f "$TARBALL"
    exit 0
    ;;
  *limaronaldo/agentshield/releases/download*agentshield*.zip*)
    # Build a zip containing the fake agentshield binary
    TMPDIR_FAKE="$(mktemp -d)"
    cp "$GITHUB_WORKSPACE/tests/fixtures/fake-agentshield.sh" "$TMPDIR_FAKE/agentshield"
    chmod +x "$TMPDIR_FAKE/agentshield"
    ZIPFILE="$(mktemp).zip"
    (cd "$TMPDIR_FAKE" && zip -q "$ZIPFILE" agentshield)
    rm -rf "$TMPDIR_FAKE"
    if [ -n "$out" ]; then
      cp "$ZIPFILE" "$out"
    else
      cat "$ZIPFILE"
    fi
    rm -f "$ZIPFILE"
    exit 0
    ;;
esac

# Fall through to real curl for anything else
exec /usr/bin/curl "$@"
