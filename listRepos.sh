#!/usr/bin/env bash
# Regenerate allGits.md from the authenticated GitHub account (public + private).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${SCRIPT_DIR}/allGits.md"

command -v gh >/dev/null || { echo "gh (GitHub CLI) is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "not logged in, run: gh auth login" >&2; exit 1; }

USER="$(gh api user --jq .login)"

DATA="$(gh repo list "$USER" --limit 1000 \
    --json name,isPrivate,isFork,isArchived,description,url,pushedAt,primaryLanguage)"

TOTAL=$(echo "$DATA" | jq 'length')
PUBLIC=$(echo "$DATA" | jq '[.[] | select(.isPrivate==false)] | length')
PRIVATE=$(echo "$DATA" | jq '[.[] | select(.isPrivate==true)] | length')
FORKS=$(echo "$DATA" | jq '[.[] | select(.isFork==true)] | length')

{
    echo "# All GitHub Repositories (${USER})"
    echo
    echo "Generated: $(date +%Y-%m-%d)"
    echo "Total: ${TOTAL} repos — ${PUBLIC} public, ${PRIVATE} private, ${FORKS} forks"
    echo
    echo "| Repo | Visibility | Language | Description | Last Push | URL |"
    echo "|---|---|---|---|---|---|"
    echo "$DATA" | jq -r '
        sort_by(.pushedAt) | reverse | .[] |
        "| " + .name
        + (if .isFork then " (fork)" else "" end)
        + (if .isArchived then " (archived)" else "" end)
        + " | " + (if .isPrivate then "Private" else "Public" end)
        + " | " + (.primaryLanguage.name // "-")
        + " | " + ((.description // "-") | gsub("\\|"; "\\|"))
        + " | " + (.pushedAt[0:10])
        + " | " + .url + " |"
    '
} > "$OUT"

echo "wrote $OUT ($TOTAL repos)" >&2
