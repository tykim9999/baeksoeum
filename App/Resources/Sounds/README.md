# Sounds

These are **placeholder ambient tones** generated procedurally with ffmpeg. They make the audio pipeline work end-to-end in development but are NOT production-quality lullabies.

## Replacement before ship

Source real CC0 audio from one of:

| Source | License | URL |
|--------|---------|-----|
| Pixabay Music | CC0 (no attribution) | https://pixabay.com/music/ |
| Freesound.org | filter to CC0 only | https://freesound.org/?f=license:%22Creative+Commons+0%22 |
| Public domain Korean lullabies (folk songs >70yr) | PD | National Folk Museum / Korean Music Research Institute |

Naming must match `LullabyCatalog.swift`:

- `lullaby_brahms.mp3` -- Brahms's Wiegenlied
- `lullaby_wiegenlied.mp3` -- Mozart's Wiegenlied (alt)
- `lullaby_twinkle.mp3` -- Twinkle Twinkle Little Star
- `lullaby_jajangga.mp3` -- Korean traditional 자장가
- `lullaby_seomjip.mp3` -- 섬집아기 (folk lullaby)
- `womb_heartbeat.mp3` -- maternal heartbeat at ~60bpm
- `womb_flow.mp3` -- amniotic fluid flow

Format: mono, 44.1kHz, 96+ kbps MP3. 30-90s loop length recommended (we play with `numberOfLoops = -1`).

## Re-generate placeholders

```bash
ffmpeg -y -f lavfi -i "sine=frequency=220:duration=30" -af "tremolo=f=0.4:d=0.3,volume=0.4" -ac 1 -ar 44100 -b:a 96k lullaby_brahms.mp3
# etc. -- see git history for full commands
```
