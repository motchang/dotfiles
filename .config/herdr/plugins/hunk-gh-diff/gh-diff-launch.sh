#!/usr/bin/env bash
# Local exec-based replacement for Allianaab2m/herdr-hunk-gh-diff: launches
# `hunk` directly in the target pane (via `exec`) instead of leaving a shell
# wrapping it, same trick as ../claude-fork/fork.sh.
set -euo pipefail

target="${1:?usage: gh-diff-launch.sh <split|tab>}"
case "$target" in split|tab) ;; *) echo "invalid target: $target" >&2; exit 1 ;; esac

command -v gh >/dev/null 2>&1 || { echo "gh (GitHub CLI) is required but was not found on PATH." >&2; exit 1; }

ctx="${HERDR_PLUGIN_CONTEXT_JSON:-{}}"
workspace_id=$(jq -r '.workspace_id // empty' <<<"$ctx")
workspace_id="${workspace_id:-${HERDR_WORKSPACE_ID:?missing Herdr workspace id}}"
pane_id=$(jq -r '.focused_pane_id // empty' <<<"$ctx")
pane_id="${pane_id:-${HERDR_PANE_ID:-}}"
cwd=$(jq -r '.focused_pane_cwd // .workspace_cwd // empty' <<<"$ctx")
cwd="${cwd:-$PWD}"

branch=$(git -C "$cwd" branch --show-current || true)

if [ -n "$branch" ]; then
  pr_json=$(gh pr view "$branch" --json baseRefName,number,url 2>/dev/null) || pr_json=""
else
  pr_json=$(gh pr view --json baseRefName,number,url 2>/dev/null) || pr_json=""
fi
if [ -z "$pr_json" ]; then
  echo "No GitHub PR found${branch:+ for branch '$branch'}." >&2
  exit 1
fi

base_name=$(jq -r '.baseRefName // empty' <<<"$pr_json")
pr_number=$(jq -r '.number // empty' <<<"$pr_json")
[ -n "$base_name" ] || { echo "The GitHub PR did not report a base branch." >&2; exit 1; }

base_ref="$base_name"
if git -C "$cwd" rev-parse --verify "origin/$base_name" >/dev/null 2>&1; then
  base_ref="origin/$base_name"
elif ! git -C "$cwd" rev-parse --verify "$base_name" >/dev/null 2>&1; then
  git -C "$cwd" fetch origin "$base_name" >/dev/null 2>&1 || true
  git -C "$cwd" rev-parse --verify "origin/$base_name" >/dev/null 2>&1 && base_ref="origin/$base_name"
fi

head="${branch:-HEAD}"
separator="..."
[ -n "${HUNK_GH_DIFF_TWO_DOT:-}" ] && separator=".."
range="${base_ref}${separator}${head}"

theme_args=(--no-transparent-bg)
[ -n "${HUNK_THEME:-}" ] && theme_args=(--theme "$HUNK_THEME" --no-transparent-bg)

if command -v hunk >/dev/null 2>&1; then
  hunk_cmd=(hunk diff "$range" "${theme_args[@]}")
else
  hunk_cmd=(bunx hunkdiff diff "$range" "${theme_args[@]}")
fi

label="hunk"
[ -n "$pr_number" ] && label="hunk PR#$pr_number"

if [ "$target" = "tab" ]; then
  split_json=$(herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label "$label" --focus)
  hunk_pane=$(jq -r '.result.root_pane.pane_id' <<<"$split_json")
else
  : "${pane_id:?missing focused Herdr pane id}"
  split_json=$(herdr pane split "$pane_id" --direction right --cwd "$cwd" --focus)
  hunk_pane=$(jq -r '.result.pane.pane_id' <<<"$split_json")
fi

herdr pane rename "$hunk_pane" "$label"
herdr pane run "$hunk_pane" exec "${hunk_cmd[@]}"
