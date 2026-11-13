# Week 2 queue (Nov 15 to 21)

Week 1 slipped: only "the bed" went out (Nov 6). The Nov 8, 10 and 12 slots were missed because the production
format was still being settled. These three are the next posts, in the production format (generated scene, Champ's
ElevenLabs voice, real bleat, music bed, text beats, cover, AI flags on). Voice is already recorded in `voice/`.

## 1. Sunday, Nov 15 — Sundays are mine  #BabyGoatSunday

**Scene (to generate, seedance-2 720p, 280 cr):** Champ alone in the pasture by the farmhouse, facing the house,
mid-bleat, morning light. No people anywhere. The house is in the background with a window.
**Voice:** `voice/2026-11-15-sunday.mp3` (10.8 s)

> Sundays are mine. Donnie is in the house, talking to the rectangle. That is not a Sunday activity. I will be screaming about this until lunch. #BabyGoatSunday

## 2. Tuesday, Nov 17 — the trampoline (Champ's recorded day one)

**Scene:** reuse `renders/2026-11-06-trampoline-scene-seedance.mp4` (already paid for, 1080p). Champ bouncing
off sleeping Ghost in the pasture.
**Voice:** `voice/2026-11-17-trampoline.mp3` (13.5 s)

> The big white dog is the best trampoline on the farm. I bounced off him eleven times today. He looked at Elizabeth for help. She kept drinking her coffee. I like Elizabeth.

## 3. Thursday, Nov 19 — the sweater

**Scene (to generate, 280 cr):** two kids in the barn, one in a red sweater with white dots. Champ (dark
chocolate, tan legs, white dot between the ears) walks up and sniffs the sweater. No people.
**Voice:** `voice/2026-11-19-sweater.mp3` (8.6 s)

> One of us is in a sweater. Nobody asked me. I inspected it. It is red. It has dots. It can stay.

## Ship checklist, every post

1. Scene generated and watched frame by frame: Champ's coat right, no people, no hurt animals.
2. `tools/compose.sh` with a Donnie-confirmed bleat from `bleats/`.
3. `tools/earshot.sh post out.mp4`: bleat shows up near the top, voice events after it, nothing clipped,
   true peak at or under -1 dBTP.
4. Cover frame exported to champ-media `covers/`.
5. Pushed to champ-media `posts/`, scheduled in Metricool as Reel + TikTok + Short with all three AI flags true
   and `videoThumbnailUrl` set. Time: Donnie's wake-up hour, still a placeholder at 16:00 Central.
