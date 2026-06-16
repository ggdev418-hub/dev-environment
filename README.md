# dev-environment

A reproducible developer environment wired to the **ECC** agent-harness toolkit
([github.com/affaan-m/ECC](https://github.com/affaan-m/ECC)) — skills, multi-agent
orchestration, and scheduled automation.

## Quick start

```bash
npm run setup        # reads scripts/setup-ecc.sh — review it first
```

| Capability | Command | Backed by |
|---|---|---|
| Skills / commands | `npx ecc --help` | `ecc-universal@2.0.0` |
| Multi-agent (`/multi-*`) | `npx ccg --help` | `ccg-workflow@3.1.5` |
| Security scan | `npm run security:scan` | `ecc-agentshield@1.4.0` |

Scheduled automation (nightly) runs via GitHub Actions in
[`.github/workflows/`](.github/workflows).

Full setup, gotchas, and security notes: **[docs/ECC-SETUP.md](docs/ECC-SETUP.md)**.

## Notes

- Dependencies are **pinned** and installed from the verified npm channel;
  `node_modules/` is git-ignored. Nothing is auto-installed — you run `setup`.
- There is no standalone `ecc-install` npm package; use `npx ecc`. See docs.
- Don't stack install methods (plugin install **and** the script) — pick one.
