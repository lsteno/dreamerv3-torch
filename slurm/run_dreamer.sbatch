#!/bin/bash
# Example SLURM script for launching DreamerV3 training on a GPU node.

#SBATCH --job-name=dreamer_dmc
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=slurm-%x-%j.out

set -euo pipefail

# --- User configuration ----------------------------------------------------
# Update these to match your cluster environment before submitting.
module purge
module load python/3.11

VENV_DIR="${VENV_DIR:-$HOME/venvs/dreamerv3}"  # Override when needed
CONFIG_NAME="${CONFIG_NAME:-dmc_vision}"
TASK_NAME="${TASK_NAME:-dmc_walker_walk}"
LOGDIR="${LOGDIR:-logdir/${TASK_NAME}}"

# --- Environment bootstrap -------------------------------------------------
if [ ! -d "$VENV_DIR" ]; then
  echo "Virtual environment not found at $VENV_DIR" >&2
  echo "Create one with: python -m venv $VENV_DIR && source $VENV_DIR/bin/activate && pip install -r requirements.txt" >&2
  exit 1
fi

source "$VENV_DIR/bin/activate"
cd "$SLURM_SUBMIT_DIR"
export PYTHONPATH="$SLURM_SUBMIT_DIR:${PYTHONPATH:-}"

mkdir -p "$LOGDIR"

# Uncomment if your run needs extra assets (Atari ROMs, Minecraft data, etc.).
# bash envs/setup_scripts/atari.sh
# bash envs/setup_scripts/minecraft.sh

srun python dreamer.py \
  --configs "$CONFIG_NAME" \
  --task "$TASK_NAME" \
  --logdir "$LOGDIR"
