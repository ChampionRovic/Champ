#!/usr/bin/env bash
# One-shot install of the pinned Earshot copy in tools/earshot.
#   tools/earshot-setup.sh            install from the lock file, fetch the pinned models, run doctor
#   tools/earshot-setup.sh --relock   (maintainers only) resolve fresh versions and rewrite the lock file
# Needs: uv, ffmpeg. CPU only. Models (~1.1 GB) land in tools/earshot/.cache/hf (gitignored).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/earshot"
VENV="$SRC/.venv"
LOCK="$HERE/earshot-requirements.lock"
PY="$VENV/bin/python"
TORCH_INDEX="https://download.pytorch.org/whl/cpu"

command -v uv >/dev/null || { echo "uv is required (https://docs.astral.sh/uv/)"; exit 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg is required on PATH"; exit 1; }

[ -x "$PY" ] || uv venv --python 3.12 "$VENV"

if [ "${1:-}" = "--relock" ]; then
  uv pip install --python "$PY" torch --index-url "$TORCH_INDEX"
  uv pip install --python "$PY" "$SRC[mcp,dev]"
  # exact versions of everything except earshot itself (installed from this folder, not from PyPI)
  uv pip freeze --python "$PY" | grep -v -i '^-e \|earshot' > "$LOCK"
  echo "wrote $LOCK"
else
  uv pip install --python "$PY" -r "$LOCK" --index-url "$TORCH_INDEX" --extra-index-url https://pypi.org/simple --index-strategy unsafe-best-match
fi
# earshot itself, editable, from this pinned folder; its deps are already satisfied by the lock
uv pip install --python "$PY" --no-deps -e "$SRC"

export EARSHOT_HOME="$SRC/.cache"
"$PY" -m earshot doctor --fetch
# doctor exits 0 even when a download failed: insist on both weight files before going further
WEIGHTS=$(find "$EARSHOT_HOME/hf" -path '*/snapshots/*' -name 'model.safetensors' | wc -l)
[ "$WEIGHTS" -eq 2 ] || { echo "model fetch incomplete ($WEIGHTS of 2 weight files); see doctor output above"; exit 1; }
"$PY" -m earshot doctor --load

# verify the model weights against the recorded checksums (first run writes them)
SUMS="$HERE/earshot-models.sha256"
if [ -s "$SUMS" ]; then
  (cd "$EARSHOT_HOME" && sha256sum -c "$SUMS")
else
  (cd "$EARSHOT_HOME" && find hf -path '*/snapshots/*' \( -name 'model.safetensors' -o -name 'config.json' \) | sort | xargs sha256sum) > "$SUMS"
  echo "wrote $SUMS"
fi
echo "earshot ready: $PY -m earshot <command>"
