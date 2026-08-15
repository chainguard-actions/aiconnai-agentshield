#!/bin/sh
# Fake agentshield binary that simulates a successful scan with no findings.
# Supports: scan <path> --fail-on <sev> --format sarif --output <file>
# Exits 0 (pass).

OUTPUT_FILE=""
FORMAT="console"

# Parse arguments to find --output and --format
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
      "results": []
    }
  ]
}
SARIF
fi

echo "AgentShield scan complete. No findings."
exit 0
