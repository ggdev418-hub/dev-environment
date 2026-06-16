#!/usr/bin/env bash
#
# setup-ecc.sh — one-shot, idempotent setup for the ECC agent-harness toolkit.
#
# Review this script before running it. It installs PINNED versions of three
# packages from the npm registry and then applies ECC's config into this
# project. It does NOT modify your global ~/.claude unless you pass --global.
#
# Packages (verified on npmjs.org, see docs/ECC-SETUP.md):
#   ecc-universal   2.0.0   (skills, commands, rules)   bin: ecc, ecc-install
#   ccg-workflow    3.1.5   (multi-agent orchestration) bin: ccg
#   ecc-agentshield 1.4.0   (security scanner)          bin: agentshield
#
# NOTE: there is NO standalone `ecc-install` npm package. The README command
# `npx ecc-install` only works AFTER `ecc-universal` is installed (it exposes
# an `ecc-install` bin as a compat alias). The canonical command is `npx ecc`.

set -euo pipefail

SCOPE="project"
TARGETS=("typescript")

for arg in "$@"; do
  case "$arg" in
    --global) SCOPE="global" ;;
    --target=*) IFS=',' read -r -a TARGETS <<< "${arg#*=}" ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

echo "==> Checking toolchain"
command -v node >/dev/null || { echo "node is required (>=20)"; exit 1; }
command -v npm  >/dev/null || { echo "npm is required";        exit 1; }
echo "    node $(node -v), npm $(npm -v)"

echo "==> Installing pinned dependencies (postinstall is a no-op echo)"
npm install

echo "==> Applying ECC config for targets: ${TARGETS[*]} (scope: $SCOPE)"
# IMPORTANT: do not stack install methods. If you previously ran
# `/plugin install ecc@ecc`, do NOT also run this — it creates duplicate
# skills/commands. Pick ONE install method and stick with it.
if [ "$SCOPE" = "global" ]; then
  npx ecc "${TARGETS[@]}"
else
  # Apply into this project only.
  npx ecc "${TARGETS[@]}" --target project || npx ecc "${TARGETS[@]}"
fi

# Claude Code plugins cannot distribute `rules` automatically. If a rules/
# directory was produced, surface where to copy it.
if [ -d node_modules/ecc-universal/rules ]; then
  echo "==> ECC ships rules at node_modules/ecc-universal/rules"
  echo "    Copy the ones you want into .claude/rules/ (project) or"
  echo "    ~/.claude/rules/ecc/ (global). They are NOT auto-installed."
fi

echo "==> Done. Try:"
echo "    npx ecc --help            # skills/commands surface"
echo "    npx ccg --help            # multi-agent orchestration (/multi-*)"
echo "    npx agentshield scan .    # security scan (1282 tests, 102 rules)"
