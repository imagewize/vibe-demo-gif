#!/usr/bin/env bash
# Rebuild vibe-agent-demo.gif end to end. Run from anywhere: ./build.sh
#   record (VHS tape) -> cut (freeze-aware segments) -> shrink (gifsicle)
# Requirements: vhs, ffmpeg, ffprobe, jq, gifsicle, vibe (with the
# mistral-toolbox skills wired into ~/.vibe, agents linked into ~/.vibe/agents).
#
#   ./build.sh              record, then cut + shrink
#   ./build.sh --cut-only   skip recording, reuse the existing vibe-agent-demo.mp4
#
# The SEGMENTS plan below matches the committed recording. After a fresh
# recording the timings differ — regenerate the plan with:
#   ./mp4-to-gif.sh --detect vibe-agent-demo.mp4
# and rebuild SEGMENTS as alternating activity (speed 1) / frozen (speed 12)
# intervals covering [0, duration], with an empty end on the last segment.
set -euo pipefail
cd "$(dirname "$0")"

SEGMENTS="0.00:2.12:12 2.12:3.72:1 3.72:15.52:12 15.52:17.40:1 17.40:19.60:12 19.60:21.40:1 21.40:80.00:12 80.00:81.12:1 81.12:97.80:12 97.80:99.40:1 99.40:172.12:12 172.12:173.92:1 173.92:182.12:12 182.12:183.60:1 183.60:200.12:12"

if [[ "${1:-}" != "--cut-only" ]]; then
    vhs vibe-agent-demo.tape   # tape Output: vibe-agent-demo.mp4 (this directory)
fi

./mp4-to-gif.sh vibe-agent-demo.mp4 vibe-agent-demo-raw.gif "$SEGMENTS"
gifsicle -O3 --colors 32 --lossy=120 vibe-agent-demo-raw.gif -o vibe-agent-demo.gif
rm -f vibe-agent-demo-raw.gif
echo "wrote vibe-agent-demo.gif"
