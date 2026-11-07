#!/usr/bin/env bash
# Champ's ears. Thin wrapper over the pinned Earshot in tools/earshot (install: tools/earshot-setup.sh).
#   tools/earshot.sh bleats FILES|DIR...     rank candidate clips: which ones are actually a baby goat bleating
#   tools/earshot.sh find VIDEO [--top N]    best bleat moments inside a long clip (start/end seconds to cut)
#   tools/earshot.sh post POST.mp4           second-by-second listening transcript of a finished post (audio QC)
#   tools/earshot.sh <any earshot command>   passthrough (describe, match, timeline, doctor, mcp ...)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PY="$HERE/earshot/.venv/bin/python"
[ -x "$PY" ] || { echo "run tools/earshot-setup.sh first"; exit 1; }
export EARSHOT_HOME="$HERE/earshot/.cache"
export EARSHOT_OFFLINE=1          # never touch the network at run time; models are already in the cache
export EARSHOT_THREADS="${EARSHOT_THREADS:-3}"
BLEAT="a baby goat bleating"
case "${1:-}" in
  bleats) shift; exec "$PY" -m earshot rank "$BLEAT" "$@" ;;
  find)   shift; f="$1"; shift; exec "$PY" -m earshot find "$f" "$BLEAT" --kind event "$@" ;;
  post)   shift; exec "$PY" -m earshot timeline "$@" ;;
  *)      exec "$PY" -m earshot "$@" ;;
esac
