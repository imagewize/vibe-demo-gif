# vibe-demo-gif

How the animated README GIF in
[imagewize/mistral-toolbox](https://github.com/imagewize/mistral-toolbox) was made:
a terminal recording of a Mistral Vibe **agent using skills**, cut down to a small GIF.

Result (committed to mistral-toolbox as `docs/assets/vibe-agent-demo.gif`, commit `c101f89`):

![vibe --agent wp-reviewer reviewing the latest commit in mistral-toolbox](vibe-agent-demo.gif)

- 800px wide, 27s, 1.7 MB, 10 fps, 32 colors
- Shows `vibe --agent wp-reviewer` in `~/code/mistral-toolbox` reviewing the latest commit:
  the agent loads the `code-review` skill on demand (`Loading skill: code-review`), runs git /
  grep checks, and ends with an `OVERALL ASSESSMENT: Approve` report with `file:line` findings

## Pipeline

```
VHS tape ──vhs──> demo.mp4 ──mp4-to-gif.sh --detect──> freeze list
                                            │
   segments "start:end:speed" (freezes 12x) │
                                            ▼
                              mp4-to-gif.sh ──> raw.gif (ffmpeg trim/setpts/concat/palette)
                                            │
                              gifsicle -O3 --colors 32 --lossy=120
                                            ▼
                                       demo.gif
```

1. **Record** with [VHS](https://github.com/charmbracelet/vhs) (brew-installed, 0.12.1):
   `vhs vibe-agent-demo.tape` → `vibe-agent-demo.mp4` (1200x720, Catppuccin Mocha, 10 fps).
   The tape types real commands in a PTY; see `vibe-agent-demo.tape`.
2. **Find frozen stretches**: `./mp4-to-gif.sh --detect demo.mp4` lists `freeze_start/end`
   pairs (2s+ of no screen change — the agent waiting on tool calls).
3. **Cut**: `./mp4-to-gif.sh demo.mp4 out.gif "0:2.12:12 2.12:3.72:1 … 183.6::12"` —
   `start:end:speed` segments, activity at 1x, freezes at 12x, empty end = run to the end.
   (`mp4-to-gif.sh` is an unmodified copy of `~/code/seo-strategy/scripts/mp4-to-gif.sh`.)
4. **Shrink**: `gifsicle -O3 --colors 32 --lossy=120 raw.gif -o demo.gif` (4.0 MB → 1.7 MB).

The recorded vibe command (see the tape):

```bash
vibe --auto-approve --output streaming --agent wp-reviewer -p 'Review the diff of the latest commit (HEAD) for README.md and CHANGELOG.md only; report severity-ranked findings with file:line.' 2>/dev/null | jq --unbuffered -R -r -f pretty.jq
```

`pretty.jq` turns the `--output streaming` NDJSON events into readable terminal text:
`effect` events print the tool summary (`Loading skill: code-review`, `bash: git diff …`),
assistant `message` events print the narration and the final report.

## Gotchas (learned the hard way, VHS 0.12.1 + vibe 3.1.0)

- **`Type` interpolates `$VAR`** in tape strings — `"$HOME/..."` fails with
  `Invalid command: HOME/...`. Use single-quoted shell args inside the double-quoted
  `Type` string; a bare `$ ` (as in `PS1='$ '`) is safe.
- **Wait regex needs a single backslash**: `/^\$$/` in the tape is passed through literally
  and never matches. Use `/^\$$/` in the file (one backslash). A trailing space in the
  captured prompt line also breaks end-anchored patterns — safer to set a unique prompt
  (`export PS1='demo$ '`) and wait for `/demo\$/`.
- **Don't `Wait+Line` inside the interactive TUI**: it uses an alternate screen, so Wait
  only sees the footer, never the scrolled report. Record headless (`-p`), not the TUI.
- **`vibe -p` (text mode) buffers everything until exit** — the recording is one static
  screen, then the whole answer at once. Use `--output streaming` (NDJSON) piped through
  `jq --unbuffered -R -r -f pretty.jq`; add `2>/dev/null` to hide MCP-connection noise.
- **Headless `-p` denies tool calls without approval** ("Tool execution denied by approval
  callback") — add `--auto-approve` (the demo repo dir is in `~/.vibe/trusted_folders.toml`,
  but headless still skips the callback without the flag).
- **Segment math**: merge freeze intervals with gaps < 1s, alternate activity (speed 1) /
  freeze (speed ~12) over `[0, duration]`, leave the last segment's end empty.
  200s recording → 27s GIF.

## Alternatives

- **asciinema + agg** (`brew install asciinema agg`): `asciinema rec demo.cast` then
  `agg demo.cast demo.gif`. Same caveat as above: `vibe -p` text mode buffers, so record an
  interactive session or the streaming+jq pipe.
- **Webpage animations** (not terminal): headless-Chrome recorder
  `~/code/architect-demo/scripts/demo-gif.rec.mjs` — drives Chrome over the DevTools
  protocol, captures frames on a scroll timeline, encodes with ffmpeg concat → gifski →
  `gifsicle -O3 --colors 32 --lossy=30`. That is how `architect-demo/images/demo.gif`
  (the Bureau Kadewerk homepage recording) was made.

## Files

- `vibe-agent-demo.tape` — the VHS tape that produced the recording
- `pretty.jq` — NDJSON → readable text filter for `vibe --output streaming`
- `mp4-to-gif.sh` — unmodified copy of the seo-strategy converter (detect + segments)
- `vibe-agent-demo.gif` — the final GIF (as embedded in the mistral-toolbox README)
