#!/bin/sh
# Fake agentshield binary for testing
# Parses arguments and produces appropriate output

FORMAT="console"
OUTPUT=""
FAIL_ON="high"

# Parse arguments
prev=""
for arg in "$@"; do
  case "$prev" in
    --format) FORMAT="$arg" ;;
    --output) OUTPUT="$arg" ;;
    --fail-on) FAIL_ON="$arg" ;;
  esac
  prev="$arg"
done

SARIF_CONTENT='{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "AgentShield",
          "version": "0.0.0-fake",
          "rules": []
        }
      },
      "results": []
    }
  ]
}'

if [ "$FORMAT" = "sarif" ]; then
  if [ -n "$OUTPUT" ]; then
    echo "$SARIF_CONTENT" > "$OUTPUT"
  else
    echo "$SARIF_CONTENT"
  fi
elif [ "$FORMAT" = "json" ]; then
  echo '{"findings":[],"summary":{"total":0}}'
else
  echo "AgentShield scan complete. No findings."
fi

exit 0
