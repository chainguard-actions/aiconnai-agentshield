#!/bin/sh
# Fake agentshield binary that simulates findings (exit 1) with SARIF output.
# Parses arguments to write a SARIF file with one finding if --output is specified.

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
          "version": "0.8.8"
        }
      },
      "results": [
        {
          "ruleId": "AS001",
          "level": "error",
          "message": {
            "text": "Hardcoded secret detected in agent configuration"
          },
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "agent/config.py"
                },
                "region": {
                  "startLine": 42
                }
              }
            }
          ]
        }
      ]
    }
  ]
}
SARIF
fi

echo "AgentShield scan complete. 1 finding(s) detected above threshold."
exit 1
