#!/bin/sh
# Fake agentshield binary that simulates "No suitable adapter found" (exit 2).
# This is used to test the strict=false non-blocking behavior.

echo "No suitable adapter found for directory: ."
exit 2
