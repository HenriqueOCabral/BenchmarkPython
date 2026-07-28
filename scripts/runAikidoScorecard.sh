#!/usr/bin/env bash
# Place an Aikido/Opengrep SARIF export into results/ with the naming
# BenchmarkUtils expects, then generate scorecards.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ "$(basename "$(pwd)")" != "$(basename "$(git rev-parse --show-toplevel)")" ]; then
	echo "Run this from the root directory of the Benchmark for Python."
	exit 1
fi

SARIF_SRC="${1:-AIK.sarif.json}"
if [ ! -f "$SARIF_SRC" ]; then
	echo "SARIF file not found: $SARIF_SRC"
	echo "Usage: $0 [path/to/export.sarif.json]"
	exit 1
fi

VERSION="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['runs'][0]['tool']['driver'].get('semanticVersion') or d['runs'][0]['tool']['driver'].get('version') or '0.0.0')" "$SARIF_SRC")"
DEST="results/Benchmark_Aikido-${VERSION}.sarif"
mkdir -p results
cp "$SARIF_SRC" "$DEST"
echo "Copied $SARIF_SRC -> $DEST"

./createScorecards.sh
