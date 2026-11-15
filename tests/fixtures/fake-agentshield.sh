#!/bin/sh
# Fake agentshield binary for tests. Behaviour is selected by the contents of
# /tmp/fake-agentshield-mode (clean | findings | noadapter | error).
MODE="$(cat /tmp/fake-agentshield-mode 2>/dev/null || echo clean)"

if [ "$1" = "scan" ] && [ "$2" = "--help" ]; then
  echo "Usage: agentshield scan [OPTIONS] <PATH>"
  echo "      --trust-target-config  Apply the target's own config and rules"
  exit 0
fi

echo "$@" > /tmp/fake-agentshield-args.log

out=""
prev=""
for a in "$@"; do
  if [ "$prev" = "--output" ]; then
    out="$a"
  fi
  prev="$a"
done

write_sarif() {
  if [ -n "$out" ]; then
    printf '{"version":"2.1.0","runs":[{"tool":{"driver":{"name":"agentshield"}},"results":[%s]}]}\n' "$1" > "$out"
  fi
}

case "$MODE" in
  clean)
    write_sarif ""
    echo "AgentShield: no findings"
    exit 0
    ;;
  findings)
    write_sarif '{"ruleId":"SHIELD-001","level":"error","message":{"text":"Command injection"},"locations":[{"physicalLocation":{"artifactLocation":{"uri":"src/tool.py"},"region":{"startLine":10}}}]},{"ruleId":"SHIELD-002","level":"warning","message":{"text":"Unpinned dependency"},"locations":[{"physicalLocation":{"artifactLocation":{"uri":"requirements.txt"},"region":{"startLine":3}}}]}'
    echo "AgentShield: 2 findings"
    exit 1
    ;;
  noadapter)
    echo "Error: No suitable adapter found for directory: ."
    exit 2
    ;;
  *)
    echo "Error: internal scanner failure"
    exit 2
    ;;
esac
