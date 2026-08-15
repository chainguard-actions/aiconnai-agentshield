#!/bin/sh
# Fake agentshield binary for testing
# Simulates the agentshield scan command

FORMAT="console"
OUTPUT_FILE=""

prev=""
for arg in "$@"; do
  case "$prev" in
    --format) FORMAT="$arg" ;;
    --output) OUTPUT_FILE="$arg" ;;
  esac
  prev="$arg"
done

if [ "$FORMAT" = "sarif" ] && [ -n "$OUTPUT_FILE" ]; then
  printf '{"$schema":"https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json","version":"2.1.0","runs":[{"tool":{"driver":{"name":"agentshield","version":"0.0.0-test","rules":[]}},"results":[]}]}\n' > "$OUTPUT_FILE"
fi

if [ "$FORMAT" = "json" ]; then
  echo '{"findings":[],"summary":{"total":0}}'
fi

if [ "$FORMAT" = "console" ]; then
  echo "AgentShield scan complete. No findings."
fi

exit 0
