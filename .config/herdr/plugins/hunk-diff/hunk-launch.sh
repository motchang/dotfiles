#!/usr/bin/env bash
# Local exec-based replacement for edmundmiller/herdr-plugin-hunk: launches
# `hunk` directly in the target pane (via `exec`) instead of leaving a shell
# wrapping it, same trick as ../claude-fork/fork.sh.
# Credit to edmundmiller for the original approach:
# https://github.com/edmundmiller/herdr-plugin-hunk
set -euo pipefail

mode="${1:?usage: hunk-launch.sh <worktree|staged|branch> <split|tab>}"
target="${2:?usage: hunk-launch.sh <worktree|staged|branch> <split|tab>}"

case "$mode" in worktree|staged|branch) ;; *) echo "invalid mode: $mode" >&2; exit 1 ;; esac
case "$target" in split|tab) ;; *) echo "invalid target: $target" >&2; exit 1 ;; esac

ctx="${HERDR_PLUGIN_CONTEXT_JSON:-}"
[ -n "$ctx" ] || ctx='{}'
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
    remote_head=$(git -C "$cwd" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)
    base=""
    for candidate in "$remote_head" origin/main origin/master main master; do
      [ -n "$candidate" ] || continue
      if git -C "$cwd" rev-parse --verify "$candidate" >/dev/null 2>&1; then
        base="$candidate"
        break
      fi
    done
    base="${base:-origin/main}"
    # Diff the working tree against the merge base rather than passing a
    # `base...branch` commit range: a range hides staged/unstaged/untracked
    # work, which is usually the part still being reviewed. A single ref makes
    # hunk diff base -> working tree, so committed and uncommitted changes show
    # up together. Set HUNK_DIFF_COMMITTED_ONLY=1 for the range-only view.
    merge_base=""
    if [ -z "${HUNK_DIFF_COMMITTED_ONLY:-}" ]; then
      merge_base=$(git -C "$cwd" merge-base "$base" HEAD 2>/dev/null || true)
      # Abbreviate so hunk's title stays readable; it shows the ref verbatim.
      [ -n "$merge_base" ] && merge_base=$(git -C "$cwd" rev-parse --short "$merge_base" 2>/dev/null || true)
    fi
    if [ -n "$merge_base" ]; then
      diff_args=(diff "$merge_base")
    else
      diff_args=(diff "${base}...${branch}")
    fi
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
