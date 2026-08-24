#!/usr/bin/env bash
# Apply Autotriage suppressions to AIK.sarif.json and regenerate the scorecard.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 << 'PY'
import json
from pathlib import Path

IGNORED = {
    'BenchmarkTest01108', 'BenchmarkTest01222',
    'BenchmarkTest00075', 'BenchmarkTest00163', 'BenchmarkTest01166',
    'BenchmarkTest00730', 'BenchmarkTest00821', 'BenchmarkTest00822', 'BenchmarkTest01173',
    'BenchmarkTest01165', 'BenchmarkTest00987', 'BenchmarkTest00893', 'BenchmarkTest00892',
    'BenchmarkTest00818', 'BenchmarkTest00600', 'BenchmarkTest00423', 'BenchmarkTest00345',
    'BenchmarkTest00344', 'BenchmarkTest00263', 'BenchmarkTest00158', 'BenchmarkTest00157',
    'BenchmarkTest00156',
    'BenchmarkTest00513', 'BenchmarkTest00608', 'BenchmarkTest00658', 'BenchmarkTest00995',
    'BenchmarkTest01172', 'BenchmarkTest01230',
}

with open('AIK.sarif.json') as f:
    sarif = json.load(f)
kept = []
for r in sarif['runs'][0]['results']:
    test = Path(r['locations'][0]['physicalLocation']['artifactLocation']['uri']).stem
    if test not in IGNORED:
        kept.append(r)
sarif['runs'][0]['results'] = kept
Path('AIK.sarif.autotriage.json').write_text(json.dumps(sarif, separators=(',', ':')))
ver = sarif['runs'][0]['tool']['driver'].get('semanticVersion', '0.0.0')
Path('results').mkdir(exist_ok=True)
Path(f'results/Benchmark_Aikido-{ver}-autotriage.sarif').write_text(json.dumps(sarif, separators=(',', ':')))
print(f'Filtered SARIF: {len(kept)} findings ({len(IGNORED)} suppressed)')
PY

# Score Aikido-only
mkdir -p .results-aside scorecard-autotriage
for f in results/Benchmark-*.json results/BenchmarkPython-*.sarif results/Benchmark_Aikido-1.18.0.sarif; do
  [ -f "$f" ] && mv "$f" .results-aside/ 2>/dev/null || true
done

source scripts/verifyBenchmarkPluginAvailable.sh 2>/dev/null || true
export PATH="/opt/homebrew/bin:${PATH:-}"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/Cellar/openjdk/26.0.2/libexec/openjdk.jdk/Contents/Home}"
JAR="${HOME}/.m2/repository/org/owasp/benchmarkutils-maven-plugin/1.3/benchmarkutils-maven-plugin-1.3-jar-with-dependencies.jar"
OUT="${ROOT}/.bu-patched-classes"
API="${HOME}/.m2/repository/org/apache/maven/maven-plugin-api/3.9.14/maven-plugin-api-3.9.14.jar"
CP="${OUT}:${JAR}:${API}:${HOME}/.m2/repository/org/apache/maven/maven-artifact/3.9.14/maven-artifact-3.9.14.jar"

MAVEN_OPTS="-Xmx8G" "${JAVA_HOME}/bin/java" -Djava.awt.headless=true -cp "$CP" \
  org.owasp.benchmarkutils.score.BenchmarkScore -cf scoringconfigfile.yaml

cp scorecard/Benchmark_v0.1_Scorecard_for_Aikido_Security_v1.18.0.* scorecard-autotriage/
mv .results-aside/* results/ 2>/dev/null || true

echo "Scorecard: scorecard-autotriage/Benchmark_v0.1_Scorecard_for_Aikido_Security_v1.18.0.html"
