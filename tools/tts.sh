#!/usr/bin/env bash
# tts.sh <out.mp3> "<line>" ["<line>"...]  one ElevenLabs call per line, joined with 0.45 s gaps, 1.2 s before the last line
set -euo pipefail
out="$1"; shift
VOICE=rlf1aTZty7nlLCXR98af
rm -f part_*.mp3 parts.txt
n=0; total=$#
for line in "$@"; do
  n=$((n+1))
  jq -n --arg t "$line" '{text:$t, model_id:"eleven_multilingual_v2", voice_settings:{stability:0.90,similarity_boost:0.90,style:0.0,speed:0.85}}' > body.json
  code=$(curl -sS -o part_$n.mp3 -w '%{http_code}' -X POST "https://api.elevenlabs.io/v1/text-to-speech/$VOICE?output_format=mp3_44100_128" -H "xi-api-key: proxy-injected" -H "Content-Type: application/json" --data @body.json)
  [ "$code" = 200 ] || { echo "elevenlabs $code: $(head -c 300 part_$n.mp3)"; exit 1; }
  gap=0.45; [ $n -eq $((total-1)) ] && gap=1.2; [ $n -eq $total ] && gap=0
  ffmpeg -nostdin -loglevel error -y -i part_$n.mp3 -af "apad=pad_dur=$gap" -ar 44100 part_$n.wav
  echo "file 'part_$n.wav'" >> parts.txt
done
ffmpeg -nostdin -loglevel error -y -f concat -safe 0 -i parts.txt -c:a libmp3lame -q:a 2 "$out"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$out"
