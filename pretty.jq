fromjson?
| if .type == "effect" then
    (.detail.display.summary // empty)
  elif .type == "message" and .role == "assistant" then
    (.content | map(.text // empty) | join("\n"))
  else
    empty
  end
