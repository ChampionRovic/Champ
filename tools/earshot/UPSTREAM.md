# Earshot, pinned copy

This folder is a frozen copy of https://github.com/Leonxlnx/earshot. It is not a submodule and
it does not track upstream. Nothing here changes unless we change it on purpose.

| what | pinned to |
|---|---|
| upstream commit | `4ac3d2ac2b151e1c23376f9ce7f3047a17050013` (release 0.4.1, 2026-11-06) |
| copied on | 2026-11-07, `.git` left out, everything else as-is |
| CLAP model | `laion/larger_clap_general` @ `16c8cc3159a3c8a31e8ff5ef1f66b0d9ab3667db` (pinned in `earshot/config.py`) |
| AudioSet tagger | `MIT/ast-finetuned-audioset-10-10-0.4593` @ `f826b80d28226b62986cc218e5cec390b1096902` (pinned in `earshot/config.py`) |
| Python packages | `../earshot-requirements.lock` (exact versions, CPU torch) |
| model checksums | `../earshot-models.sha256` |

Why: Champ's pipeline uses Earshot to pick real goat bleats out of Donnie's videos and to QC
every post's audio. If upstream renames a tool, changes a default, swaps a model or deletes the
repo, this copy keeps working exactly as it did the day it was tested.

Updating on purpose: clone upstream at the new commit, diff against this folder, copy it over,
regenerate the lock file with `../earshot-setup.sh --relock`, run `earshot doctor --load` and the
bleat test in `../README.md`, then commit with the new commit sha in this table.

Hosts the fetch needs (cloud sessions): huggingface.co, cas-server.xethub.hf.co, cas-bridge.xethub.hf.co,
us.aws.cdn.hf.co, cdn.hf.co, download.pytorch.org, download-r2.pytorch.org. All are already allowed on the
"Zoom Link Check Agent" environment. If Hugging Face ever drops the models, the checksums in
`../earshot-models.sha256` identify the exact files to restore from any backup of `tools/earshot/.cache/hf`.
