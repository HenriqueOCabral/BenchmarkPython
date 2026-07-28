#!/bin/sh
## WARNING: This script makes the Benchmark for Python web access accesible outside your machine. Be careful when doing this.

set -e

# ensure you are in the right directory when running this script
if [ $(basename $(pwd)) != $(basename $(git rev-parse --show-toplevel)) ]; then
	echo "Run this from the root directory of the Benchmark for Python."
	exit 1
fi

# Test cases use match/case and nested f-string quotes (Python 3.12+)
PY_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PY_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 12 ]; }; then
	echo "Python 3.12+ is required (found $(python3 --version))."
	exit 1
fi

# ensure venv exists
if [ ! -d venv ]; then
	echo "Creating python venv..."
	python3 -m venv venv
fi


if [ -n ${VIRTUAL_ENV} ]; then
source venv/bin/activate
ENTERED_VENV=y
fi

pip install -q -r requirements.txt

# TODO: Replace with a real WSGI server (whatever that means)
flask --app app.py run --debug --port 8443 --cert=adhoc --host=0.0.0.0


if [ -v ENTERED_VENV ]; then
	deactivate
fi

