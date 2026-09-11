# run_with_venv.sh

A small bash wrapper that activates a Python virtual environment, runs a
Python script, and guarantees the environment is deactivated afterward —
even if the script errors out or is interrupted.

## Features

- Activates a virtual environment before running your script
- Forwards any command-line arguments straight through to the Python script
- Supports **hardcoded/fixed arguments** that are always passed in, in
  addition to whatever the user supplies
- Always deactivates the venv on exit, whether the run succeeds, fails,
  or is interrupted (`Ctrl-C`)
- Fails fast with clear error messages if the venv or script can't be found

## Requirements

- bash
- A Python virtual environment created with `python -m venv` (or
  equivalent), containing `bin/activate`

## Setup

1. Copy `run_with_venv.sh` into your project.
2. Make it executable:

   ```bash
   chmod +x run_with_venv.sh
   ```

3. Open the script and edit the configuration variables near the top:

   ```bash
   # Path to the virtual environment directory (contains bin/activate)
   VENV_PATH="./venv"

   # Path to the python script to run
   PYTHON_SCRIPT="./main.py"

   # Arguments that should ALWAYS be passed to the python script
   FIXED_ARGS=()
   ```

   | Variable         | Description                                                                 |
   |------------------|-------------------------------------------------------------------------------|
   | `VENV_PATH`      | Path to your venv folder (the one containing `bin/activate`).                |
   | `PYTHON_SCRIPT`  | Path to the Python script you want to run.                                   |
   | `FIXED_ARGS`     | Bash array of arguments always passed to the script, e.g. `(--verbose)`.     |

## Usage

```bash
./run_with_venv.sh [arguments...]
```

Any arguments you pass on the command line are forwarded to the Python
script, appended after any `FIXED_ARGS`.

### Examples

Run with no extra arguments:

```bash
./run_with_venv.sh
```

Run with arguments passed at the command line:

```bash
./run_with_venv.sh --input data.csv --output results.json
```

Run with a hardcoded default configured in the script (`FIXED_ARGS=(--config
"./config.yaml")`), plus a user-supplied argument:

```bash
./run_with_venv.sh --verbose
# effectively runs:
# python ./main.py --config ./config.yaml --verbose
```

## How it works

- `trap cleanup EXIT` registers a cleanup function that calls `deactivate`
  whenever the script exits — for any reason — so the venv is never left
  active by accident.
- `source "${VENV_PATH}/bin/activate"` activates the environment.
- `python "${PYTHON_SCRIPT}" "${FIXED_ARGS[@]}" "$@"` runs your script with
  the fixed arguments first, followed by anything passed on the command
  line.

## Notes

- Whether a user-supplied flag *overrides* a matching fixed argument (as
  opposed to both being passed and possibly conflicting) depends on how
  your Python script parses arguments. Most `argparse`-based CLIs use
  "last value wins" for repeated flags.
- If `VENV_PATH/bin/activate` or `PYTHON_SCRIPT` doesn't exist, the script
  exits with an error message rather than failing silently.

## License

Add your license of choice here (e.g. MIT).

