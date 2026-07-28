# Verify the benchmarkutils plugin is installed. And if not, explain how to install it
# Prefer help:describe; fall back to a local jar check when Maven Central is unreachable.
if mvn -Dplugin=org.owasp:benchmarkutils-maven-plugin help:describe >/dev/null 2>&1; then
  :
elif ls "${HOME}/.m2/repository/org/owasp/benchmarkutils-maven-plugin/"*/*.jar >/dev/null 2>&1; then
  echo "Note: could not resolve plugin metadata from Maven Central; using locally installed benchmarkutils jar."
else
  echo ""
  echo "!!!WARNING: Required plugin: org.owasp:benchmarkutils-maven-plugin not available."
  echo "To get and install it, do the following:"
  echo "  git clone https://github.com/OWASP-Benchmark/BenchmarkUtils.git"
  echo "  cd BenchmarkUtils"
  echo "  mvn install"
  echo ""
  echo "This installs the plugin in your local Maven repo, and it can then be used from anywhere."
  echo ""
  exit 1
fi
