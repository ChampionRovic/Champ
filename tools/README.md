# Rendering

Every Champ post is a 1080x1920 video with his lines appearing one beat at a time.

- A photo becomes a 9 to 10 second clip: slow push-in, two to four text beats.
- A video gets trimmed to 15 to 20 seconds, cropped to 9:16, two to five text beats.
- Font: DejaVu Sans Bold, white on a soft black band at 70% height.
- Encode: H.264, CRF 24, 30 fps, AAC audio, faststart.

`render-week-1.sh` is the first week's render as run. The reusable renderer that reads a post's beats from its day file is the next step.
