Output "/tmp/mistral-demo/vibe-agent-demo.mp4"

Set Shell "bash"
Set FontSize 15
Set Width 1200
Set Height 720
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Framerate 10

Hide
Type "export PS1='demo$ ' && cd ~/code/mistral-toolbox && clear"
Enter
Show

Type "# The toolbox agents, linked into ~/.vibe/agents:"
Enter
Sleep 500ms
Type "ls ~/.vibe/agents"
Sleep 300ms
Enter
Sleep 2s
Type "clear"
Enter
Sleep 500ms

Type "# Review the latest commit with the wp-reviewer agent (it loads the code-review skill on demand):"
Enter
Sleep 500ms
Type "vibe --auto-approve --output streaming --agent wp-reviewer -p 'Review the diff of the latest commit (HEAD) for README.md and CHANGELOG.md only; report severity-ranked findings with file:line.' 2>/dev/null | jq --unbuffered -R -r -f /tmp/mistral-demo/pretty.jq"
Sleep 400ms
Enter
Wait+Line@10m /demo\$/
Sleep 3s
