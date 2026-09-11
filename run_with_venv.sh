#!/usr/bin/env bash
#
# run_with_venv.sh
#
# Template for activating a Python virtual environment, running a
# Python script with any passed-through arguments, and then cleanly
# deactivating the venv afterwards — even if the script fails.
#
# Usage:
#   ./run_with_venv.sh [args passed to the python script...]
#
# Configure the variables below for your project.

set -euo pipefail

# ---- Configuration ---------------------------------------------------

# Path to the virtual environment directory (contains bin/activate)
VENV_PATH="./.venv"

# Path to the python script to run
PYTHON_SCRIPT="./main.py"

# Arguments that should ALWAYS be passed to the python script,
# regardless of what the user supplies on the command line.
# Leave empty ( () ) if you don't need any fixed arguments.
#
# Example:
#   FIXED_ARGS=(--config "./config.yaml" --verbose)
FIXED_ARGS=()

# ---- Implementation ---------------------------------------------------

# Ensure deactivation happens no matter how the script exits
# (normal exit, error, or Ctrl-C).
cleanup() {
    # 'deactivate' is a function defined by activate; only call it if it exists
    if command -v deactivate >/dev/null 2>&1; then
        deactivate
    fi
}
trap cleanup EXIT

if [[ ! -f "${VENV_PATH}/bin/activate" ]]; then
    echo "Error: venv activation script not found at ${VENV_PATH}/bin/activate" >&2
    exit 1
fi

# shellcheck disable=SC1091
source "${VENV_PATH}/bin/activate"

if [[ ! -f "${PYTHON_SCRIPT}" ]]; then
    echo "Error: python script not found at ${PYTHON_SCRIPT}" >&2
    exit 1
fi

# Combine hardcoded FIXED_ARGS with whatever the user passed in ("$@"),
# preserving quoting/spacing for both. FIXED_ARGS come first, so a
# user-supplied flag of the same name will typically override it
# (most argparse-based CLIs use "last value wins").
python "${PYTHON_SCRIPT}" "${FIXED_ARGS[@]}" "$@"
