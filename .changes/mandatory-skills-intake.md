---
bump: patch
category: Internal
---

`AGENTS.md` now gates work behind mandatory first steps: bootstrap the toolchain, resolve the shared skills path, and read the skills index in full before writing anything. It also requires passing that bootstrap and the relevant `SKILL.md` paths to any subagent, since subagents do not inherit the guide.
