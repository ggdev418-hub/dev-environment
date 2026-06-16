# Multi-agent orchestration (ccg-workflow)

This documents the multi-agent / multi-model layer pinned in `package.json` as
`ccg-workflow@3.1.5`. It is the runtime behind ECC's `/multi-*` wrappers.

> **Verified vs. uncertain.** Versions, bin name, config location, required
> CLIs, and the `/ccg:*` command list below were checked against the npm
> registry and the upstream repo. The **full `config.toml` field schema is NOT
> publicly documented** — so the example config further down is *illustrative*.
> Generate the authoritative file with `ccg init` / `/ccg:init`; do not assume
> the example field names are exact.

## What it is

`ccg-workflow` ("Claude + Codex + Gemini") makes **Claude Code the orchestrator
and reviewer**, routing **backend** work to the **Codex CLI** and **frontend**
work to the **Gemini CLI**. Source: upstream repo `fengshao1227/ccg-workflow`
(MIT). Distributed on npm as `ccg-workflow`, bin `ccg`.

```
        ┌─────────── Claude Code (orchestrate + review) ───────────┐
        │                                                          │
   Codex CLI  ◀── backend tasks            frontend tasks ──▶  Gemini CLI
```

## Prerequisites

| Tool | Required? | Why |
|---|---|---|
| Claude Code CLI | yes | orchestrator |
| Codex CLI | optional | enables backend fan-out |
| Gemini CLI | optional | enables frontend fan-out |

Without Codex/Gemini installed and authenticated, the multi-model routing is
inert — Claude still runs, but there is nothing to delegate to.

## Setup

1. Install the pinned runtime (see [ECC-SETUP.md](ECC-SETUP.md) §1 — gated as
   untrusted-code integration; run it yourself):

   ```bash
   npm run setup            # installs ccg-workflow among the pinned deps
   ```

2. Generate the authoritative config (this writes `~/.claude/.ccg/config.toml`):

   ```bash
   npx ccg init             # or the /ccg:init slash command inside Claude Code
   ```

3. Install + authenticate the Codex and Gemini CLIs if you want true
   multi-model routing.

## Commands

`ccg-workflow` v3 ships ~13 `/ccg:*` slash commands. Verified subset:

| Command | Purpose |
|---|---|
| `/ccg:go` | Describe intent in plain language; engine picks the strategy |
| `/ccg:init` | Initialize project `CLAUDE.md` / config |
| `/ccg:context` | Project context management |
| `/ccg:commit` | Smart conventional commit |
| `/ccg:rollback` | Interactive rollback |
| `/ccg:worktree` | Worktree management |
| `/ccg:clean-branches` | Clean merged branches |
| `/ccg:spec-init` | Initialize the OpenSpec (OPSX) environment |
| `/ccg:spec-research` | Requirements → constraints |
| `/ccg:spec-plan` | Constraints → plan (saved under `.claude/plan/`) |
| `/ccg:spec-impl` | Execute plan + archive |
| `/ccg:spec-review` | Dual-model cross-review |

ECC additionally exposes `/multi-plan`, `/multi-execute`, `/multi-backend`,
`/multi-frontend`, `/multi-workflow` as higher-level wrappers over this runtime.

## Config (ILLUSTRATIVE — generate the real one with `ccg init`)

Location: `~/.claude/.ccg/config.toml`. The upstream docs confirm sections for
**model routing**, **MCP**, and **performance**, but not exact field names. Treat
this as a shape sketch only:

```toml
# ~/.claude/.ccg/config.toml  — ILLUSTRATIVE, not authoritative.
# Run `ccg init` to generate the real file, then edit that.

[routing]
# which model handles which kind of work
backend  = "codex"
frontend = "gemini"
review   = "claude"

[performance]
# tune timeouts / concurrency to taste

[mcp]
# MCP tool wiring
```

Some related knobs are set in `~/.claude/settings.json` under `"env"` rather
than in `config.toml`, e.g. `CODEX_TIMEOUT`,
`CODEAGENT_POST_MESSAGE_DELAY`, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`.

## Why this is docs-only in this repo

The config is global (`~/.claude/.ccg/`), so it can't be committed as a working
project file, and it's ephemeral in a remote container. `ccg init` is also
behind the install gate. So the durable, correct deliverable here is this guide
plus the pinned version — not a fabricated config that might not load.

## Sources

- npm: `ccg-workflow@3.1.5`
- upstream: https://github.com/fengshao1227/ccg-workflow
- ECC: https://github.com/affaan-m/ECC
