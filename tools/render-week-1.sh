#!/bin/bash
# Champ clip renderer. Every post becomes a 1080x1920 mp4 with text beats.
set -u
S="$1"; P=/home/user/champ/photos; F=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
cd "$S"
T="drawtext=fontfile=$F:fontcolor=white:fontsize=62:line_spacing=12:box=1:boxcolor=black@0.55:boxborderw=24:x=(w-text_w)/2:y=h*0.70"
beats(){ # args: "text|start|end" ...
  local out=""; for b in "$@"; do IFS='|' read -r txt a z <<<"$b"; txt=$(printf '%b' "$txt"); out="$out,$T:text='$txt':enable='between(t,$a,$z)'"; done; echo "$out"; }
photo_clip(){ # src out seconds beats...
  local src=$1 out=$2 sec=$3; shift 3; local frames=$((sec*30))
  convert "$P/$src" -auto-orient -resize 1620x -gravity center -crop 1620x2880+0+0 +repage /tmp/claude-0/pc.jpg
  ffmpeg -v error -y -loop 1 -i /tmp/claude-0/pc.jpg -vf "zoompan=z='min(zoom+0.0005,1.14)':d=$frames:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30$(beats "$@")" \
    -t $sec -c:v libx264 -preset fast -crf 24 -pix_fmt yuv420p -movflags +faststart "$out"
}
video_clip(){ # src out start seconds beats...
  local src=$1 out=$2 ss=$3 sec=$4; shift 4
  ffmpeg -v error -y -ss $ss -t $sec -i "$src" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920$(beats "$@")" \
    -r 30 -c:v libx264 -preset fast -crf 24 -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart "$out"
}
photo_clip album-038.jpg 01-sunday.mp4 9 "Sundays are mine.|0.3|3.2" "Elizabeth agrees.|3.5|5.8" "Donnie is in the house\ntalking to the rectangle.|6.1|9"
photo_clip album-001.jpg 02-trampoline.mp4 10 "The big white dog\nis a trampoline.|0.3|3" "I bounced off him\neleven times today.|3.3|5.8" "He looked at Elizabeth\nfor help.|6.1|8" "She kept drinking\nher coffee.|8.3|10"
video_clip "$S/../mock/ghost.mp4" 03-ghost.mp4 0 19.5 "This is the big white dog.|0.3|3.5" "They call him Ghost.|3.8|6.8" "I can see him.\nThat is not a ghost.|7.1|10.5" "The man is Donnie.\nHe owes me rent.|10.8|15.6" "This is Elizabeth.\nShe does not.|16|19.5"
photo_clip album-030.jpg 04-bed.mp4 9 "There are four troughs.|0.3|2.6" "This one is the bed.|2.9|5" "Elizabeth says\nit is not the bed.|5.3|7.3" "It is the bed.|7.6|9"
video_clip "$S/../mock/sweater.mp4" 05-sweater.mp4 3 15 "One of us is in a sweater.|0.3|4" "Nobody asked me.|4.3|7.3" "I inspected it. It is red.\nIt has dots.|7.6|11.3" "It can stay.|11.6|15"
ls -la *.mp4 | awk '{print $5, $9}'
for f in 01 02 03 04 05; do ffmpeg -v error -y -ss 2 -i $f-*.mp4 -frames:v 1 -vf scale=360:-2 p_$f.jpg; done
montage -label '%f' p_01.jpg p_02.jpg p_03.jpg p_04.jpg p_05.jpg -tile 5x -geometry 360x640+4+4 -background '#222' -fill white -pointsize 20 preview.png && convert preview.png -quality 85 preview.jpg
