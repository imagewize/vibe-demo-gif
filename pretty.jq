# vibe --output streaming emits one JSON event per line (NDJSON) on stdout.
# Print a readable transcript: tool-call summaries + assistant messages.
# `fromjson` (no `?`) so a non-JSON line aborts loudly instead of vanishing.
def astext($c):
  if ($c | type) == "array" then ($c | map(.text? // empty) | join("\n"))
  else ($c | tostring) end;

fromjson
| if .type == "effect" then
    (.detail.display.summary // empty)
  elif .type == "message" and .role == "assistant" then
    astext(.content)
  else
    empty
  end
