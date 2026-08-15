#!/bin/sh
# Fake agentshield binary that simulates a clean scan (no findings, exit 0)
# Supports: scan <path> --fail-on <level> --format <fmt> [--output <file>]

OUTPUT_FILE=""
FORMAT="console"

prev=""
for arg in "$@"; do
  case "$prev" in
    --output) OUTPUT_FILE="$arg" ;;
    --format) FORMAT="$arg" ;;
  esac
  prev="$arg"
done

if [ "$FORMAT" = "sarif" ] && [ -n "$OUTPUT_FILE" ]; then
  cat > "$OUTPUT_FILE" <<'SARIF'
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "AgentShield",
          "version": "0.0.0-fake"
        }
      },
      "results": []
    }
  ]
}
SARIF
  echo "AgentShield scan complete. No findings."
elif [ "$FORMAT" = "json" ]; then
  echo '{"findings":[],"summary":{"total":0}}'
else
  echo "AgentShield scan complete. No findings."
fi

exit 0
