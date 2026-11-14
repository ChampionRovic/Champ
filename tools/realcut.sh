#!/bin/bash
# realcut.sh <source.mp4> <start> <end> <music.mp3|none> <out.mp4> "<beat text|start|end>"...
# Real farm footage, cut to 9:16, Champ's lines as text beats, the clip's OWN audio (real bleats) on top,
# a music bed under it. No synthetic voice. Beat times are relative to the cut (0 = <start>).
set -u
SRC=$1; A=$2; Z=$3; M=$4; OUT=$5; shift 5
F=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
T="drawtext=fontfile=$F:fontcolor=white:fontsize=64:line_spacing=10:box=1:boxcolor=black@0.55:boxborderw=24:x=(w-text_w)/2:y=h*0.70"
beats=""; for b in "$@"; do IFS='|' read -r txt s e <<<"$b"; txt=$(printf '%b' "$txt"); beats="$beats,$T:text='$txt':enable='between(t,$s,$e)'"; done
dur=$(python3 -c "print(float('$Z')-float('$A'))")
fade=$(python3 -c "print(max(0,float('$dur')-1.0))")
if [ "$M" = none ]; then
  ffmpeg -nostdin -v error -y -ss "$A" -t "$dur" -i "$SRC" -filter_complex \
   "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1$beats[v];
    [0:a]anull[a]" \
   -map "[v]" -map "[a]" -r 30 -c:v libx264 -preset fast -crf 21 -pix_fmt yuv420p -x264-params keyint=30:min-keyint=30:scenecut=0 -force_key_frames 0 -c:a aac -b:a 160k -movflags +faststart "$OUT"
else
  ffmpeg -nostdin -v error -y -ss "$A" -t "$dur" -i "$SRC" -i "$M" -filter_complex \
   "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1$beats[v];
    [0:a]loudnorm=I=-16:TP=-2:LRA=9[nat];
    [1:a]volume=-16dB,afade=t=in:d=0.3,afade=t=out:st=$fade:d=1.0[m];
    [nat][m]amix=inputs=2:duration=longest:dropout_transition=0:normalize=0[a]" \
   -map "[v]" -map "[a]" -t "$dur" -r 30 -c:v libx264 -preset fast -crf 21 -pix_fmt yuv420p -x264-params keyint=30:min-keyint=30:scenecut=0 -force_key_frames 0 -c:a aac -b:a 160k -movflags +faststart "$OUT"
fi

# second pass: measure the mix, then normalize it to -14 LUFS / -1.5 dBTP with the measured values (accurate on short clips)
J=$(ffmpeg -nostdin -i "$OUT" -af "acompressor=threshold=-22dB:ratio=3:attack=8:release=120:makeup=4dB,loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json" -f null - 2>&1 | sed -n '/^{/,/^}/p')
read -r II TP LRA TH < <(python3 -c "import json,sys; d=json.loads(sys.argv[1]); print(d['input_i'], d['input_tp'], d['input_lra'], d['input_thresh'])" "$J")
TMP="${OUT%.mp4}.tmp.mp4"
ffmpeg -nostdin -v error -y -i "$OUT" -c:v copy -af "acompressor=threshold=-22dB:ratio=3:attack=8:release=120:makeup=4dB,loudnorm=I=-14:TP=-1.5:LRA=11:measured_I=$II:measured_TP=$TP:measured_LRA=$LRA:measured_thresh=$TH:linear=true,alimiter=limit=0.89:level=false" -c:a aac -b:a 160k -movflags +faststart "$TMP" && mv "$TMP" "$OUT"
