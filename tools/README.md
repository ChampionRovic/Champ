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

## Scheduling rules

- Finished clip is pushed to the public repo `ChampionRovic/champ-media` under `posts/`, and Metricool is given the raw GitHub link.
- Providers: Instagram as REEL, TikTok, YouTube as short. Same file to all three.
- AI disclosure flags are always true: `instagramData.isAiGenerated`, `tiktokData.isAigc`, `youtubeData.isAiGeneratedContent`.
- Metricool brand id 7921951, timezone America/Chicago.
- Every video post ships with a cover: a clean frame of Champ's face, exported to `covers/` in champ-media and passed as `videoThumbnailUrl`. Never let the platform pick the cover.
- Encode with a keyframe at frame 0 (compose.sh does this) so a platform that grabs the first frame gets a whole one.

## Ears (Earshot)

Claude cannot hear audio. Earshot (CPU audio models, runs locally) turns a clip into evidence: what it sounds like,
how well it matches "a baby goat bleating", and where in a long video the bleats are. It replaced guessing from
waveforms, which once picked a human giggle as a bleat.

- `tools/earshot/` is a **pinned copy** of upstream, not a live dependency. See `tools/earshot/UPSTREAM.md` for the
  commit, the model revisions and the checksum file. Upstream can change or vanish and nothing here moves.
- `tools/earshot-setup.sh` installs it from `tools/earshot-requirements.lock` (exact versions, CPU torch), fetches
  the two models at their pinned revisions (~1.1 GB, into `tools/earshot/.cache`, gitignored) and verifies them
  against `tools/earshot-models.sha256`. Run it once per machine or fresh cloud session.
- `tools/earshot.sh` is the day-to-day wrapper. It runs fully offline.

```
tools/earshot.sh bleats bleats/*.wav            # rank the bank: real bleats float to the top
tools/earshot.sh find photos/video-014.mp4      # where the bleats are in a raw clip, as cut points
tools/earshot.sh post renders/the-bed-v4.mp4    # listening transcript of a finished post before it ships
```

Rule: a bleat goes into `bleats/` only if Earshot ranks it as a bleat **and** Donnie has heard it. A post ships only
after `tools/earshot.sh post` shows the bleat, then the voice, then music, with nothing clipped.

Thresholds from the first run (Nov 7, 51 clips: the 5 bleats Donnie confirmed plus the raw harvest): every confirmed
bleat scored z +5.2 or better and "sounds most like a cow mooing". The giggle that was once mistaken for a bleat
scored z +3.0 and "sounds most like a vocal chop / people laughing". So: a candidate needs **z >= +5.5 and an
animal as its nearest sound** to be put in front of Donnie. Anything whose nearest sound is laughing, speaking or
music is out without a listen.

Network, cloud sessions only: the one-time model fetch needs these hosts allowed on the environment:
huggingface.co, cas-server.xethub.hf.co, cas-bridge.xethub.hf.co, us.aws.cdn.hf.co, cdn.hf.co; the CPU torch wheel
needs download.pytorch.org and download-r2.pytorch.org. After the fetch, nothing touches the network.
