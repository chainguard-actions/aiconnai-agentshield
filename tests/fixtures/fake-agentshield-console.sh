#!/bin/sh
# Fake agentshield binary that outputs in console format (no SARIF file).
# Exits 0 (pass).

echo "AgentShield Security Scanner"
echo "Scanning path: ."
echo "No findings detected."
exit 0
