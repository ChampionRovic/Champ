# Rendering

Every Champ post is a 1080x1920 video with his lines appearing one beat at a time.

- A photo becomes a 9 to 10 second clip: slow push-in, two to four text beats.
- A video gets trimmed to 15 to 20 seconds, cropped to 9:16, two to five text beats.
- Font: DejaVu Sans Bold, white on a soft black band at 70% height.
- Encode: H.264, CRF 24, 30 fps, AAC audio, faststart.

`render-week-1.sh` is the first week's render as run. The reusable renderer that reads a post's beats from its day file is the next step.

## The production format (decided Nov 6)

Every post is a generated 9:16 clip of Champ, not a repurposed phone video.

1. **Scene**: image-to-video, seeded from a real photo of Champ so he stays consistent. minimax-h3, 768p, 8 seconds, 9:16. About 120 vidIQ credits per shot. Prompt always describes his coat exactly and says "no people anywhere in the frame."
2. **Voice**: his lines in the Baby Goat Champ voice from Donnie's ElevenLabs account, settings in `voice.json`. One or two short sentences per clip, under 7 seconds of speech.
3. **Bleat**: a real bleat from Donnie's goats at the top of the clip. Bank lives in the scratch harvest for now; keepers move into the repo once Donnie picks them from the sampler.
4. **Music**: short instrumental bed at -20 dB, faded out.
5. **Text beats**: his lines on screen, one beat at a time, DejaVu Sans Bold on a soft black band at 74% height.

`compose.sh` does steps 2 to 5 given the generated clip, the voice file, the music and a bleat.
