#!/usr/bin/env bash
# Local exec-based replacement for edmundmiller/herdr-plugin-hunk: launches
# `hunk` directly in the target pane (via `exec`) instead of leaving a shell
# wrapping it, same trick as ../claude-fork/fork.sh.
set -euo pipefail

mode="${1:?usage: hunk-launch.sh <worktree|staged|branch> <split|tab>}"
target="${2:?usage: hunk-launch.sh <worktree|staged|branch> <split|tab>}"

case "$mode" in worktree|staged|branch) ;; *) echo "invalid mode: $mode" >&2; exit 1 ;; esac
case "$target" in split|tab) ;; *) echo "invalid target: $target" >&2; exit 1 ;; esac

ctx="${HERDR_PLUGIN_CONTEXT_JSON:-{}}"
workspace_id=$(jq -r '.workspace_id // empty' <<<"$ctx")
workspace_id="${workspace_id:-${HERDR_WORKSPACE_ID:?missing Herdr workspace id}}"
pane_id=$(jq -r '.focused_pane_id // empty' <<<"$ctx")
pane_id="${pane_id:-${HERDR_PANE_ID:-}}"
cwd=$(jq -r '.focused_pane_cwd // .workspace_cwd // empty' <<<"$ctx")
cwd="${cwd:-$PWD}"

case "$mode" in
  staged)
    diff_args=(diff --staged)
    ;;
  branch)
    branch=$(git -C "$cwd" branch --show-current || true)
    branch="${branch:-HEAD}"
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
    if [ -z "$upstream" ]; then
      for candidate in origin/main origin/master main master; do
        if git -C "$cwd" rev-parse --verify "$candidate" >/dev/null 2>&1; then
          upstream="$candidate"
          break
        fi
      done
      upstream="${upstream:-origin/main}"
    fi
    diff_args=(diff "${upstream}..${branch}")
    ;;
  *)
    diff_args=(diff)
    ;;
esac

theme_args=(--no-transparent-bg)
if [ -n "${HUNK_THEME:-}" ]; then
  theme_args=(--theme "$HUNK_THEME" --no-transparent-bg)
fi

if command -v hunk >/dev/null 2>&1; then
  hunk_cmd=(hunk "${diff_args[@]}" "${theme_args[@]}")
else
  hunk_cmd=(bunx hunkdiff "${diff_args[@]}" "${theme_args[@]}")
fi

if [ "$target" = "tab" ]; then
  split_json=$(herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label hunk --focus)
  hunk_pane=$(jq -r '.result.root_pane.pane_id' <<<"$split_json")
else
  : "${pane_id:?missing focused Herdr pane id}"
  split_json=$(herdr pane split "$pane_id" --direction right --cwd "$cwd" --focus)
  hunk_pane=$(jq -r '.result.pane.pane_id' <<<"$split_json")
fi

herdr pane rename "$hunk_pane" hunk
herdr pane run "$hunk_pane" exec "${hunk_cmd[@]}"
