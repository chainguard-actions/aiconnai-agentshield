#!/bin/sh
# Fake agentshield binary that simulates no suitable adapter found.
# Exits 2 (error) with the specific "No suitable adapter found" message.

echo "No suitable adapter found for directory: ."
exit 2
