# Sounds

The 7 MP3 files here are **procedurally generated** (ffmpeg + Python). They
are scientifically valid for infant sleep / soothing per peer-reviewed criteria
(see `AUDIT.md`), but they are not recordings of named melodies.

| File | What it is |
|------|-----------|
| `lullaby_brahms.mp3` | F-major triad ambient pad |
| `lullaby_wiegenlied.mp3` | G-major triad ambient pad |
| `lullaby_twinkle.mp3` | C-major triad ambient pad |
| `lullaby_jajangga.mp3` | A pentatonic-leaning ambient pad |
| `lullaby_seomjip.mp3` | D-minor pentatonic ambient pad |
| `womb_heartbeat.mp3` | Procedural lub-DUB at 60 BPM (S1 50Hz + S2 70Hz) |
| `womb_flow.mp3` | Brown noise lowpass-filtered to 180Hz |

For Family TestFlight release, these ship as-is.
For public App Store release, see `AUDIT.md` for real-recording sourcing options
(Freesound CC0 + YouTube Audio Library + commission for Korean traditional).

To re-render the heartbeat: see the Python script in commit history under
`/tmp/audio-candidates/`. To re-render the lullaby pads: see the ffmpeg
commands in `git log -p -- App/Resources/Sounds/`.
