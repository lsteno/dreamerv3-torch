#!/bin/bash
# SLURM script for launching DreamerV3 training on a GPU node.

#SBATCH --job-name=dreamer_v3
#SBATCH --output=logs/dreamer_%j.out
#SBATCH --error=logs/dreamer_%j.err
#SBATCH --partition=students
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --ntasks=1

set -euo pipefail

# --- Modules ---------------------------------------------------------------
# Adjust the Python module to match what's available on your cluster.
module load python/3.11 || module load python/3.10.7 || true

# --- User configuration ----------------------------------------------------
# Update these to match your cluster environment before submitting.

PROJECT_ROOT="${PROJECT_ROOT:-$SLURM_SUBMIT_DIR}"
VENV_DIR="${VENV_DIR:-$PROJECT_ROOT/venv}"
CONFIG_NAME="${CONFIG_NAME:-dmc_vision}"
TASK_NAME="${TASK_NAME:-dmc_walker_walk}"
LOGDIR="${LOGDIR:-$PROJECT_ROOT/logdir/${TASK_NAME}}"

# --- Environment bootstrap -------------------------------------------------
if [ ! -d "$VENV_DIR" ]; then
  echo "Virtual environment not found at $VENV_DIR" >&2
  echo "Create one with: python -m venv $VENV_DIR && source $VENV_DIR/bin/activate && pip install -r requirements.txt" >&2
  exit 1
fi

cd "$PROJECT_ROOT"
source "$VENV_DIR/bin/activate"
export PYTHONPATH="$SLURM_SUBMIT_DIR:${PYTHONPATH:-}"

# Ensure log directories exist (Slurm needs 'logs' present at submit time).
mkdir -p "$PROJECT_ROOT/logs" "$LOGDIR"

# Uncomment if your run needs extra assets (Atari ROMs, Minecraft data, etc.).
# bash envs/setup_scripts/atari.sh
# bash envs/setup_scripts/minecraft.sh

python3 dreamer.py \
  --configs "$CONFIG_NAME" \
  --task "$TASK_NAME" \
  --logdir "$LOGDIR"
