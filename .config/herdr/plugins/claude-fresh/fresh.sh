#!/usr/bin/env bash
# Open a *fresh* Claude Code session in a new split pane next to the pane this
# action ran from. Sibling of ../claude-fork: same split-then-launch shape, but
# a brand-new conversation instead of `--fork-session`'s carried-over history.
#
# What carries over: the source pane's cwd, its `--add-dir` set, and
# CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD. Together those are what `cw`
# hands a pane to give it its multi-repo view, so a fresh sibling that dropped
# them would quietly see a different set of repos than the pane it came from.
#
# What deliberately does not carry over: everything else in the source argv.
# --resume/--continue and a one-shot prompt are exactly what "fresh" rules out,
# and a pane created by claude-fork runs with `--resume <id> --fork-session`, so
# blanket argv reuse would make "fresh" fork the conversation instead.
#
# Both `herdr pane split` and `herdr pane run` go through the pane's interactive
# zsh — `pane run` is send-text-plus-Enter, which is why `exec` (a shell
# builtin, with no binary of that name) works and replaces zsh with claude.
#
# Set CLAUDE_FRESH_DRY_RUN=1 to print the two herdr calls without running them.
set -euo pipefail

direction="${1:-right}"
case "$direction" in
  right|down) ;;
  *)
    echo "usage: fresh.sh [right|down]" >&2
    exit 1
    ;;
esac

pane_id="${HERDR_PANE_ID:?HERDR_PANE_ID not set — run this action from a pane context}"

cwd=$(herdr pane get "$pane_id" | jq -r '.result.pane.cwd')

# The pane's Claude process. Prefer the foreground process group leader so a
# nested `claude` spawned by a Bash tool call can't be mistaken for the session.
claude_json=$(herdr pane process-info --pane "$pane_id" | jq -c '
  .result.process_info as $pi
  | [ $pi.foreground_processes[]
      | select((.argv[0] | split("/") | last) == "claude") ] as $c
  | ( [ $c[] | select(.pid == $pi.foreground_process_group_id) ] + $c )
  | .[0] // empty
')

if [ -z "$claude_json" ]; then
  echo "No Claude Code process found in pane $pane_id" >&2
  exit 1
fi

# --- carry over the --add-dir set -------------------------------------------
# `--add-dir` is variadic, so consume tokens after it until the next flag, and
# accept the --add-dir=PATH spelling too.
src_argv=()
while IFS= read -r arg; do
  src_argv+=("$arg")
done < <(jq -r '.argv[1:][]' <<<"$claude_json")

# A variadic group's end is ambiguous: `cw` appends the caller's own claude args
# after its generated --add-dir flags, so `cw <preset> "do the thing"` puts a
# one-shot prompt exactly where another directory would go. --add-dir takes
# directory paths, so require one — the prompt is not a directory, so it drops
# out, which is what a fresh session wants anyway. Resolve relative to the source
# pane rather than to this script, which runs from the herdr server's cwd.
is_pane_dir() {
  case "$1" in
    /*) [ -d "$1" ] ;;
    *)  [ -d "$cwd/$1" ] ;;
  esac
}

add_dirs=()
i=0
n=${#src_argv[@]}
while [ "$i" -lt "$n" ]; do
  case "${src_argv[$i]}" in
    --add-dir)
      i=$((i + 1))
      while [ "$i" -lt "$n" ]; do
        case "${src_argv[$i]}" in
          -*) break ;;
        esac
        is_pane_dir "${src_argv[$i]}" || break
        add_dirs+=("${src_argv[$i]}")
        i=$((i + 1))
      done
      continue
      ;;
    --add-dir=*)
      # Unambiguous spelling — a prompt cannot arrive this way, so take it as given.
      add_dirs+=("${src_argv[$i]#--add-dir=}")
      ;;
  esac
  i=$((i + 1))
done

# --- carry over the additional-CLAUDE.md opt-in -----------------------------
# Read it off the live process rather than this script's own environment: plugin
# actions run from the herdr server, not from the pane.
md_var=CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD
claude_pid=$(jq -r '.pid' <<<"$claude_json")
if [ -r "/proc/$claude_pid/environ" ]; then
  md_val=$(tr '\0' '\n' < "/proc/$claude_pid/environ" | sed -n "s/^$md_var=//p" | head -1)
else
  # macOS: `ps -E` appends the environment to the command, space separated. That
  # split is only safe for a value that cannot contain a space, so require one.
  md_val=$(ps -p "$claude_pid" -E -o command= 2>/dev/null \
    | tr ' ' '\n' | sed -n "s/^$md_var=//p" | head -1)
fi
env_flags=()
case "$md_val" in
  '') ;;
  *[!A-Za-z0-9_.:/-]*) ;;
  *) env_flags=(--env "$md_var=$md_val") ;;
esac

# --- build the launch line ---------------------------------------------------
# `pane run` sends literal text to zsh, so each path has to arrive quoted.
shq() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

cmd="exec claude"
for d in ${add_dirs[@]+"${add_dirs[@]}"}; do
  cmd="$cmd --add-dir $(shq "$d")"
done

if [ -n "${CLAUDE_FRESH_DRY_RUN:-}" ]; then
  printf 'herdr pane split --pane %s --direction %s --cwd %s%s --focus\n' \
    "$pane_id" "$direction" "$(shq "$cwd")" \
    "$( [ ${#env_flags[@]} -gt 0 ] && printf ' --env %s' "$(shq "${env_flags[1]}")" )"
  printf 'herdr pane run <new-pane> %s\n' "$cmd"
  exit 0
fi

split_json=$(herdr pane split --pane "$pane_id" --direction "$direction" --cwd "$cwd" \
  ${env_flags[@]+"${env_flags[@]}"} --focus)
new_pane_id=$(jq -r '.result.pane.pane_id' <<<"$split_json")

herdr pane run "$new_pane_id" "$cmd"
