@AGENTS.md

# Claude-specific routing

The shared skills this repo depends on live under `~/.loom/store/AgentSkills@<version>/src/<scope>/<name>/SKILL.md`, not in `.claude/skills/`, so they are **not** auto-surfaced by the Skill tool. Route yourself: run `lute run install` first, then when a task matches a trigger in the library's Project Skills index (see AGENTS.md above for the path), read that `SKILL.md` before working.
