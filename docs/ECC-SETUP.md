# ECC Dev Environment — Setup & Operations

This repo wires up the **ECC** agent-harness toolkit
([github.com/affaan-m/ECC](https://github.com/affaan-m/ECC)) in a reproducible,
reviewable way: pinned dependencies in `package.json`, a vetted setup script in
`scripts/setup-ecc.sh`, and scheduled automation under `.github/workflows/`.

> **Why pinned-install instead of vendored files?** ECC ships 270+ skills plus
> hooks that run shell commands. Rather than copying that whole tree into the
> repo unreviewed, we pin exact versions and install from the verified npm
> channel, so the install is reproducible *and* auditable (`npm why`, lockfile).

## Verified facts (checked against npm + the repo, 2026-06-16)

| Thing | Value |
|---|---|
| `ecc-universal` | `2.0.0` — bins: `ecc`, `ecc-control-pane`, `ecc-install` |
| `ecc-agentshield` | `1.4.0` — bin: `agentshield` |
| `ccg-workflow` | `3.1.5` — bin: `ccg` |
| ECC repo | 216k★ / 33.3k forks / 230+ contributors |
| AgentShield | 1,282 tests, 102 rules, 98% coverage |

> **Gotcha:** there is **no standalone `ecc-install` npm package** — `npm view
> ecc-install` returns 404. The README's `npx ecc-install --profile full` only
> works *after* `ecc-universal` is installed (it exposes an `ecc-install` bin as
> a compat alias). Use `npx ecc …` as the canonical entry point. Always install
> only from the verified channels above; treat re-uploads/mirrors as untrusted.

## 1. Install

Pick **ONE** method. Do **not** stack methods (plugin install *then* the
script) — that creates duplicate skills/commands/hooks.

**Option A — this repo's pinned setup (recommended for reproducibility):**

```bash
npm run setup            # = bash scripts/setup-ecc.sh (read it first)
# or target other stacks:
bash scripts/setup-ecc.sh --target=typescript,python
```

**Option B — ECC plugin marketplace (global, not tracked by this repo):**

```text
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc
```

Note: plugins **cannot** auto-distribute `rules`. Copy the rules you want from
`node_modules/ecc-universal/rules/` into `.claude/rules/` (project) or
`~/.claude/rules/ecc/` (global) yourself. With Claude Code v2.1+, do **not** add
a `"hooks"` field to a plugin manifest — hooks auto-load and a manual entry
causes duplicate-hook errors.

## 2. Multi-agent orchestration

The `/multi-*` commands (`/multi-plan`, `/multi-execute`, `/multi-backend`,
`/multi-frontend`, `/multi-workflow`) are **not** part of the base install. They
need the `ccg-workflow` runtime, which this repo pins:

```bash
npx ccg --help           # orchestration surface
npx ccg init             # scaffold a multi-agent workflow in this project
```

See the ECC v2.0 release notes for the PM2-backed agent fan-out model.

## 3. Scheduled automation (cron / routines)

There are two flavors of "cron" here — pick per use case:

**a) GitHub Actions (lives in this repo, runs on GitHub's schedule).**
Already wired up under `.github/workflows/`:

- `security-scan.yml` — nightly AgentShield scan (`npx agentshield scan .`).
- `dependency-audit.yml` — nightly `npm audit` + outdated report.

Both are safe (no secrets, no external API keys) and run on a daily `cron`.
Adjust the `cron:` expressions to taste. To add a Claude-driven workflow
(e.g. auto-triage), you'd supply your own API key as a repo secret — not
enabled by default.

**b) Claude Code Routines (run on your Claude Code account, not in CI).**
ECC can promote a skill-driven workflow to a Routine that triggers on a
schedule / via API / on a GitHub event. These are configured on the Claude Code
platform tied to your account — they cannot be created from inside a CI job or
an ephemeral container. See https://code.claude.com/docs for routine setup.

## Optional: reduce permission prompts

If you want Claude Code to stop prompting for the ECC commands, add an allowlist
to **your** settings yourself (intentionally not auto-added by this repo):

```jsonc
// .claude/settings.json  ->  permissions.allow
"Bash(npx ecc:*)", "Bash(npx ccg:*)", "Bash(npx agentshield:*)"
```

## Security posture

- Versions are pinned; review changes before bumping.
- `postinstall` for `ecc-universal` is a no-op `echo` (verified) — no hidden
  install-time code execution.
- `node_modules/` is git-ignored; the lockfile is too (regenerate locally) so
  no opaque vendored blobs land in history.
- Run `npm run security:scan` before shipping.
