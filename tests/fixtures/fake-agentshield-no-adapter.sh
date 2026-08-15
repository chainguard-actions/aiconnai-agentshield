#!/bin/sh
# Fake agentshield binary that simulates "no suitable adapter found" (exit 2)
# The action checks for "No suitable adapter found for directory:" in the log.

echo "No suitable adapter found for directory: ."
exit 2
