#!/bin/sh
# Fake agentshield binary that simulates findings (exit 1) with SARIF output

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
      "results": [
        {
          "ruleId": "AS001",
          "level": "error",
          "message": {
            "text": "Hardcoded secret detected"
          },
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "agent.py"
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
  echo "AgentShield scan complete. 1 finding(s) detected."
else
  echo "AgentShield scan complete. 1 finding(s) detected."
fi

exit 1
