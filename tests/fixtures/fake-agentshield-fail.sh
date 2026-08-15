#!/bin/sh
# Fake agentshield binary that simulates a scan with one HIGH finding.
# Exits 1 (findings above threshold).

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
  "version": "2.1.0",
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
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
          "message": { "text": "Hardcoded secret detected" },
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": { "uri": "src/agent.py" },
                "region": { "startLine": 42 }
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

echo "AgentShield scan complete. 1 finding(s) above threshold."
exit 1
