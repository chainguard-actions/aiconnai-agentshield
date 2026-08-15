#!/bin/sh
# Fake curl: intercepts agentshield download requests and serves a fake tarball.
# Honors both "curl URL | sh" (stdout) and "curl -o FILE URL" (write to file).
# Falls through to real curl for all other URLs.

out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done

# Check if this is an agentshield binary download request
case "$*" in
  *agentshield*releases/download*)
    # Build a fake tarball containing the fake agentshield binary
    TMPD="$(mktemp -d)"
    cp /tmp/fake-agentshield "$TMPD/agentshield"
    chmod +x "$TMPD/agentshield"
    TARBALL="$(mktemp).tar.gz"
    tar czf "$TARBALL" -C "$TMPD" agentshield
    rm -rf "$TMPD"
    if [ -n "$out" ]; then
      cp "$TARBALL" "$out"
    else
      cat "$TARBALL"
    fi
    rm -f "$TARBALL"
    exit 0
    ;;
  *api.github.com*agentshield*releases/latest*)
    # Return a fake release JSON with a version tag
    PAYLOAD='{"tag_name":"v0.0.0-test","name":"Test Release"}'
    if [ -n "$out" ]; then
      printf '%s\n' "$PAYLOAD" > "$out"
    else
      printf '%s\n' "$PAYLOAD"
    fi
    exit 0
    ;;
esac

# Fall through to real curl for other URLs
exec /usr/bin/curl "$@"
