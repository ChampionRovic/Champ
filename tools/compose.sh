#!/bin/bash
# compose.sh <video.mp4> <voice.mp3> <music.mp3> <bleat.wav> <out.mp4> "<beat text|start|end>"...
# Generated clip + Champ's voice + a bleat at the start + music bed + text beats.
set -u
V=$1; VO=$2; M=$3; B=$4; OUT=$5; shift 5
F=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
T="drawtext=fontfile=$F:fontcolor=white:fontsize=60:line_spacing=10:box=1:boxcolor=black@0.5:boxborderw=22:x=(w-text_w)/2:y=h*0.74"
beats=""; for b in "$@"; do IFS='|' read -r txt a z <<<"$b"; txt=$(printf '%b' "$txt"); beats="$beats,$T:text='$txt':enable='between(t,$a,$z)'"; done
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V")
fade=$(python3 -c "print(max(0,float('$dur')-1.2))")
# audio: bleat at 0.2s, voice from 0.9s, music low throughout
ffmpeg -nostdin -v error -y -i "$V" -i "$VO" -i "$M" -i "$B" -filter_complex \
 "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920$beats[v];
  [3:a]adelay=200|200,volume=-2dB[bl];
  [1:a]adelay=900|900,volume=0dB[vo];
  [2:a]volume=-20dB,afade=t=in:d=0.4,afade=t=out:st=$fade:d=1.2[m];
  [bl][vo][m]amix=inputs=3:duration=first:dropout_transition=0:normalize=0[a]" \
 -map "[v]" -map "[a]" -t "$dur" -r 30 -c:v libx264 -preset fast -crf 22 -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart "$OUT"
